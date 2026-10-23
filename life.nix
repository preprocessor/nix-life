let
  inherit (builtins)
    length
    elemAt
    head
    genList
    concatStringsSep
    ;
  # cell lookup, everything outside the grid is "dead"
  at =
    grid: row: col:
    let
      rows = length grid;
      cols = length (head grid);
    in
    if row < 0 || row >= rows || col < 0 || col >= cols then 0 else elemAt (elemAt grid row) col;

  neighbours =
    grid: row: col:
    at grid (row - 1) (col - 1)
    + at grid (row - 1) col
    + at grid (row - 1) (col + 1)
    + at grid row (col - 1)
    + at grid row (col + 1)
    + at grid (row + 1) (col - 1)
    + at grid (row + 1) col
    + at grid (row + 1) (col + 1);

  rule = alive: neighbours: if neighbours == 3 || (alive == 1 && neighbours == 2) then 1 else 0;
in
{
  step = g: genList (r: genList (c: rule (at g r c) (neighbours g r c)) (length (head g))) (length g);

  render =
    g:
    concatStringsSep "\n" (map (row: concatStringsSep "" (map (x: if x == 1 then "█" else "-") row)) g);
}
