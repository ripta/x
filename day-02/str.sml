structure StringUtils =
  struct
    (* val matchNewline = fn : char -> bool *)
    fun matchNewline (c : char) = c <> #"\n";

    (* val chomp = fn : string -> string *)
    fun chomp (input : string) = String.implode (List.filter matchNewline (String.explode input));

    (* val consume = fn : TextIO.instream -> string list *)
    fun consume (stream : TextIO.instream) =
      case TextIO.inputLine stream of
          SOME line => chomp line :: consume stream
        | NONE      => []
      ;

    (* val before : ('a * 'b) -> 'a *)
    (* val linesFromFile = fn : string -> string list *)
    fun linesFromFile (infile : string) =
      let
        val file = TextIO.openIn infile
      in
        let
          val ret = consume file
          val _   = TextIO.closeIn file
        in ret
        end
      end;

    fun trimSpaces s =
      String.translate (fn c => if c = #" " then "" else str c) s;

    fun tokenizeOn sep =
      String.tokens (fn c => c = sep);

    val concatLines = foldr (fn (a, b) => a ^ "\n" ^ b) "";
    val concatLines2 = foldr (fn (a, b) => (concatLines a) ^ "\n" ^ b) "";
  end;
