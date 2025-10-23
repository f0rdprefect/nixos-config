# NixOS Configuration Agent Guidelines

## Build, Lint, & Test Commands
- `nix flake check` - Validate flake configuration
- `nixfmt-rfc-style ./**/*.nix` - Format all Nix files (RFC style)
- `statix check` - Static analysis for Nix expressions
- `nh os switch --hostname &lt;hostname&gt;` - Apply full system rebuild
- `nh os test --hostname &lt;hostname&gt;` - Test changes without persistence (full config)
- `nh home switch --username &lt;username&gt;` - Apply home-manager changes only
- For single module test: `nixos-rebuild test --install-bootloader -I nixos-config=hosts/&lt;hostname&gt;/configuration.nix` (adapt for specific modules)

## Code Style Guidelines
- **Files**: `.nix` extension, `kebab-case.nix` naming (e.g., `hardware-configuration.nix`)
- **Structure**: `config/` for shared, `hosts/&lt;hostname&gt;/` for host-specific, `users/&lt;username&gt;/` for user configs
- **Imports**: Relative paths (`../../`), group by category at top; use `lib` for Nixpkgs functions
- **Formatting**: 2-space indentation, RFC-style attrsets; run `nixfmt` before commits
- **Naming**: `camelCase` for variables (e.g., `gitUsername`), `PascalCase` for module names if needed
- **Types**: Use Nix type annotations (e.g., `types.str`) for module options; ensure type safety with `lib.types`
- **Conditionals**: `lib.mkIf` for ifs, `lib.mkDefault` for overridable defaults
- **Error Handling**: Use `lib.warn` or `throw` for config errors; validate inputs with assertions
- **Secrets**: Store in `secrets/secrets.yaml` via SOPS; never commit raw secrets
- **Comments**: Add for complex configs; avoid in simple attrsets
- **Patterns**: Prefer `let ... in` for expressions; keep modular and reusable

## Additional Notes
- No Cursor/Copilot rules found in repo
- Always test rebuilds before switching; mimic existing patterns in codebase