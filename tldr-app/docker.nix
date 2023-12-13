{ pkgs, app }:
pkgs.dockerTools.buildImage {
    name = app.name;
    tag = "latest";

    config = {
        Cmd = [app.bin] ++ app.prodArgs;
    };

    copyToRoot = [
        pkgs.dockerTools.caCertificates
    ];

    runAsRoot = ''
        mkdir -p /tmp
    '';
}
