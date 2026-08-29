<!-- owner: shikanime | zone: internal | purpose: explain the module tree and fragment-isolation design so a new identity lands in the right file -->

# Architecture

## Goal

One repo owns every persona's PII (name, email, SSH signing key) behind SOPS,
and each identity generates includable config fragments via sops templates. The
single design constraint is **isolation**: turning on multiple identities must
never leak one persona's config into another repo. Each identity is scoped to
its own `git.condition` and JJ repository set.

## Module tree

```text
modules/home/
  default.nix      # aggregator: imports every identity module
  identities.nix   # top-level options (global toggle, git/jj/glab)
  shikanime.nix    # primary identity (sops + git + jj + glab)
  gouv.nix         # government identity (sops + git + jj)
  automata.nix     # YoRHa operator identity (sops + git + jj)
  lib.nix          # sops template helpers (mkGitConfigTemplate, ...)

secrets/
  shikanime.enc.yaml   # sops-encrypted PII for shikanime
  gouv.enc.yaml        # sops-encrypted PII for gouv
  automata.enc.yaml    # sops-encrypted PII for automata
```

`modules/home/default.nix` is the public surface: it imports all identities and
exposes `identities.homeModules.default`. Each `<name>.nix` declares its SOPS
secrets and renders the fragments; `lib.nix` holds the shared template helpers.

## Fragment-only rule

The modules write **only** config fragments. They do not set
`programs.git.enable`, `programs.jujutsu.enable`, etc. — the consumer's Home
Manager config owns tool enablement. A fragment emitted here that the consumer
has not enabled is simply inert. Never add tool-enablement to these modules.

## Isolation rule

Each identity stays scoped by `identities.<name>.git.condition` (a `gitpath:`
match) and `identities.<name>.jj.extraConfig."--when".repositories`. A binding
that fires outside its scoped repo is a bug, not a feature; keep the scoping in
the identity module, not in the consumer.
