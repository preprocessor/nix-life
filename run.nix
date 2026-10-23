{
  pkgs ? import <nixpkgs> { },
  delay ? 0.0,
  wrap ? false,
  init_state,
}:
let
  initJson = builtins.toJSON init_state;

  frameExpr = /* nix */ ''
    let
      grid = builtins.fromJSON (builtins.getEnv "STATE");
      life = import ${./life.nix} {
        inherit grid;
        wrap = ${if wrap then "true" else "false"};
      };
    in { frame = life.render; next = life.step; }
  '';
in
pkgs.writeShellApplication {
  name = "run";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.jq
  ];
  text = ''
    state='${initJson}'
    gen=0
    while true; do
      out=$(STATE="$state" nix-instantiate --eval --strict --json --expr '${frameExpr}')
      printf '\033[2J\033[HGeneration: %s\n%s\n' "$gen" "$(jq -r .frame <<<"$out")"
      state=$(jq -c .next <<<"$out")
      gen=$((gen + 1))
      sleep ${toString delay}
    done
  '';
}
