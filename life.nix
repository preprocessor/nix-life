{ wrap, grid }:
let
  inherit (builtins)
    concatStringsSep
    genList
    elemAt
    length
    ceil
    head
    ;

  rowCount = length grid;
  colCount = length (head grid);

  # cell lookup, everything outside the grid is dead
  lookup =
    x: y: if y < 0 || x < 0 || y >= rowCount || x >= colCount then 0 else elemAt (elemAt grid y) x;
  at =
    x: y:
    if wrap then
      let
        wrap =
          val: max:
          if val == -1 then
            max - 1
          else if val == max then
            0
          else
            val;
        wrapX = wrap x colCount;
        wrapY = wrap y rowCount;
      in
      lookup wrapX wrapY
    else
      lookup x y;
  # return number of neighbours for a given cell pos
  neighbours =
    x: y:
    /*nixfmt:disable*/
      at (x - 1) (y + 1)
    + at  x      (y + 1)
    + at (x + 1) (y + 1)
    + at (x - 1)  y
    + at (x + 1)  y
    + at (x - 1) (y - 1)
    + at  x      (y - 1)
    + at (x + 1) (y - 1);
    /*nixfmt:enable*/

  # get the next state of a cell given the cell and its number of neighbours
  rule = cell: neighbours: if neighbours == 3 || (cell == 1 && neighbours == 2) then 1 else 0;
in
{
  # The next generation step
  step = genList (y: genList (x: rule (at x y) (neighbours x y)) colCount) rowCount;

  render =
    let
      renderCell =
        x: y:
        let
          top = at x (2 * y);
          bottom = at x (2 * y + 1);
        in
        if top == 1 && bottom == 1 then
          "█"
        else if top == 0 && bottom == 0 then
          " "
        else if top > bottom then
          "▀"
        else
          "▄";

      rendered = genList (y: genList (x: renderCell x y) colCount) (ceil rowCount / 2 + 1);
    in
    concatStringsSep "\n" (map (concatStringsSep "") rendered);
}
