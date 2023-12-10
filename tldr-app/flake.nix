{
  description = "tldr-app flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix }:
    let
      name = "tldr-app";

      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      p2n = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

      poetryParams = {
        projectDir = ./.;
      };
      app = p2n.mkPoetryApplication poetryParams;

      dependencies = with pkgs; [ tldr ];

      appWrapper = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = dependencies;
        text = ''
          ${app.dependencyEnv}/bin/uvicorn "$@" tldr_app.main:app
        '';
      };
      appWrapperBin = "${appWrapper}/bin/${name}";

      devEnv = p2n.mkPoetryEnv poetryParams;
      devDependencies = with pkgs; [ docker poetry ];
    in
    {
      apps.x86_64-linux.default = {
        type = "app";
        program = appWrapperBin;
      };

      devShells.x86_64-linux.default = devEnv.env.overrideAttrs (oldAttrs: {
          buildInputs = dependencies ++ devDependencies;
      });

      image = pkgs.dockerTools.buildImage {
        inherit name;
        tag = "latest";

        config = {
          Cmd = [appWrapperBin "--host" "0.0.0.0" "--port" "80"];
        };

        copyToRoot = [
          pkgs.dockerTools.caCertificates
        ];

        runAsRoot = ''
          mkdir -p /tmp
        '';
      };
    };
}
