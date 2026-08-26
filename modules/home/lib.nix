{ lib, pkgs, ... }:

with lib;

let
  gitIni = pkgs.formats.gitIni { };
  ini = pkgs.formats.ini { };
  toml = pkgs.formats.toml { };
  yaml = pkgs.formats.yaml { };
in
{
  mkGitConfigTemplate =
    {
      name,
      email,
      username,
      signingKey,
      extraConfig,
    }:
    {
      file = gitIni.generate "${username}-gitconfig" (
        recursiveUpdate {
          user = {
            inherit email name;
            signingkey = signingKey;
          };
          commit.gpgsign = true;
          gpg.format = "ssh";
        } extraConfig
      );
    };

  mkJujutsuConfigTemplate =
    {
      name,
      email,
      signingKey,
      username,
      extraConfig,
    }:
    {
      file = toml.generate "${username}-jujutsu-config" (
        recursiveUpdate {
          git.sign-on-push = true;
          remotes.origin.auto-track-bookmarks = "${username}/*";
          signing = {
            backend = "ssh";
            behavior = "own";
            key = signingKey;
          };
          templates.git_push_bookmark = "\"${username}/push-\" ++ change_id.short()";
          user = {
            inherit email name;
          };
        } extraConfig
      );
    };

  mkGhstackConfigTemplate =
    {
      username,
      token,
      extraConfig,
    }:
    {
      file = ini.generate "${username}-ghstackrc" (
        recursiveUpdate {
          ghstack = {
            github_oauth = token;
            github_url = "github.com";
            github_username = username;
          };
        } extraConfig
      );
      mode = "0640";
    };

  mkGlabConfigTemplate =
    {
      username,
      hosts,
      extraConfig,
    }:
    {
      file = yaml.generate "${username}-glabrc" (
        recursiveUpdate {
          git_protocol = "https";
          hosts = mapAttrs (host: token: {
            api_host = host;
            api_protocol = "https";
            inherit token;
          }) hosts;
        } extraConfig
      );
    };
}
