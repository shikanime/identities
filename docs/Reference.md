<!-- owner: shikanime | zone: internal | purpose: the identities.* option namespace and generated fragment surface -->

# Reference

## Option namespace (`identities.*`)

Set under a Home Manager config after importing
`identities.homeModules.default`.

| Option                                | Effect                                  |
| ------------------------------------- | --------------------------------------- |
| `identities.enable`                   | Global toggle for all identities.       |
| `identities.<name>.enable`            | Per-identity toggle.                    |
| `identities.<name>.git.enable`        | Emit the git include fragment.          |
| `identities.<name>.jj.enable`         | Emit the `jj/conf.d/<name>.toml`.       |
| `identities.<name>.git.condition`     | `gitpath:` scoping for the git include. |
| `identities.<name>.git.extraConfig`   | Merged into the generated git include.  |
| `identities.<name>.jj.extraConfig`    | Merged into the generated JJ config.    |
| `identities.shikanime.glab.enable`    | Emit glab config for shikanime.         |
| `identities.shikanime.ghstack.enable` | Emit ghstack config for shikanime.      |

## Exposed flake module

| Attribute             | Target       | Source                     |
| --------------------- | ------------ | -------------------------- |
| `homeModules.default` | Home Manager | `modules/home/default.nix` |

## Generated files

| Identity    | Output                                           |
| ----------- | ------------------------------------------------ |
| `shikanime` | git includes, `jj/conf.d/shikanime.toml`         |
| `gouv`      | git includes (scoped), `jj/conf.d/gouv.conf`     |
| `automata`  | git includes (scoped), `jj/conf.d/automata.toml` |

## Secrets

Encrypted with age key
`age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g`.

| File                         | Holds                                                                         |
| ---------------------------- | ----------------------------------------------------------------------------- |
| `secrets/shikanime.enc.yaml` | `name`, `email`, `gpg-key`, `ssh-signing-key`, `github-token`, `gitlab-token` |
| `secrets/gouv.enc.yaml`      | `name`, `email`, `gpg-key`, `ssh-signing-key`                                 |
| `secrets/automata.enc.yaml`  | `name`, `email`, `gpg-key`, `ssh-signing-key`                                 |
