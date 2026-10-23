{
  pkgs ? import <nixpkgs> { },
  delay ? "0.05",
  init_state,
}:
let
  initJson = builtins.toJSON init_state;

  frameExpr = ''
    let
      life = import ${./life.nix};
      s = builtins.fromJSON (builtins.getEnv "STATE");
    in { frame = life.render s; next = life.step s; }
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
      printf '\033[2J\033[Hgen %s\n%s\n' "$gen" "$(jq -r .frame <<<"$out")"
      state=$(jq -c .next <<<"$out")
      gen=$((gen + 1))
      sleep ${delay}
    done
  '';
}
