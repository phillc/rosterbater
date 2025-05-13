
{ pkgs }: {
  deps = [
    pkgs.ruby_3_3
    pkgs.postgresql
    pkgs.postgresql.lib
    pkgs.postgresql_15
    pkgs.postgresql_15.lib
    pkgs.libyaml
    pkgs.libyaml.dev
  ];
}
