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
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    supportedDockerSystems = ["x86_64-linux" "aarch64-linux"];
    forDockerSystems = nixpkgs.lib.genAttrs supportedDockerSystems;

    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

    app = forAllSystems (system: import ./app.nix {
      inherit self;
      pkgs = pkgs.${system}; 
      poetry2nix = poetry2nix.lib.mkPoetry2Nix { pkgs = pkgs.${system}; };
    });

    image = forDockerSystems (system: import ./docker.nix {
      pkgs = pkgs.${system}; 
      app = app.${system}; 
    });
  in
  {
    apps = forAllSystems (system: {
      default = {
        type = "app";
        program = app.${system}.bin;
      };
    });

    devShells = forAllSystems (system: {
      default = app.${system}.devEnv;
    });

    packages = forDockerSystems (system: {
      default = image.${system};
    });
  };
}
