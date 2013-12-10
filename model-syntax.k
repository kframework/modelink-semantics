module MODEL-SYNTAX
  syntax Model ::= "model" Id ":" Id "{" Instances "}"

  syntax Instances ::= List{Instance,""}

  syntax Instance ::= "instance" Id ":" Id "{" Fields "}"
  syntax Fields ::= List{Field,""}
  syntax Field ::= Id "=" Data ";"
  
  syntax Data ::= Int | String | Id | Bool | Coll
  syntax Coll ::= "{" Datas "}"
  syntax Datas ::= List{Data,","}
endmodule