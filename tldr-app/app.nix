{ self, pkgs, poetry2nix }:
let
  name = "tldr-app";

  pythonApp = poetry2nix.mkPoetryApplication { projectDir = self; };
  pythonEnv = poetry2nix.mkPoetryEnv { projectDir = self; };

  dependencies = with pkgs; [ tldr ];
  devDependencies = with pkgs; [ docker poetry ];

  appWrapper = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = dependencies;
    text = ''
      ${pkgs.busybox}/bin/mkdir -p /tmp  # needed for tldr

      ${pythonApp.dependencyEnv}/bin/uvicorn "$@" tldr_app.main:app
    '';
  };

in
{
  inherit name;

  bin = "${appWrapper}/bin/${name}";

  prodArgs = ["--host" "0.0.0.0" "--port" "80"];

  devEnv = pkgs.mkShellNoCC {
    packages = dependencies ++ devDependencies ++ [pythonEnv];
  };
}
