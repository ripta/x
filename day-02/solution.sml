use "str.sml";

structure Solution =
  struct

    (* pull :: a single handful of cubes taken at the same time from bag *)
    datatype pull =
        (* RGB of (r, g, b) :: a pull consisting of the number of red, green,
         *    and blue cubes respectively *)
        RGB of int * int * int;

        (*   R of int
         * | G of int
         * | B of int *)

    (* game :: a collection of pulls with a game ID *)
    datatype game =
        (* Game of (id : int, pulls : pull list *)
        Game of int * pull list;

    (* toStringPull :: format a pull as a string *)
    fun toStringPull (p : pull) : string =
      case p of
          RGB (r, g, b) =>
              "r=" ^ (Int.toString r)
            ^ " g=" ^ (Int.toString g)
            ^ " b=" ^ (Int.toString b)
      ;

    (* splitPair :: split a string "3 blue" into (3, "blue") *)
    fun splitPair (part : string) : int * string =
      let
        val rawPair = StringUtils.tokenizeOn #" " part
        val cleanPair = map StringUtils.trimSpaces rawPair
        val amt =
          case Int.fromString (List.hd cleanPair) of
              SOME i => i
            | NONE   => 0
      in
        (amt, List.last cleanPair)
      end;

    (* val parts = [["3 blue", "4 red"], ["1 red", "2 green", "6 blue"], ...] *)
    fun parsePull (parts : string list) =
      let
        val acc = RGB (0, 0, 0)
        val pairs = map splitPair parts
        fun countRGB rgb [] = rgb
          | countRGB (RGB (r, g, b)) ((i, "red") :: xs)   = countRGB (RGB (r + i, g, b)) xs
          | countRGB (RGB (r, g, b)) ((i, "green") :: xs) = countRGB (RGB (r, g + i, b)) xs
          | countRGB (RGB (r, g, b)) ((i, "blue") :: xs)  = countRGB (RGB (r, g, b + i)) xs
      in
        countRGB acc pairs
      end;

    (* val line = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green" *)
    fun parseGame (line : string) =
      let
        (* val parts = ["Game 1", "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"] *)
        val parts = StringUtils.tokenizeOn #":" line

        (* val gameParts = ["Game", "1"] *)
        val gameParts = String.tokens Char.isSpace (List.hd parts)
        val gameID =
          case Int.fromString (List.last gameParts) of
              SOME i => i
            | NONE   => 0

        (* val rawPulls = ["3 blue, 4 red", "1 red, 2 green, 6 blue", "2 green"] *)
        val rawPulls = StringUtils.tokenizeOn #";" (List.last parts)

        (* val rawPullParts = [["3 blue", "4 red"], ["1 red", "2 green", "6 blue"], ...] *)
        val rawPullParts = map (StringUtils.tokenizeOn #",") rawPulls

        (* val pulls = [RGB(4, 0, 3), RGB(1, 2, 6), ...] *)
        val pulls = map parsePull rawPullParts
      in
        Game (gameID, pulls)
      end;

    (* toStringPulls :: format pulls into a multiline string *)
    fun toStringPulls (ps : pull list) : string = StringUtils.concatLines (map toStringPull ps);

    (* toStringGame :: format a game into a multiline string *)
    fun toStringGame (Game (id, pulls)) = (Int.toString id) ^ " :: " ^ (toStringPulls pulls);

    (* isPossiblePull pull1 pull2 :: determine whether pull2 is possible within
     *    the constraints of pull1 *)
    fun isPossiblePull (RGB (r, g, b)) (RGB (pr, pg, pb)) =
      (pr <= r) andalso (pg <= g) andalso (pb <= b);

    (* isPossibleGame pull game :: determine whether game is possible within the
     *    constraints of pull *)
    fun isPossibleGame rgb (Game (_, pulls)) =
      List.all (isPossiblePull rgb) pulls;

    (* minGameTokens :: determine the minimal pull constraint necessary to make
     *    all pulls within a game possible *)
    fun minGameTokens (Game (_, pulls)) =
      let
        val minTokens = RGB (0, 0, 0)
        fun maxRGB ((RGB (r1, g1, b1)), (RGB (r2, g2, b2))) =
          RGB (Int.max (r1, r2), Int.max (g1, g2), Int.max (b1, b2))
      in
        foldl maxRGB minTokens pulls
      end;

    (* pullPower :: calculate the "power" of a pull, defined by the problem as
     *    the product of r, g, and b components *)
    fun pullPower (RGB (r, g, b)) = r * g * b;

    (* run :: read from stdin, process games, and emit the answers to stdout *)
    fun run () =
      let
        val availableTokens = RGB (12, 13, 14)

        val input = StringUtils.consume TextIO.stdIn
        val games = map parseGame input

        val possibleGames = List.filter (isPossibleGame availableTokens) games
        val possibleGameIDs = map (fn (Game (id, _)) => id) possibleGames
        val sumOfPossibleGameIDs = foldl op+ 0 possibleGameIDs

        val powers = map pullPower (map minGameTokens games)
        val powerSum = foldl op+ 0 powers
      in
        (* print (StringUtils.concatLines (map toStringGame games)); *)
        print ("Part I - sum of possible game IDs: " ^ (Int.toString sumOfPossibleGameIDs) ^ "\n");
        print ("Part II - power sum of minimal game: " ^ (Int.toString powerSum) ^ "\n")
      end;

    (* main :: the Compilation Manager target *)
    fun main (prog, args) = (
      print ("Program: " ^ prog ^ "\n");
      RunCML.doit (fn () => (run (); ()), NONE);
      OS.Process.success
    )

  end; (* struct *)
