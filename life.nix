#   step:   board -> board  (advance one generation)
#   render: board -> string (one text frame)
# A board is a list of rows, each row a list of 0/1.
let
  # cell lookup, with everything outside the grid counted as dead
  at =
    g: r: c:
    let
      rows = builtins.length g;
      cols = builtins.length (builtins.head g);
    in
    if r < 0 || r >= rows || c < 0 || c >= cols then 0 else builtins.elemAt (builtins.elemAt g r) c;

  neighbours =
    g: r: c:
    at g (r - 1) (c - 1)
    + at g (r - 1) c
    + at g (r - 1) (c + 1)
    + at g r (c - 1)
    + at g r (c + 1)
    + at g (r + 1) (c - 1)
    + at g (r + 1) c
    + at g (r + 1) (c + 1);

  rule = alive: n: if n == 3 || (alive == 1 && n == 2) then 1 else 0;
in
{
  step =
    g:
    builtins.genList (
      r: builtins.genList (c: rule (at g r c) (neighbours g r c)) (builtins.length (builtins.head g))
    ) (builtins.length g);

  render =
    g:
    builtins.concatStringsSep "\n" (
      map (row: builtins.concatStringsSep "" (map (x: if x == 1 then "█" else "·") row)) g
    );
}
