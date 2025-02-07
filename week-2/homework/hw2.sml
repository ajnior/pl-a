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

(* Write a function remove_card, which takes a list of cards cs, a card c, and an exception e. It returns a list that has all the elements of cs except c. If c is in the list more than once, remove only the first one. If c is not in the list, raise the exception e. You can compare cards with = *)

fun remove_card(cs, c, e) =
   case cs of
      [] => raise e
      | x::xs => case (x = c) of
            false => x :: remove_card(xs, c, e)
            | true => xs

(* Write a function all_same_color, which takes a list of cards and returns true if all the cards in the list are the same color. Hint: An elegant solution is very similar to one of the functions using nested pattern-matching in the lectures. *)

fun all_same_color(cs) =
   case cs of
      [] => true
      | x::[] => true
      | x::y::tl => case (card_color(x) = card_color(y)) of 
                     false => false 
                     | true => all_same_color(tl)


(* Write a function sum_cards, which takes a list of cards and returns the sum of their values. Use a locally defined helper function that is tail recursive. (Take “calls use a constant amount of stack space” as a requirement for this problem.) *)

fun sum_cards(cs) =
   let 
      fun aux(cs, sum) =
         case cs of 
            [] => sum
            | c::xs => aux(xs, card_value(c) + sum)
   in
      aux(cs, 0)
   end



(* Write a function score, which takes a card list (the held-cards) and an int (the goal) and computes the score as described above. *)

(* The objective is to end the game with a low score (0 is best). Scoring works as follows: Let sum be the sum of the values of the held-cards. If sum is greater than goal, the preliminary score is three times (sum−goal), else the preliminary score is (goal − sum). The score is the preliminary score unless all the held-cards are the same color, in which case the score is the preliminary score divided by 2 (and rounded down as usual with integer division; use ML’s div operator). *)

fun score(cs, goal) =
   let 
      val sum = sum_cards(cs)
      fun calc_preliminary_score(sum, goal) =
         case (sum > goal) of
            true => 3 * (sum - goal)
            | false => (goal - sum)
   in
      case all_same_color(cs) of
         true => calc_preliminary_score(sum, goal) div 2
         | false => calc_preliminary_score(sum, goal)
   end

(* Write a function officiate, which “runs a game.” It takes a card list (the card-list) a move list (what the player “does” at each point), and an int (the goal) and returns the score at the end of the game after processing (some or all of) the moves in the move list in order. Use a locally defined recursive helper function that takes several arguments that together represent the current state of the game. As described above: *)

(* The game starts with the held-cards being the empty list. *)

(* The game ends if there are no more moves. (The player chose to stop since the move list is empty.) *)

(* If the player discards some card c, play continues (i.e., make a recursive call) with the held-cards not having c and the card-list unchanged. If c is not in the held-cards, raise the IllegalMove exception. *)

(* If the player draws and the card-list is (already) empty, the game is over. Else if drawing causes the sum of the held-cards to exceed the goal, the game is over (after drawing). Else play continues with a larger held-cards and a smaller card-list. *)

fun officiate (cs, ms, goal) =
  let fun process_moves(cs, ms, held) =
      case ms of
        [] => held
        | m::ms_tail => case m of
                          Discard card => process_moves(cs, ms_tail, remove_card(held, card, IllegalMove))
                          | Draw => case cs of
                                      [] => held
                                      | c::_ => case sum_cards(c::held) > goal of
                                                  true => c::held
                                                  | false => process_moves(remove_card(cs, c, IllegalMove), ms_tail, c::held)                                             
  in
    score(process_moves(cs, ms, []), goal) 
  end
