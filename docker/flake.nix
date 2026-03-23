{
  description = "Container runtime packages for Claude Sandbox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    claude-status-nix = {
      url = "github:claude-contrib/claude-status";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      claude-code-nix,
      claude-status-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        claude-code = claude-code-nix.packages.${system}.default;
        claude-status = claude-status-nix.packages.${system}.default;
      in
      {
        packages.claude-sandbox = pkgs.buildEnv {
          paths = with pkgs; [
            claude-code
            claude-status
            ripgrep
            gosu
            gh
            jq
          ];
        };
      }
    );
}
