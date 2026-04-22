{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "python-env";
  targetPkgs = pkgs: (with pkgs;
    [
      thttpd
      postgresql
      (python39.withPackages (pkgs: with pkgs; [
        psycopg2
        flask
      ]))
    ]);
}).env