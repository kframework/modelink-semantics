require "ocl-syntax.k"
module METAMODEL-SYNTAX

  /*@ Metamodel */
  syntax Metamodel   ::= "metamodel" Id "{" Classifiers "}"
  syntax Classifiers ::= List{Classifier, ""}
  syntax Classifier  ::= Class | Enumeration
  
  /*@ Classes */
  syntax Class      ::= "class" Id "{" ClassItems "}" 
  	 	      | "class" Id ":" Type "{" ClassItems "}" 
  syntax ClassItems ::= List{ClassItem, ""}
  syntax ClassItem  ::= "attribute" Id ":" Type ";"
  	 	      | "reference" Id ":" Id ";"
		      | "reference" Id ":" Id "[" Int "-" RightBound "]" ";"
		      | "method"  Type ":" Id "(" Params ")" ";"

  syntax Params ::= List{Type,","}
  syntax RightBound ::= Int | "*"

  /*@ Enumerations syntax */
  syntax Enumeration      ::= "enumeration" Id "{" EnumerationItems "}"
  syntax EnumerationItems ::= List{EnumerationItem, ","}
  syntax EnumerationItem  ::= Id

  /*@ Types */
  syntax Type ::= "int" | "bool" | "string" | "object" | "collection" | Id

endmodule