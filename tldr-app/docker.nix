{ pkgs, app }:
pkgs.dockerTools.buildLayeredImage {
    name = app.name;
    tag = "latest";

    config = {
        Cmd = [app.bin] ++ app.prodArgs;
    };

    contents = [
        pkgs.dockerTools.caCertificates
    ];
}
