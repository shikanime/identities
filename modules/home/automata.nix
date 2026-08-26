{
  config,
  lib,
  identities-lib,
  ...
}:

with lib;

let
  cfg = config.identities;
in
{
  imports = [
    ./identities.nix
  ];

  options.identities.automata = {
    enable = mkEnableOption "the automata identity";

    git = {
      enable = mkEnableOption "git identity includes for automata" // {
        default = config.identities.git.enable;
      };

      condition = mkOption {
        default = null;
        description = ''
          Optional git include condition, such as `gitpath:<path>`.
        '';
        type = types.nullOr types.str;
      };

      extraConfig = mkOption {
        default = config.identities.git.extraConfig;
        description = ''
          Extra git config merged into the generated identity include.
          Signing settings are fixed by this module and cannot be overridden.
        '';
        type = types.attrs;
      };
    };

    jj = {
      enable = mkEnableOption "Jujutsu identity config for automata" // {
        default = config.identities.jj.enable;
      };

      priority = mkOption {
        default = 20;
        description = ''
          Priority of the generated Jujutsu config file for automata.
        '';
        type = types.int;
      };

      extraConfig = mkOption {
        default = config.identities.jj.extraConfig;
        description = ''
          Extra Jujutsu config merged into the generated identity include.
          Signing settings are fixed by this module and cannot be overridden.
        '';
        type = types.attrs;
      };
    };

    glab = {
      enable = mkEnableOption "glab config for automata" // {
        default = config.identities.glab.enable;
      };

      extraConfig = mkOption {
        default = config.identities.glab.extraConfig;
        description = ''
          Extra glab config merged into the generated config.
          The GitLab host and token fields are fixed by the module and cannot be
          overridden.
        '';
        type = types.attrs;
      };
    };
  };

  # yohra-operator is the GitHub login (automata taken, formerly yorha-automata);
  # the option and docs stay on the public name automata.
  config = mkIf (cfg.enable && cfg.automata.enable) {
    sops = {
      secrets = {
        automata-username.sopsFile = ../../secrets/automata.enc.yaml;
        automata-email.sopsFile = ../../secrets/automata.enc.yaml;
        automata-name.sopsFile = ../../secrets/automata.enc.yaml;
        automata-gpg-key.sopsFile = ../../secrets/automata.enc.yaml;
        automata-ssh-signing-key.sopsFile = ../../secrets/automata.enc.yaml;
        automata-gitlab-token.sopsFile = ../../secrets/automata.enc.yaml;
      };

      templates = {
        "automata-git-config" = mkIf cfg.automata.git.enable (
          identities-lib.mkGitConfigTemplate {
            name = config.sops.placeholder."automata-name";
            email = config.sops.placeholder."automata-email";
            username = config.sops.placeholder."automata-username";
            signingKey = config.sops.placeholder."automata-ssh-signing-key";
            extraConfig = cfg.automata.git.extraConfig;
          }
        );

        "automata-jj-config" = mkIf cfg.automata.jj.enable (
          identities-lib.mkJujutsuConfigTemplate {
            name = config.sops.placeholder."automata-name";
            email = config.sops.placeholder."automata-email";
            username = config.sops.placeholder."automata-username";
            signingKey = config.sops.placeholder."automata-ssh-signing-key";
            extraConfig = cfg.automata.jj.extraConfig;
          }
        );

        "automata-glab-config" = mkIf cfg.automata.glab.enable (
          identities-lib.mkGlabConfigTemplate {
            username = config.sops.placeholder."automata-username";
            token = config.sops.placeholder."automata-gitlab-token";
            extraConfig = cfg.automata.glab.extraConfig;
          }
        );
      };
    };

    programs.git.includes = mkIf cfg.automata.git.enable [
      (
        {
          path = config.lib.file.mkOutOfStoreSymlink config.sops.templates."automata-git-config".path;
        }
        // optionalAttrs (cfg.automata.git.condition != null) {
          condition = cfg.automata.git.condition;
        }
      )
    ];

    xdg.configFile."jj/conf.d/${toString cfg.automata.jj.priority}-automata.toml" =
      mkIf cfg.automata.jj.enable
        {
          source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."automata-jj-config".path;
        };

    xdg.configFile."glab-cli/automata/config.yml" = mkIf cfg.automata.glab.enable {
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."automata-glab-config".path;
    };
  };
}
