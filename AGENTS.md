# Identities

Nix flake modules for managing personas. Each identity declares its own sops
secrets for PII (name, email) and, where needed, an SSH signing key, then
generates includable config fragments via sops templates.

**The identity modules do NOT enable or configure the VCS tools themselves.**
They only emit config fragments. The consumer is responsible for enabling
`programs.git`, `programs.jujutsu`, etc.

## Identities

- **shikanime** — Primary identity for Shikanime Studio work.
  - Sops secrets: `shikanime-name`, `shikanime-email`, `shikanime-gpg-key`,
    `shikanime-ssh-signing-key`, `shikanime-github-token`,
    `shikanime-gitlab-token`
  - Sops file: `secrets/shikanime.enc.yaml`
  - Output: git includes, `jj/conf.d/shikanime.toml`
- **gouv** — Government identity.
  - Sops secrets: `gouv-name`, `gouv-email`, `gouv-gpg-key`,
    `gouv-ssh-signing-key`
  - Sops file: `secrets/gouv.enc.yaml`
  - Output: git includes (scoped via `git.condition`), `jj/conf.d/gouv.conf`
- **automata** — YoRHa operator identity (`yorha-automata` GitHub login).
  - Sops secrets: `automata-name`, `automata-email`, `automata-gpg-key`,
    `automata-ssh-signing-key`
  - Sops file: `secrets/automata.enc.yaml`
  - Output: git includes (scoped via `git.condition`), `jj/conf.d/automata.toml`

## Usage

Consumer must import both `sops-nix.homeModules.default` and the identities
module:

```nix
{
  inputs.identities.url = "github:x-shikanime/identities";
  inputs.sops-nix.url = "github:mic92/sops-nix";

  outputs = { self, identities, sops-nix, home-manager, ... }: {
    homeConfigurations.user = home-manager.lib.homeConfiguration {
      modules = [
        sops-nix.homeModules.default
        identities.homeModules.default

        # Identity modules write directly to programs.git.includes
      ];
    };
  };
}
```

## Options Design

Inspired by Catppuccin/nix:

- `identities.enable` — global toggle for all identity modules
- `identities.<name>.enable` — per-identity toggle
- `identities.<name>.git.enable` / `.jj.enable` — per-tool output control
- `identities.shikanime.glab.extraConfig` — forwarded glab config merged into
  the generated config; GitLab host and token fields are fixed by the module
- `identities.homeModules.default` — option-driven home-manager module that
  exposes `identities.shikanime.enable`, `identities.gouv.enable`, and
  `identities."automata".enable`

## File Structure

```text
modules/home/
├── default.nix        # Aggregator — imports all identities
├── identities.nix     # Top-level options (global toggle, git/jj/glab)
├── shikanime.nix      # Primary identity (sops + git + jj + glab)
├── gouv.nix           # Government identity (sops + git + jj)
├── automata.nix       # YoRHa operator identity (sops + git + jj)
└── lib.nix            # sops template helpers (mkGitConfigTemplate, etc.)

secrets/
├── shikanime.enc.yaml  # Sops-encrypted PII for shikanime
├── gouv.enc.yaml       # Sops-encrypted PII for gouv
└── automata.enc.yaml # Sops-encrypted PII for automata
```

## Sops

Secrets are encrypted with age key
`age1pwl9yz4k4255a4h8qz7lafce8wxhsul0cnqwmr8528fqgujlfshshv3z3g`. Edit with:
`sops secrets/<name>.enc.yaml`

## Coding Style

- Nix files: 2-space indentation, `with lib;` at top.
- Commit messages: plain-text capitalized title, no conventional-commit prefix.
- Run `nix fmt` before shipping.

## Stack Workflow

- Install the official GitHub extension once:
  `gh extension install github/gh-stack` (requires GitHub CLI ≥ 2.0; `gh stack`
  is in public preview and may change).
- Keep one logical change per PR; split large work into a stack of PRs.
- Create a stack: `gh stack init`, then `gh stack add` for each new branch, and
  commit on the active branch. `gh stack view` lists the stack.
- Submit/update: `gh stack submit` (add `--open` to open PRs, `--auto` to skip
  prompts). Resubmit after each change to refresh titles, bodies, and branches.
- Pull down an existing stack: `gh stack checkout <PR_NUMBER>` (also accepts a
  stack number, PR URL, or branch name).
- Rebase onto updated trunk: `gh stack rebase` (cascading), then
  `gh stack submit`.
- Land a stack: `gh stack merge` (interactive) or
  `gh stack merge <PR_NUMBER> --yes --squash` to merge up to a PR.
- Never `gh pr merge` on a stacked PR — only `gh stack merge` lands stacks.
- Never force-push stack branches; `gh stack` owns the branch pointers.
