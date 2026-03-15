{
  description = "Sandboxed Docker environment for Claude Code";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { nixpkgs, flake-utils, claude-code-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        claude-code = claude-code-nix.packages.${system}.default;
      in
      {
        packages.claude-sandbox = pkgs.buildEnv {
          name = "claude-sandbox";
          paths = [
            claude-code
            pkgs.bash
            pkgs.git
            pkgs.gh
            pkgs.jq
            pkgs.ripgrep
            pkgs.curl
            pkgs.cacert
          ];
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            bats
            shellcheck
          ];
        };
      }
    );
}
