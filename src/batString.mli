(*
 * BatString - Additional functions for string manipulations.
 * Copyright (C) 2003 Nicolas Cannasse
 * Copyright (C) 1996 Xavier Leroy, INRIA Rocquencourt
 * Copyright (C) 2008 Edgar Friendly
 * Copyright (C) 2009 David Teller, LIFO, Universite d'Orleans
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(** String operations.

    Given a string [s] of length [l], we call character number in [s]
    the index of a character in [s].  Indexes start at [0], and we will
    call a character number valid in [s] if it falls within the range
    [[0...l-1]]. A position is the point between two characters or at
    the beginning or end of the string.  We call a position valid
    in [s] if it falls within the range [[0...l]]. Note that character
    number [n] is between positions [n] and [n+1].

    Two parameters [start] and [len] are said to designate a valid
    substring of [s] if [len >= 0] and [start] and [start+len] are
    valid positions in [s].

    OCaml strings can be modified in place, for instance via the
    {!String.set} and {!String.blit} functions described below.  This
    possibility should be used rarely and with much care, however, since
    both the OCaml compiler and most OCaml libraries share strings as if
    they were immutable, rather than copying them.  In particular,
    string literals are shared: a single copy of the string is created
    at program loading time and returned by all evaluations of the
    string literal.  Consider for example:

    {[
      # let f () = "foo";;
      val f : unit -> string = <fun>
          # (f ()).[0] <- 'b';;
      -: unit = ()
        # f ();;
      -: string = "boo"
    ]}

    Likewise, many functions from the standard library can return string
    literals or one of their string arguments.  Therefore, the returned strings
    must not be modified directly.  If mutation is absolutely necessary,
    it should be performed on a fresh copy of the string, as produced by
    {!String.copy}.

    This module replaces Stdlib's
    {{:http://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html}String}
    module.

    If you're going to do a lot of string slicing, BatSubstring might be
    a useful module to represent slices of strings, as it doesn't
    allocate new strings on every operation.

    @author Xavier Leroy (base library)
    @author Nicolas Cannasse
    @author David Teller
    @author Edgar Friendly
*)

open String

val init : int -> (int -> char) -> string
(** [init l f] returns the string of length [l] with the chars
    f 0 , f 1 , f 2 ... f (l-1).

    Example: [String.init 256 char_of_int]
*)

val is_empty : string -> bool
(** [is_empty s] returns [true] if [s] is the empty string, [false]
    otherwise.

    Usually a tad faster than comparing [s] with [""].

    Example (for some string [s]):
    [ if String.is_empty s then "(Empty)" else s ]
*)

external length : string -> int = "%string_length"
(** Return the length (number of characters) of the given string. *)

external get : string -> int -> char = "%string_safe_get"
(** [String.get s n] returns character number [n] in string [s].
    You can also write [s.[n]] instead of [String.get s n].

    @raise Invalid_argument if [n] not a valid character number in [s]. *)


external set : string -> int -> char -> unit = "%string_safe_set"
(** [String.set s n c] modifies string [s] in place,
    replacing the character number [n] by [c].
    You can also write [s.[n] <- c] instead of [String.set s n c].

    @raise Invalid_argument if [n] is not a valid character number in [s]. *)

external create : int -> string = "caml_create_string"
(** [String.create n] returns a fresh string of length [n].
    The string initially contains arbitrary characters.

    @raise Invalid_argument if [n < 0] or [n > ]{!Sys.max_string_length}. *)

val make : int -> char -> string
(** [String.make n c] returns a fresh string of length [n],
    filled with the character [c].

    @raise Invalid_argument if [n < 0] or [n > ]{!Sys.max_string_length}.*)

val copy : string -> string
(** Return a copy of the given string. *)

val sub : string -> int -> int -> string
(** [String.sub s start len] returns a fresh string of length [len],
    containing the substring of [s] that starts at position [start] and
    has length [len].

    @raise Invalid_argument if [start] and [len] do not
    designate a valid substring of [s]. *)

val fill : string -> int -> int -> char -> unit
(** [String.fill s start len c] modifies string [s] in place,
    replacing [len] characters by [c], starting at [start].

    @raise Invalid_argument if [start] and [len] do not
    designate a valid substring of [s]. *)

val blit : string -> int -> string -> int -> int -> unit
(** [String.blit src srcoff dst dstoff len] copies [len] characters
    from string [src], starting at character number [srcoff], to
    string [dst], starting at character number [dstoff]. It works
    correctly even if [src] and [dst] are the same string,
    and the source and destination intervals overlap.

    @raise Invalid_argument if [srcoff] and [len] do not
    designate a valid substring of [src], or if [dstoff] and [len]
    do not designate a valid substring of [dst]. *)

val concat : string -> string list -> string
(** [String.concat sep sl] concatenates the list of strings [sl],
    inserting the separator string [sep] between each. *)

val iter : (char -> unit) -> string -> unit
(** [String.iter f s] applies function [f] in turn to all
    the characters of [s].  It is equivalent to
    [f s.[0]; f s.[1]; ...; f s.[String.length s - 1]; ()]. *)

val iteri : (int -> char -> unit) -> string -> unit
(** Same as {!String.iter}, but the
    function is applied to the index of the element as first argument
    (counting from 0), and the character itself as second argument.
    @since 4.00.0
*)

val map : (char -> char) -> string -> string
(** [String.map f s] applies function [f] in turn to all
    the characters of [s] and stores the results in a new string that
    is returned.
    @since 4.00.0 *)

val trim : string -> string
(** Return a copy of the argument, without leading and trailing
    whitespace.  The characters regarded as whitespace are: [' '],
    ['\012'], ['\n'], ['\r'], and ['\t'].  If there is no leading nor
    trailing whitespace character in the argument, return the original
    string itself, not a copy.
    @since 4.00.0 *)

val escaped : string -> string
(** Return a copy of the argument, with special characters
    represented by escape sequences, following the lexical
    conventions of OCaml.  If there is no special
    character in the argument, return the original string itself,
    not a copy. Its inverse function is Scanf.unescaped. *)

val index : string -> char -> int
(** [String.index s c] returns the character number of the first
    occurrence of character [c] in string [s].

    @raise Not_found if [c] does not occur in [s]. *)

val rindex : string -> char -> int
(** [String.rindex s c] returns the character number of the last
    occurrence of character [c] in string [s].

    @raise Not_found if [c] does not occur in [s]. *)

val index_from : string -> int -> char -> int
(** [String.index_from s i c] returns the character number of the
    first occurrence of character [c] in string [s] after position [i].
    [String.index s c] is equivalent to [String.index_from s 0 c].

    @raise Invalid_argument if [i] is not a valid position in [s].
    @raise Not_found if [c] does not occur in [s] after position [i]. *)

val rindex_from : string -> int -> char -> int
(** [String.rindex_from s i c] returns the character number of the
    last occurrence of character [c] in string [s] before position [i+1].
    [String.rindex s c] is equivalent to
    [String.rindex_from s (String.length s - 1) c].

    @raise Invalid_argument if [i+1] is not a valid position in [s].
    @raise Not_found if [c] does not occur in [s] before position [i+1]. *)

val contains : string -> char -> bool
(** [String.contains s c] tests if character [c]
    appears in the string [s]. *)

val contains_from : string -> int -> char -> bool
(** [String.contains_from s start c] tests if character [c]
    appears in [s] after position [start].
    [String.contains s c] is equivalent to
    [String.contains_from s 0 c].

    @raise Invalid_argument if [start] is not a valid position in [s]. *)

val rcontains_from : string -> int -> char -> bool
(** [String.rcontains_from s stop c] tests if character [c]
    appears in [s] before position [stop+1].

    @raise Invalid_argument if [stop < 0] or [stop+1] is not a valid
    position in [s]. *)

val uppercase : string -> string
(** Return a copy of the argument, with all lowercase letters
    translated to uppercase, including accented letters of the ISO
    Latin-1 (8859-1) character set. *)

val lowercase : string -> string
(** Return a copy of the argument, with all uppercase letters
    translated to lowercase, including accented letters of the ISO
    Latin-1 (8859-1) character set. *)

val capitalize : string -> string
(** Return a copy of the argument, with the first character set to uppercase. *)

val uncapitalize : string -> string
(** Return a copy of the argument, with the first character set to lowercase. *)

type t = string
(** An alias for the type of strings. *)

val compare: t -> t -> int
(** The comparison function for strings, with the same specification as
    {!Pervasives.compare}.  Along with the type [t], this function [compare]
    allows the module [String] to be passed as argument to the functors
    {!Set.Make} and {!Map.Make}. *)

(** {6 Conversions} *)

val enum : string -> char BatEnum.t
(** Returns an enumeration of the characters of a string.
    The behaviour is unspecified if the string is mutated
    while it is enumerated.

    Examples:
      ["foo" |> String.enum |> List.of_enum = ['f'; 'o'; 'o']]
      [String.enum "a b c" // ((<>) ' ') |> String.of_enum = "abc"]
*)

val of_enum : char BatEnum.t -> string
(** Creates a string from a character enumeration.
    Example: [['f'; 'o'; 'o'] |> List.enum |> String.of_enum = "foo"]
*)

val backwards : string -> char BatEnum.t
(** Returns an enumeration of the characters of a string, from last to first.

    Examples:
    [ "foo" |> String.backwards |> String.of_enum = "oof" ]
    [ let rev s = String.backwards s |> String.of_enum ]
*)

val of_backwards : char BatEnum.t -> string
(** Build a string from an enumeration, starting with last character, ending with first.

    Examples:
    [ "foo" |> String.enum |> String.of_backwards = "oof" ]
    [ "foo" |> String.backwards |> String.of_backwards = "foo" ]
    [ let rev s = String.enum s |> String.of_backwards ]
*)


val of_list : char list -> string
(** Converts a list of characters to a string.

    Example: [ ['c'; 'h'; 'a'; 'r'; 's'] |> String.of_list = "chars" ]
*)

val to_list : string -> char list
(** Converts a string to the list of its characters.

    Example: [ String.to_list "string" |> List.interleave ';' |> String.of_list = "s;t;r;i;n;g" ]
*)

val of_int : int -> string
(** Returns the string representation of an int.

    Example: [ String.of_int 56 = "56" && String.of_int (-1) = "-1" ]
*)

val of_float : float -> string
(** Returns the string representation of an float.

    Example: [ String.of_float 1.246 = "1.246" ]
*)

val of_char : char -> string
(** Returns a string containing one given character.

    Example: [ String.of_char 's' = "s" ]
*)

val to_int : string -> int
(** Returns the integer represented by the given string
    or @raise Failure if the string does not represent an
    integer. This follows OCaml's int literal rules, so "0x"
    prefixes hexadecimal integers, "0o" for octal and "0b" for
    binary.  Underscores within the number are allowed for
    readability but ignored.

    Examples: [ String.to_int "8_480" = String.to_int "0x21_20" ]
    [ try ignore(String.to_int "2,3"); false with Failure _ -> true ]

    @raise Failure if the string does not represent an integer.
*)

val to_float : string -> float
(** Returns the float represented by the given string
    or @raise Failure if the string does not represent a float.
    Decimal points aren't required in the given string, as they are
    for float literals in OCaml, but otherwise the rules for float
    literals apply.

    Examples: [String.to_float "12.34e-1" = String.to_float "1.234"]
    [String.to_float "1" = 1.]
    [try ignore(String.to_float ""); false with Failure _ -> true]

    @raise Failure if the string does not represent a float.
*)

(** {6 String traversals} *)

val map : (char -> char) -> string -> string
(** [map f s] returns a string where all characters [c] in [s] have been
    replaced by [f c].

    Example: [String.map Char.uppercase "Five" = "FIVE"]
 **)

val fold_left : ('a -> char -> 'a) -> 'a -> string -> 'a
(** [fold_left f a s] is
    [f (... (f (f a s.[0]) s.[1]) ...) s.[n-1]]

    Examples: [String.fold_left (fun li c -> c::li) [] "foo" = ['o';'o';'f']]
    [String.fold_left max 'a' "apples" = 's']
*)

val fold_lefti : ('a -> int -> char -> 'a) -> 'a -> string -> 'a
(** As [fold_left], but with the index of the element as additional argument *)

val fold_right : (char -> 'a -> 'a) -> string -> 'a -> 'a
(** [fold_right f s b] is
    [f s.[0] (f s.[1] (... (f s.[n-1] b) ...))]

    Examples: [String.fold_right List.cons "foo" [] = ['f';'o';'o']]
    [String.fold_right (fun c a -> if c = ' ' then a+1 else a) "a b c" 0 = 2]
*)

val fold_righti : (int -> char -> 'a -> 'a) -> string -> 'a -> 'a
(** As [fold_right], but with the index of the element as additional argument *)

val filter : (char -> bool) -> string -> string
(** [filter f s] returns a copy of string [s] in which only
    characters [c] such that [f c = true] remain.

    Example: [ String.filter ((<>) ' ') "a b c" = "abc" ]
*)

val filter_map : (char -> char option) -> string -> string
(** [filter_map f s] calls [(f a0) (f a1).... (f an)] where [a0..an] are
    the characters of [s]. It returns the string of characters [ci] such as
    [f ai = Some ci] (when [f] returns [None], the corresponding element of
    [s] is discarded).

    Example: [ String.filter_map (function 'a'..'z' as c -> Some (Char.uppercase c) | _ -> None) "a b c" = "ABC" ]
*)


val iteri : (int -> char -> unit) -> string -> unit
(** [String.iteri f s] is equivalent to
    [f 0 s.[0]; f 1 s.[1]; ...; f len s.[len]] where [len] is length of string [s].
    Example:
    {[ let letter_positions word =
      let positions = Array.make 256 [] in
      let count_letter pos c =
        positions.(int_of_char c) <- pos :: positions.(int_of_char c) in
      String.iteri count_letter word;
      Array.mapi (fun c pos -> (char_of_int c, List.rev pos)) positions
      |> Array.to_list
      |> List.filter (fun (c,pos) -> pos <> [])
      in
      letter_positions "hello" = ['e',[1]; 'h',[0]; 'l',[2;3]; 'o',[4] ]
    ]}
*)

(** {6 Finding}*)



val find : string -> string -> int
(** [find s x] returns the starting index of the first occurrence of
    string [x] within string [s].

    {b Note} This implementation is optimized for short strings.

    @raise Not_found if [x] is not a substring of [s].

    Example: [String.find "foobarbaz" "bar" = 3]
*)

val find_from: string -> int -> string -> int
(** [find_from s pos x] behaves as [find s x] but starts searching
    at position [pos]. [find s x] is equivalent to [find_from s 0 x].

    @raise Not_found if not substring is found
    @raise Invalid_argument if [pos] is not a valid position in the string.

    Example: [String.find_from "foobarbaz" 4 "ba" = 6]
*)

val rfind : string -> string -> int
(** [rfind s x] returns the starting index of the last occurrence
    of string [x] within string [s].

    {b Note} This implementation is optimized for short strings.

    @raise Not_found if [x] is not a substring of [s].

    Example: [String.rfind "foobarbaz" "ba" = 6]
*)

val rfind_from: string -> int -> string -> int
(** [rfind_from s pos x] behaves as [rfind s x] but starts searching
    from the right at position [pos + 1]. [rfind s x] is equivalent to
    [rfind_from s (String.length s - 1) x].

    {b Beware}, it search between the {e beginning} of the string to
    the position [pos + 1], {e not} between [pos + 1] and the end.

    @raise Not_found if not substring is found
    @raise Invalid_argument if [pos] is not a valid position in the string.

    Example: [String.rfind_from "foobarbaz" 6 "ba" = 6]
*)

val find_all : string -> string -> int BatEnum.t
(** [find_all s x] enumerates positions of [s] at which [x] occurs.
    Example: [find_all "aabaabaa" "aba" |> List.of_enum] will return
    the list [[1; 4]].
    @since 2.2.0 *)

val ends_with : string -> string -> bool
(** [ends_with s x] returns [true] if the string [s] is ending with [x], [false] otherwise.

    Example: [String.ends_with "foobarbaz" "rbaz" = true]
*)

val starts_with : string -> string -> bool
(** [starts_with s x] returns [true] if [s] is starting with [x], [false] otherwise.

    Example: [String.starts_with "foobarbaz" "fooz" = false]
*)

val exists : string -> string -> bool
(** [exists str sub] returns true if [sub] is a substring of [str] or
    false otherwise.

    Example: [String.exists "foobarbaz" "obar" = true]
*)

(** {6 Transformations}*)

val lchop : ?n:int -> string -> string
(** Returns the same string but without the first [n] characters.
    By default [n] is 1.
    If [n] is strictly less than zero @raise Invalid_argument.
    If the string has [n] or less characters, returns the empty string.

      Example:
      [String.lchop "Weeble" = "eeble"]
      [String.lchop ~n:3 "Weeble" = "ble"]
      [String.lchop ~n:1000 "Weeble" = ""]
*)

val rchop : ?n:int -> string -> string
(** Returns the same string but without the last [n] characters.
    By default [n] is 1.
    If [n] is strictly less than zero @raise Invalid_argument.
    If the string has [n] or less characters , returns the empty string.

      Example:
      [String.rchop "Weeble" = "Weebl"]
      [String.rchop ~n:3 "Weeble" = "Wee"]
      [String.rchop ~n:1000 "Weeble" = ""]
*)

val trim : string -> string
(** Returns the same string but without the leading and trailing
    whitespaces (according to {!BatChar.is_whitespace}).

    Example: [String.trim " \t foo\n  " = "foo"]
*)

val quote : string -> string
(** Add quotes around a string and escape any quote or escape
    appearing in that string.  This function is used typically when
    you need to generate source code from a string.

    Examples:
    [String.quote "foo" = "\"foo\""]
    [String.quote "\"foo\"" = "\"\\\"foo\\\"\""]
    [String.quote "\n" = "\"\\n\""]
    etc.

    More precisely, the returned string conforms to the OCaml syntax:
    if printed, it outputs a representation of the input string as an
    OCaml string litteral.
*)

val left : string -> int -> string
(**[left r len] returns the string containing the [len] first
   characters of [r]. If [r] contains less than [len] characters, it
   returns [r].

   Examples:
   [String.left "Weeble" 4 = "Weeb"]
   [String.left "Weeble" 0 = ""]
   [String.left "Weeble" 10 = "Weeble"]
*)

val right : string -> int -> string
(**[left r len] returns the string containing the [len] last characters of [r].
   If [r] contains less than [len] characters, it returns [r].

   Example: [String.right "Weeble" 4 = "eble"]
*)

val head : string -> int -> string
(**as {!left}*)

val tail : string -> int -> string
(**[tail r pos] returns the string containing all but the [pos] first characters of [r]

   Example: [String.tail "Weeble" 4 = "le"]
*)

val strip : ?chars:string -> string -> string
(** Returns the string without the chars if they are at the beginning or
    at the end of the string. By default chars are " \t\r\n".

    Examples:
    [String.strip " foo " = "foo"]
    [String.strip ~chars:" ,()" " boo() bar()" = "boo() bar"]
*)

val replace_chars : (char -> string) -> string -> string
(** [replace_chars f s] returns a string where all chars [c] of [s] have been
    replaced by the string returned by [f c].

    Example: [String.replace_chars (function ' ' -> "(space)" | c -> String.of_char c) "foo bar" = "foo(space)bar"]
*)

val replace : str:string -> sub:string -> by:string -> bool * string
(** [replace ~str ~sub ~by] returns a tuple consisting of a boolean
    and a string where the first occurrence of the string [sub]
    within [str] has been replaced by the string [by]. The boolean
    is true if a subtitution has taken place.

    Example: [String.replace "foobarbaz" "bar" "rab" = (true, "foorabbaz")]
*)

val nreplace : str:string -> sub:string -> by:string -> string
(** [nreplace ~str ~sub ~by] returns a string obtained by iteratively
    replacing each occurrence of [sub] by [by] in [str], from right to left.
    It returns a copy of [str] if [sub] has no occurrence in [str].

    Example: [nreplace ~str:"bar foo aaa bar" ~sub:"aa" ~by:"foo" = "bar foo afoo bar"]
*)

val repeat: string -> int -> string
(** [repeat s n] returns [s ^ s ^ ... ^ s]

    Example: [String.repeat "foo" 4 = "foofoofoofoo"]
*)

val rev : string -> string
(** [string s] returns the reverse of string [s]

    @since 2.1
*)

(** {6 In-Place Transformations}*)

val rev_in_place : string -> unit
(** [rev_in_place s] mutates the string [s], so that its new value is
    the mirror of its old one: for instance if s contained ["Example!"], after
    the mutation it will contain ["!elpmaxE"]. *)

val in_place_mirror : string -> unit
(** @deprecated Use {!String.rev_in_place} instead *)

(** {6 Splitting around}*)

val split : string -> by:string -> string * string
(** [split s sep] splits the string [s] between the first
    occurrence of [sep], and returns the two parts before
    and after the occurence (excluded).

    @raise Not_found if the separator is not found.

    Examples:
    [String.split "abcabcabc" "bc" = ("a","abcabc")]
    [String.split "abcabcabc" "" = ("","abcabcabc")]
*)

val rsplit : string -> by:string -> string * string
(** [rsplit s sep] splits the string [s] between the last occurrence
    of [sep], and returns the two parts before and after the
    occurence (excluded).

    @raise Not_found if the separator is not found.

    Example: [String.rsplit "abcabcabc" "bc" = ("abcabca","")]
*)

val nsplit : string -> by:string -> string list
(** [nsplit s sep] splits the string [s] into a list of strings
    which are separated by [sep] (excluded).
    [nsplit "" _] returns the empty list.

    Example: [String.nsplit "abcabcabc" "bc" = ["a"; "a"; "a"; ""]]
*)

val join : string -> string list -> string
(** Same as {!concat} *)

val slice : ?first:int -> ?last:int -> string -> string
(** [slice ?first ?last s] returns a "slice" of the string
    which corresponds to the characters [s.[first]],
    [s.[first+1]], ..., [s[last-1]]. Note that the character at
    index [last] is {b not} included! If [first] is omitted it
    defaults to the start of the string, i.e. index 0, and if
    [last] is omitted is defaults to point just past the end of
    [s], i.e. [length s].  Thus, [slice s] is equivalent to
    [copy s].

    Negative indexes are interpreted as counting from the end of
    the string. For example, [slice ~last:(-2) s] will return the
    string [s], but without the last two characters.

    This function {b never} raises any exceptions. If the
    indexes are out of bounds they are automatically clipped.

    Example: [String.slice ~first:1 ~last:(-3) " foo bar baz" = "foo bar "]
*)

val splice: string -> int -> int -> string -> string
(** [String.splice s off len rep] cuts out the section of [s]
    indicated by [off] and [len] and replaces it by [rep]

    Negative indexes are interpreted as counting from the end
    of the string. If [off+len] is greater than [length s],
    the end of the string is used, regardless of the value of
    [len].

    If [len] is zero or negative, [rep] is inserted at position
    [off] without replacing any of [s].

    Example: [String.splice "foo bar baz" 3 5 "XXX" = "fooXXXbaz"]
*)

val explode : string -> char list
(** [explode s] returns the list of characters in the string [s].

    Example: [String.explode "foo" = ['f'; 'o'; 'o']]
*)

val implode : char list -> string
(** [implode cs] returns a string resulting from concatenating
    the characters in the list [cs].

    Example: [String.implode ['b'; 'a'; 'r'] = "bar"]
*)

(** {6 Comparisons}*)

val equal : t -> t -> bool
(** String equality *)

val ord : t -> t -> BatOrd.order
(** Ordering function for strings, see {!BatOrd} *)

val compare: t -> t -> int
(** The comparison function for strings, with the same specification as
    {!Pervasives.compare}.  Along with the type [t], this function [compare]
    allows the module [String] to be passed as argument to the functors
    {!Set.Make} and {!Map.Make}.

    Example: [String.compare "FOO" "bar" = -1] i.e. "FOO" < "bar"
*)

val icompare: t -> t -> int
(** Compare two strings, case-insensitive.

    Example: [String.icompare "FOO" "bar" = 1] i.e. "foo" > "bar"
*)

module IString : BatInterfaces.OrderedType with type t = t
(** uses icompare as ordering function

    Example: [module Nameset = Set.Make(String.IString)]
*)


val numeric_compare: t -> t -> int
(** Compare two strings, sorting "abc32def" before "abc210abc".

    Algorithm: splits both strings into lists of (strings of digits) or
    (strings of non digits) ([["abc"; "32"; "def"]] and [["abc"; "210"; "abc"]])
    Then both lists are compared lexicographically by comparing elements
    numerically when both are numbers or lexicographically in other cases.

    Example: [String.numeric_compare "xx32" "xx210" < 0]
*)

module NumString : BatInterfaces.OrderedType with type t = t
(** uses numeric_compare as its ordering function

    Example: [module FilenameSet = Set.Make(String.NumString)]
*)

val edit_distance : t -> t -> int
(** Edition distance (also known as "Levenshtein distance").
    See {{:http://en.wikipedia.org/wiki/Levenshtein_distance} wikipedia}
    @since 2.2.0
*)

(** {6 Boilerplate code}*)

(** {7 Printing}*)

val print: 'a BatInnerIO.output -> string -> unit
(**Print a string.

   Example: [String.print stdout "foo\n"]
*)

val println: 'a BatInnerIO.output -> string -> unit
(**Print a string, end the line.

   Example: [String.println stdout "foo"]
*)

val print_quoted: 'a BatInnerIO.output -> string -> unit
(**Print a string, with quotes as added by the [quote] function.

   [String.print_quoted stdout "foo"] prints ["foo"] (with the quotes).

   [String.print_quoted stdout "\"bar\""] prints ["\"bar\""] (with the quotes).

   [String.print_quoted stdout "\n"] prints ["\n"] (not the escaped
   character, but ['\'] then ['n']).
*)

(** Exceptionless counterparts for error-raising operations *)
module Exceptionless :
sig
  val to_int : string -> int option
  (** Returns the integer represented by the given string or
      [None] if the string does not represent an integer.*)

  val to_float : string -> float option
  (** Returns the float represented by the given string or
      [None] if the string does not represent a float. *)

  val index : string -> char -> int option
  (** [index s c] returns [Some p], the position of the leftmost
      occurrence of character [c] in string [s] or
      [None] if [c] does not occur in [s]. *)

  val rindex : string -> char -> int option
  (** [rindex s c] returns [Some p], the position of the rightmost
      occurrence of character [c] in string [s] or
      [None] if [c] does not occur in [s]. *)

  val index_from : string -> int -> char -> int option
  (** Same as {!String.Exceptionless.index}, but start
      searching at the character position given as second argument.
      [index s c] is equivalent to [index_from s 0 c].*)

  val rindex_from : string -> int -> char -> int option
  (** Same as {!String.Exceptionless.rindex}, but start
      searching at the character position given as second argument.
      [rindex s c] is equivalent to
      [rindex_from s (String.length s - 1) c]. *)

  val find : string -> string -> int option
  (** [find s x] returns [Some i], the starting index of the first
      occurrence of string [x] within string [s], or [None] if [x]
      is not a substring of [s].

      {b Note} This implementation is optimized for short strings. *)

  val find_from : string -> int -> string -> int option
  (** [find_from s ofs x] behaves as [find s x] but starts searching
      at offset [ofs]. [find s x] is equivalent to [find_from s 0 x].*)

  val rfind : string -> string -> int option
  (** [rfind s x] returns [Some i], the starting index of the last occurrence
      of string [x] within string [s], or [None] if [x] is not a substring
      of [s].

      {b Note} This implementation is optimized for short strings. *)

  val rfind_from: string -> int -> string -> int option
  (** [rfind_from s ofs x] behaves as [rfind s x] but starts searching
      at offset [ofs]. [rfind s x] is equivalent to
      [rfind_from s (String.length s - 1) x]. *)

  val split : string -> by:string -> (string * string) option
  (** [split s sep] splits the string [s] between the first
      occurrence of [sep], or returns [None] if the separator
      is not found. *)

  val rsplit : string -> by:string -> (string * string) option
    (** [rsplit s sep] splits the string [s] between the last
        occurrence of [sep], or returns [None] if the separator
        is not found. *)

end (* String.Exceptionless *)

(** Capabilities for strings.

    This modules provides the same set of features as {!String}, but
    with the added twist that strings can be made read-only or write-only.
    Read-only strings may then be safely shared and distributed.

    There is no loss of performance involved. *)
module Cap:
sig

  type 'a t
  (** The type of capability strings.

      If ['a] contains [[`Read]], the contents of the string may be read.
      If ['a] contains [[`Write]], the contents of the string may be written.

      Other (user-defined) capabilities may be added without loss of
      performance or features. For instance, a string could be labelled
      [[`Read | `UTF8]] to state that it contains UTF-8 encoded data and
      may be used only for reading.  Conversely, a string labelled with
      [[]] (i.e. nothing) can neither be read nor written. It can only
      be compared for textual equality using OCaml's built-in [compare]
      or for physical equality using OCaml's built-in [==].
  *)

  external length : _ t  -> int = "%string_length"

  val is_empty : _ t -> bool

  external get : [> `Read] t -> int -> char = "%string_safe_get"

  external set : [> `Write] t -> int -> char -> unit = "%string_safe_set"

  external create : int -> _ t = "caml_create_string"

  (** {6 Constructors}*)

  external of_string : string -> _ t                = "%identity"
  (**Adopt a regular string.*)

  external to_string : [`Read | `Write] t -> string = "%identity"
  (** Return a capability string as a regular string.*)

  external read_only : [> `Read] t -> [`Read] t     = "%identity"
  (** Drop capabilities to read only.*)

  external write_only: [> `Write] t -> [`Write] t   = "%identity"
  (** Drop capabilities to write only.*)

  val make : int -> char -> _ t

  val init : int -> (int -> char) -> _ t

  (** {6 Conversions}*)
  val enum : [> `Read] t -> char BatEnum.t

  val of_enum : char BatEnum.t -> _ t

  val backwards : [> `Read] t -> char BatEnum.t

  val of_backwards : char BatEnum.t -> _ t

  val of_list : char list -> _ t

  val to_list : [> `Read] t -> char list

  val of_int : int -> _ t

  val of_float : float -> _ t

  val of_char : char -> _ t

  val to_int : [> `Read] t -> int

  val to_float : [> `Read] t -> float

  (** {6 String traversals}*)

  val map : (char -> char) -> [>`Read] t -> _ t

  val fold_left : ('a -> char -> 'a) -> 'a -> [> `Read] t -> 'a

  val fold_right : (char -> 'a -> 'a) -> [> `Read] t -> 'a -> 'a

  val filter : (char -> bool) -> [> `Read] t -> _ t

  val filter_map : (char -> char option) -> [> `Read] t -> _ t


  val iter : (char -> unit) -> [> `Read] t -> unit


  (** {6 Finding}*)

  val index : [>`Read] t -> char -> int

  val rindex : [> `Read] t -> char -> int

  val index_from : [> `Read] t -> int -> char -> int

  val rindex_from : [> `Read] t -> int -> char -> int

  val contains : [> `Read] t -> char -> bool

  val contains_from : [> `Read] t -> int -> char -> bool

  val rcontains_from : [> `Read] t -> int -> char -> bool

  val find : [> `Read] t -> [> `Read] t -> int

  val find_from: [> `Read] t -> int -> [> `Read] t -> int

  val rfind : [> `Read] t -> [> `Read] t -> int

  val rfind_from: [> `Read] t -> int -> [> `Read] t -> int

  val ends_with : [> `Read] t -> [> `Read] t -> bool

  val starts_with : [> `Read] t -> [> `Read] t -> bool

  val exists : [> `Read] t -> [> `Read] t -> bool

  (** {6 Transformations}*)

  val lchop : ?n:int -> [> `Read] t -> _ t

  val rchop : ?n:int -> [> `Read] t -> _ t

  val trim : [> `Read] t -> _ t

  val quote : [> `Read] t -> string

  val left : [> `Read] t -> int -> _ t

  val right : [> `Read] t -> int -> _ t

  val head : [> `Read] t -> int -> _ t

  val tail : [> `Read] t -> int -> _ t

  val strip : ?chars:[> `Read] t -> [> `Read] t -> _ t

  val uppercase : [> `Read] t -> _ t

  val lowercase : [> `Read] t -> _ t

  val capitalize : [> `Read] t -> _ t

  val uncapitalize : [> `Read] t -> _ t

  val copy : [> `Read] t -> _ t

  val sub : [> `Read] t -> int -> int -> _ t

  val fill : [> `Write] t -> int -> int -> char -> unit

  val blit : [> `Read] t -> int -> [> `Write] t -> int -> int -> unit

  val concat : [> `Read] t -> [> `Read] t list -> _ t

  val escaped : [> `Read] t -> _ t

  val replace_chars : (char -> [> `Read] t) -> [> `Read] t -> _ t

  val replace : str:[> `Read] t -> sub:[> `Read] t -> by:[> `Read] t -> bool * _ t

  val nreplace : str:[> `Read] t -> sub:[> `Read] t -> by:[> `Read] t -> _ t

  val repeat: [> `Read] t -> int -> _ t

  (** {6 Splitting around}*)
  val split : [> `Read] t -> by:[> `Read] t -> _ t * _ t

  val rsplit : [> `Read] t -> by:string -> string * string

  val nsplit : [> `Read] t -> by:[> `Read] t -> _ t list

  val splice: [ `Read | `Write] t  -> int -> int -> [> `Read] t -> string

  val join : [> `Read] t -> [> `Read] t list -> _ t

  val slice : ?first:int -> ?last:int -> [> `Read] t -> _ t

  val explode : [> `Read] t -> char list

  val implode : char list -> _ t

  (** {6 Comparisons}*)

  val compare: [> `Read] t -> [> `Read] t -> int

  val icompare: [> `Read] t -> [> `Read] t -> int


  (** {7 Printing}*)

  val print: 'a BatInnerIO.output -> [> `Read] t -> unit

  val println: 'a BatInnerIO.output -> [> `Read] t -> unit

  val print_quoted: 'a BatInnerIO.output -> [> `Read] t -> unit

  (**/**)

  (** {6 Undocumented operations} *)
  external unsafe_get : [> `Read] t -> int -> char = "%string_unsafe_get"
  external unsafe_set : [> `Write] t -> int -> char -> unit = "%string_unsafe_set"
  external unsafe_blit :
    [> `Read] t -> int -> [> `Write] t -> int -> int -> unit = "caml_blit_string" "noalloc"
  external unsafe_fill :
    [> `Write] t -> int -> int -> char -> unit = "caml_fill_string" "noalloc"

  (**/**)

  (** Exceptionless counterparts for error-raising operations *)
  module Exceptionless :
  sig
    val to_int : [> `Read] t -> int option

    val to_float : [> `Read] t -> float option

    val index : [>`Read] t -> char -> int option

    val rindex : [> `Read] t -> char -> int option

    val index_from : [> `Read] t -> int -> char -> int option

    val rindex_from : [> `Read] t -> int -> char -> int option

    val find : [> `Read] t -> [> `Read] t -> int option

    val find_from: [> `Read] t -> int -> [> `Read] t -> int option

    val rfind : [> `Read] t -> [> `Read] t -> int option

    val rfind_from: [> `Read] t -> int -> [> `Read] t -> int option

    (* val split : string -> string -> (string * string) option TODO *)
    val split : [> `Read] t -> by:[> `Read] t -> (_ t * _ t) option

    (*   val rsplit : string -> string -> (string * string) option TODO *)
    val rsplit : [> `Read] t -> by:[> `Read] t -> (_ t * _ t) option

  end (* String.Cap.Exceptionless *)

end

(**/**)

(* The following is for system use only. Do not call directly. *)

external unsafe_get : string -> int -> char = "%string_unsafe_get"
external unsafe_set : string -> int -> char -> unit = "%string_unsafe_set"
external unsafe_blit :
  string -> int -> string -> int -> int -> unit = "caml_blit_string" "noalloc"
external unsafe_fill :
  string -> int -> int -> char -> unit = "caml_fill_string" "noalloc"

  (**/**)
