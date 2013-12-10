require "common.k"

module OCL-SYNTAX 
  imports COMMON

  syntax OclConstraint ::= "context" Id Properties
  	 	       	 | "context" Id "::" Id "(" Ids ")" Properties

  syntax Properties ::= List{Property,""}
  syntax Property ::= "inv"  ":" Exp [strict]
  	 	    | "pre"  ":" Exp
		    | "post" ":" Exp

  syntax Exp ::= "self" | "result"
  	       | Id | Integer | Real | Boolean | String
	       | EnumerationValue
	       | Collection
  	       | "(" Exp ")" [bracket]
	       | "if" Exp "then" Exp "else" Exp "endif" [strict(1)]
	       | Exp ":" Exp 
	       > "let" Id "=" Exp "in" Exp
	       > Id "@pre"
	       > Exp "." Exp [strict(1)]
// Collections
	       > Exp "in" Exp [strict]
               | Exp "->" "iterate" "(" Id ";" Exp "|" Exp ")" [strict(1)]
               | Exp "->" "forAll" "(" Id "|" Exp ")" [strict(1)]
               | Exp "->" "exists" "(" Id "|" Exp ")" [strict(1)]
	       | Exp "->" "collect" "(" Exp ")" [strict(1)]
	       | Exp "->" "size" "(" ")" [strict]
	       > Exp "->" Exp [strict(1)]
	       > Exp "(" Exps ")"
	       > left:
	         "not" Exp
	       | "-" Exp
// Arithmetic
	       > left:
	         Exp "*" Exp [strict, left]
	       | Exp "/" Exp [strict, left]
	       > left: 
	         Exp "+" Exp [strict, left]
	       | Exp "-" Exp [strict, left]
	       > left:
// Relational
	         Exp "<"  Exp [strict]
	       | Exp "<=" Exp [strict]
	       | Exp ">"  Exp [strict]
	       | Exp ">=" Exp [strict]
	       > left:
	         Exp "<>" Exp [strict]
	       | Exp "="  Exp [strict]
// Boolean
	       > Exp "and" Exp [strict]
	       > Exp "or" Exp [strict]
	       > Exp "xor" Exp [strict]
	       > Exp "implies" Exp [strict]

  syntax Exps ::= List{Exp,","}
  
  /*@ Enumeration field access */
  syntax EnumerationValue ::= Id "::" Id

  /*@ Refer object method */
  syntax MethodReference ::= Id "::" Id "(" ")"

  /*@ OCL types */
  syntax Integer ::= Int
  syntax Real ::= Float
  syntax Boolean ::= Bool
  // String
  // UnlimitedNatural
  
  /*@ Collections */
  syntax Collection ::= CollectionType "{" Exps "}"
  syntax CollectionType ::= "Set" | "Bag" | "Sequence" | "OrderedSet" | "Collection"

  // symbolic stuff
  syntax Int  ::= "#symInt"  "(" Id ")" [onlyLabel, klabel(#symInt) ]
  syntax Bool ::= "#symBool" "(" Id ")" [onlyLabel, klabel(#symBool)]
endmodule
