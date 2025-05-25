self:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.types) str;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;

  cfg = config.services.pilum-murialis-xyz;

  # Simple webhook server using netcat
  webhookServer = pkgs.writeScript "webhook-server" ''
    #!/bin/bash

    echo "Starting webhook server on port 8080..."

    while true; do
      echo "Waiting for webhook..."
      
      # Listen for HTTP request
      REQUEST=$(echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nBlog rebuild triggered" | \
        ${pkgs.netcat-gnu}/bin/nc -l -p 8080 -q 1)
      
      # Check if it's a POST to /webhook
      if echo "$REQUEST" | grep -q "POST /webhook"; then
        echo "Valid webhook received, triggering rebuild..."
        systemctl start blog-rebuild
      else
        echo "Invalid request, ignoring..."
      fi
      
      sleep 1
    done
  '';

  # Blog rebuild script
  rebuildScript = pkgs.writeScript "blog-rebuild" ''
    #!/bin/bash
    set -e

    CONTENT_DIR="/var/lib/blog/content"
    WEB_ROOT="/var/www/${cfg.domain}"

    echo "=== Blog Rebuild Started ==="

    # Create directories if they don't exist
    mkdir -p "$CONTENT_DIR"
    mkdir -p "$WEB_ROOT"

    # Clone or update content
    if [ ! -d "$CONTENT_DIR/.git" ]; then
      echo "Cloning content repository..."
      ${pkgs.git}/bin/git clone ${cfg.contentRepo} "$CONTENT_DIR"
    else
      echo "Updating content repository..."
      cd "$CONTENT_DIR"
      ${pkgs.git}/bin/git pull origin main
    fi

    # Build with Emacs
    echo "Building site with Emacs..."
    cd "$CONTENT_DIR"
    ${pkgs.emacs}/bin/emacs --batch --load src/publish.el --eval "(org-publish \"website\")"

    # Copy to web root
    echo "Deploying to web root..."
    ${pkgs.rsync}/bin/rsync -av --delete src/out/ "$WEB_ROOT/"

    # Fix permissions
    chown -R nginx:nginx "$WEB_ROOT"
    chmod -R 755 "$WEB_ROOT"

    echo "=== Blog Rebuild Complete ==="
  '';

in
{
  options.services.pilum-murialis-xyz = {
    enable = mkEnableOption "pilum-murialis-xyz blog";

    domain = mkOption {
      type = str;
      description = "Domain name for the blog";
      example = "pilum-murialis.xyz";
    };

    contentRepo = mkOption {
      type = str;
      description = "Git repository URL for blog content";
      example = "https://github.com/username/blog-content.git";
    };

    # email = mkOption {
    #   type = str;
    #   description = "Email for ACME/Let's Encrypt";
    #   example = "you@example.com";
    # };
  };

  config = mkIf cfg.enable {
    # Create blog user
    users.users.blog = {
      isSystemUser = true;
      group = "blog";
      home = "/var/lib/blog";
      createHome = true;
    };
    users.groups.blog = { };

    # Create directories
    systemd.tmpfiles.rules = [
      "d /var/www/${cfg.domain} 755 nginx nginx -"
      "d /var/lib/blog 755 blog blog -"
    ];

    # Blog rebuild service
    systemd.services.blog-rebuild = {
      description = "Rebuild blog from git";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = rebuildScript;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Webhook server service
    systemd.services.blog-webhook = {
      description = "Blog webhook server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = webhookServer;
        Restart = "always";
        RestartSec = "10s";
        User = "blog";
        Group = "blog";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Timer for periodic updates (backup method)
    systemd.services.blog-periodic = {
      description = "Periodic blog update";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = rebuildScript;
      };
    };

    systemd.timers.blog-periodic = {
      description = "Periodic blog update timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/10"; # Every 10 minutes
        Persistent = true;
      };
    };

    # Nginx configuration
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        root = "/var/www/${cfg.domain}";
        serverAliases = [ "www.${cfg.domain}" ];

        locations."/" = {
          index = "index.html";
          tryFiles = "$uri $uri/ =404";
        };

        # Webhook endpoint
        locations."/webhook" = {
          proxyPass = "http://127.0.0.1:8080";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
          '';
        };
      };
    };

    # System packages
    # environment.systemPackages = [
    #   pkgs.git
    #   pkgs.emacs
    #   deployScript # Available as 'deploy-blog' command
    # ];
  };
}
