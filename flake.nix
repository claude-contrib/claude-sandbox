{
  description = "Dev shell for Claude Sandbox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        claude-sandbox = pkgs.stdenvNoCC.mkDerivation {
          pname = "claude-sandbox";
          version = pkgs.lib.fileContents ./version.txt;
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin $out/share/claude-sandbox/scripts
            cp claude $out/share/claude-sandbox/
            cp version.txt $out/share/claude-sandbox/
            cp scripts/core.sh $out/share/claude-sandbox/scripts/
            cp scripts/docker.sh $out/share/claude-sandbox/scripts/
            cp claude-sandbox.yml $out/share/claude-sandbox/
            cp claude-sandbox.env.yml $out/share/claude-sandbox/
            cp claude-sandbox.net.yml $out/share/claude-sandbox/
            cp claude-sandbox.ssh.yml $out/share/claude-sandbox/
            chmod +x $out/share/claude-sandbox/claude
            makeWrapper $out/share/claude-sandbox/claude $out/bin/claude \
              --prefix PATH : ${
                pkgs.lib.makeBinPath [
                  pkgs.docker
                  pkgs.git
                ]
              }
          '';
        };
      in
      {
        packages.default = claude-sandbox;

        devShells.default = pkgs.mkShell {
          name = "claude-sandbox";
          packages = with pkgs; [
            bash
            bats
            shellcheck
          ];
        };
      }
    );
}
