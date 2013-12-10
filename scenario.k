require "common.k"
require "configuration.k"
require "ocl.k"

module SCENARIO-SYNTAX
  imports COMMON
  
  syntax Scenario ::= "scenario" Id "{" Stmts "}"
  syntax Stmts ::= List{Stmt, ""}
  
  syntax Stmt ::= Id "." Id "(" Ids ")" ";"

endmodule

module SCENARIO
  imports SCENARIO-SYNTAX
  imports CONFIGURATION
  imports OCL

  syntax ListItem ::= "restoreInstances" "(" Bag ")"
  syntax K ::= "restoreCurrentInstance" | "restoreInstances"

  //@ Execute scenario: set scenario name, store instances s.t. they can be restored for other scenarios
  rule <k> scenario Name:Id { S:Stmts } => S ...</k>
       <currentScenario> _ => Name </currentScenario>
       <instances> Inst:Bag </instances>
       <stack> _ => restoreInstances(Inst) </stack>

  //@ Unroll each scenario statement
  rule <k> S:Stmt Sts:Stmts => S ~> Sts ...</k> [structural]

  //@ Method calls: process pre and post conditions 
  rule <k> Inst:Id . Method:Id ( _ ) ; => processPre(Pre, Inst) ~> processPost(Post, Inst) ~> restoreCurrentInstance  ...</k>
       <instance>
	 <instanceName> Inst </instanceName>
	 <ofClass> Cls </ofClass>
       ...</instance>
       <classes>
         <class>
	   <className> C </className>
	   <methods>
	   <method>
	     <methodName> Method </methodName>
	     <pre> Pre:K </pre>
	     <post> Post:K </post> 
	     M:Bag
	   </method>
           MR:Bag 
           </methods> 
           CR:Bag 
         </class> Rest:Bag 
       </classes>
 when inherits(Cls, C , 
      	 <class>
	   <className> C </className>
	   <methods>
	   <method>
	     <methodName> Method </methodName>
	     <pre> Pre </pre>
	     <post> Post </post> 
	     M
	   </method>
           MR 
           </methods> 
           CR 
         </class> Rest)

  syntax K ::= "processPre"  "(" Exp "," Id ")"
  	     | "processPost" "(" Exp "," Id ")"

  //@ Process pre-condition: set the current instance and evaluate the precondition
  rule <k> processPre(E:Exp, Inst:Id) => E ...</k>
       <instance>
         <instanceName> Inst </instanceName>
	 Rest:Bag
       </instance>
       <currentInstance> .Bag => <instance> <instanceName> Inst </instanceName> Rest </instance> </currentInstance>

  /*@ After the evaluation of the precondition collect it in the condition cell 
     and mark all the fields of the current instance as being @pre
  */
  rule <k> B:Bool ~> processPost(E:Exp, _:Id) => E ...</k>
       <condition> C:Bool => C andBool B </condition>
       <currentInstance> <instance>... <fields> F:Map => updateAtPre(F) </fields> ...</instance> </currentInstance>

  //@ Update path condition and restore the current fields.
  rule <k> B:Bool ~> restoreCurrentInstance => . ...</k>
       <condition> C:Bool => C andBool B </condition>
       <currentInstance>
	 (<instance> <instanceName> IName </instanceName> Rest </instance>) => .
       </currentInstance>
       <instances> 
       ( <instance> <instanceName> IName </instanceName> ...</instance> =>
	 <instance> <instanceName> IName </instanceName> Rest </instance> )
       ...</instances>

     
  //@ Rules for handling the results after executing scenario  
  syntax K ::= "scenarioResult" "(" Bool "," String ")"
  rule <k> restoreInstances => . ...</k>
       <stack> restoreInstances(Inst:Bag) => . </stack>
       <instances> _ => Inst </instances>
       <currentScenario> Name:Id => . </currentScenario>
       <condition> PC:Bool => true </condition>
       <scenarios>... . =>  Name |-> scenarioResult(PC, checkSat(PC)) </scenarios>

  // Blindly add @pre for each field in map. 
  // Notes:
  // 1. this can generate "X@pre@pre..."
  // 2. for now, only integers and boolean expressions are allowed in pre/post conditions
  syntax Map ::= "updateAtPre" "(" Map ")" [function]
  rule updateAtPre(X:Id |-> V:Int  M:Map) => X |-> V' String2Id(Id2String(X) +String "@pre") |-> V updateAtPre(M) when fresh(V':Int) [structural]
  rule updateAtPre(X:Id |-> V:Bool  M:Map) => X |-> V' String2Id(Id2String(X) +String "@pre") |-> V updateAtPre(M) when fresh(V':Bool) [structural]
  // Tool limitation: only Booleans and integers can be symbolic.
  rule updateAtPre(X:Id |-> V:Id  M:Map) => X |-> V String2Id(Id2String(X) +String "@pre") |-> V updateAtPre(M)
  rule updateAtPre(X:Id |-> V:Coll  M:Map) => X |-> V String2Id(Id2String(X) +String "@pre") |-> V updateAtPre(M)
  rule updateAtPre(X:Id |-> V:String  M:Map) => X |-> V String2Id(Id2String(X) +String "@pre") |-> V updateAtPre(M)

  rule updateAtPre(.) => .

endmodule