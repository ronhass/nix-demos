{
  description = "tldr-app flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, poetry2nix, flake-utils }:
  flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] (system:
    let
      pkgs = nixpkgs.legacyPackages."${system}";
      p2n = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

      app = import ./app.nix { inherit pkgs; poetry2nix = p2n; };
      image = import ./docker.nix { inherit pkgs app; };
    in
    {
      apps.default = {
        type = "app";
        program = app.bin;
      };

      devShells.default = app.devEnv;

      image = image;
    }
  );
}
