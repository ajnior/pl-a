(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for problem 1 here *)

(* Write a function all_except_option, which takes a string and a string list. Return NONE if the string is not in the list, else return SOME lst where lst is identical to the argument list except the string is not in it. You may assume the string is in the list at most once. Use same_string, provided to you, to compare strings. Sample solution is around 8 lines. *)

fun all_except_option(str, strs) =
   case strs of
      [] => NONE
      | x::xs => case same_string(x, str) of
                     true => SOME xs
                     | false => case all_except_option(str, xs) of
                                 NONE => NONE
                                 | SOME y => SOME (x::y);

(* Write a function get_substitutions1, which takes a string list list (a list of list of strings, the substitutions) and a string s and returns a string list. The result has all the strings that are in some list in substitutions that also has s, but s itself should not be in the result.
Example: get_substitutions1([["Fred","Fredrick"],["Elizabeth","Betty"],["Freddie","Fred","F"]], "Fred") *)
(* answer: ["Fredrick","Freddie","F"] *)

fun get_substitutions1(losl: string list list, s: string) =
   case losl of
      [] => []
      | x::xs => case all_except_option(s, x) of
                     SOME y => y @ get_substitutions1(xs ,s)
                     | NONE => get_substitutions1(xs ,s)

(* Write a function get_substitutions2, which is like get_substitutions1 except it uses a tail-recursive local helper function. *)
fun get_substitutions2(losl: string list list, s: string) =
   let fun aux(lst, acc) =
            case lst of
               [] => acc
               | x::xs => case all_except_option(s, x) of
                  NONE => aux(xs, acc)
                  | SOME y => aux(xs, acc @ y)
   in
      aux(losl,[])
   end

(* Write a function similar_names, which takes a string list list of substitutions (as in parts (b) and (c)) and a full name of type {first:string,middle:string,last:string} and returns a list of full names (type {first:string,middle:string,last:string} list). The result is all the full names you can produce by substituting for the first name (and only the first name) using substitutions and parts (b) or (c). The answer should begin with the original name (then have 0 or more other names). *)
(* Example:
similar_names([["Fred","Fredrick"],["Elizabeth","Betty"],["Freddie","Fred","F"]], {first="Fred", middle="W", last="Smith"}) *)
(* answer: [{first="Fred", last="Smith", middle="W"},
                 {first="Fredrick", last="Smith", middle="W"},
                 {first="Freddie", last="Smith", middle="W"},
                 {first="F", last="Smith", middle="W"}] *)

fun similar_names(losl: string list list, {first:string, middle:string, last:string}) =
   let 
      fun genFullNames(lon) = 
         case lon of
            [] => []
            | x::xs => {first = x, middle = middle, last = last } :: genFullNames(xs)
   in
      case get_substitutions2(losl, first) of
         [] => [{first = first, middle = middle, last = last }]
         | lon => [{first = first, middle = middle, last = last }] @ genFullNames(lon)
   end


(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

(* put your solutions for problem 2 here *)

(* Write a function card_color, which takes a card and returns its color (spades and clubs are black, diamonds and hearts are red). Note: One case-expression is enough. *)
fun card_color(suit, _) =
   case suit of
      Spades => Black
      | Clubs => Black
      | Diamonds => Red
      | Hearts => Red

(* Write a function card_value, which takes a card and returns its value (numbered cards have their number as the value, aces are 11, everything else is 10). Note: One case-expression is enough. *)

fun card_value(_, rank) =
   case rank of 
      Num value => value
      | Ace => 11
      | _ => 10