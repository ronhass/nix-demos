{ pkgs, poetry2nix }:
let
  name = "tldr-app";

  poetryParams = {
    projectDir = ./.;
  };
  app = poetry2nix.mkPoetryApplication poetryParams;
  devEnv = poetry2nix.mkPoetryEnv poetryParams;

  dependencies = with pkgs; [ tldr ];
  devDependencies = with pkgs; [ docker poetry ];

  appWrapper = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = dependencies;
    text = ''
      ${pkgs.busybox}/bin/mkdir -p /tmp  # needed for tldr

      ${app.dependencyEnv}/bin/uvicorn "$@" tldr_app.main:app
    '';
  };

in
{
  inherit name;

  bin = "${appWrapper}/bin/${name}";

  prodArgs = ["--host" "0.0.0.0" "--port" "80"];

  devEnv = devEnv.env.overrideAttrs (oldAttrs: {
      buildInputs = dependencies ++ devDependencies;
  });
}
