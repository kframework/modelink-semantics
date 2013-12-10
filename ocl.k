require "ocl-syntax.k"
require "metamodel-syntax.k"
require "model-syntax.k"
require "configuration.k"
require "modules/substitution.k"

module OCL
  imports OCL-SYNTAX
  imports METAMODEL-SYNTAX
  imports CONFIGURATION
  imports MODEL-SYNTAX
  imports SUBSTITUTION

  //@ Results
  syntax KResult ::= Boolean | Integer | Real | String | Collection
  rule isKResult(self) => true  

  //@ Setup the current context: set class name, update current instances and clean
  rule <k> (context ClassName:Id P:Properties => P ~> done) ...</k>
       <currentClass> _ => ClassName </currentClass>
       <currentInstances> _ => collectAllInstances(ClassName, B, Cls) </currentInstances>
       <instances> B:Bag </instances>
       <classes> Cls:Bag </classes>
       <currentInstance> _ => .Bag </currentInstance>

  rule <k> (context ClassName:Id :: Method:Id ( _ ) P:Properties => Method ~> P ~> done) ...</k>
       <currentClass> _ => ClassName </currentClass>


  syntax K ::= "stop" | "done"

  //@ Duplicate properties for every instance to be checked. Iterate through all instances.
  rule <k> Ps:Properties => Ps ~> stop ~> Ps ...</k>
       <currentInstances> ListItem(Inst:Id) Rest:List => Rest </currentInstances>
       <instance> <instanceName> Inst </instanceName> I:Bag </instance>
       <currentInstance> .Bag => <instance> <instanceName> Inst </instanceName> I </instance> </currentInstance>
       
  //@ Iterate through each constraint.
  rule <k> P:Property Ps:Properties => P ~> Ps ...</k>
       <currentInstance>... _:BagItem ...</currentInstance>
       <currentConstraint> _ => P </currentConstraint>

  //@ Whenever a set of contraints has been verified on an instance, repeat the process for the other instances.
  rule <k> stop => . ...</k>
       <currentConstraint> . </currentConstraint>
       <currentInstance> _:BagItem => . </currentInstance>

  //@ Finishing. Reset the context.
  rule <k> Ps:Properties ~> done => . ...</k>
       <currentInstances> .List </currentInstances>
       <currentClass> _ => . </currentClass>

  //@ Class invariants
  rule <k> inv: true => . ...</k>
       <currentConstraint> _ => . </currentConstraint>
 
  rule <k> inv: false ~> Ps:Properties ~> stop => stop ...</k>
       <currentInstance> <instance> <instanceName> Inst </instanceName> I:Bag </instance> </currentInstance>
       <failures>... . => Inst |-> P </failures>
       <currentConstraint> P:Property => . </currentConstraint>
       <stack> . </stack>

  //@ Lookup: special case for `self`
  rule <k> self . F:Id => F ...</k>
  //@ Lookup
  rule <k> X:Id => V ...</k>
       <currentInstance>
       <instance>...
	 <fields>... X |-> V:Data ...</fields>
       ...</instance>
       </currentInstance>

  //@ Transform Datas in Collection
  syntax Exps ::= Datas
  rule <k> { Ds:Datas } => Collection { Ds } ...</k>

  //@ Basic arithmetics
  rule - I:Int => 0 -Int I [anywhere]
  rule I1:Int + I2:Int => I1 +Int I2 [anywhere]
  rule I1:Int - I2:Int => I1 -Int I2 [anywhere]                                    
  rule I1:Int * I2:Int => I1 *Int I2 [anywhere]
  rule I1:Int / I2:Int => I1 /Int I2 [anywhere]

  //@ Comparisons
  rule I1:Int >= I2:Int => I1 >=Int I2 [anywhere]
  rule I1:Int >  I2:Int => I1 >Int  I2 [anywhere]
  rule I1:Int <= I2:Int => I1 <=Int I2 [anywhere]
  rule I1:Int <  I2:Int => I1 <Int  I2 [anywhere]
  rule I1:Int =  I2:Int => I1 ==Int I2 [anywhere]
  rule I1:Int <> I2:Int => I1 ==Int I2 [anywhere]

  //@ Boolean operations
  rule true and B:Bool => B [anywhere]
  rule false and _ => false [anywhere]

  rule true  or _      => true [anywhere]
  rule false or B:Bool => B    [anywhere]

  rule not true => false [anywhere]
  rule not false => true [anywhere]

  rule true implies B:Bool => B [anywhere]
  rule false implies _ => true  [anywhere]

  rule B1:Bool xor B2:Bool => B1 xorBool B2 [anywhere]

  rule if true  then E:Exp else _     endif => E [anywhere]
  rule if false then _     else E:Exp endif => E [anywhere]

  rule B1:Bool = B2:Bool => B1 ==Bool B2 [anywhere]
  rule B1:Bool <> B2:Bool => B1 ==Bool B2 [anywhere]

  //@ Let expressions
  // Substitution fails here. Probably a tool error.

  syntax  Exp ::= Exp "myIn" Exp  [strict(1)]
  syntax  Exp     ::= "myLet" Id "point" Exp  [binder, strict(2)]

  rule isKResult(V:KResult myIn E2:Exp) => true [anywhere]

  rule let X:Id = V:Exp in E:Exp => myLet X point (V myIn E) [anywhere]
  rule <k> myLet X:Id point (V:KResult myIn E:Exp) => E[V / X] ...</k> 

  //@ Collections size
  rule C:CollectionType { E:Exp, Es:Exps } -> size() => 1 + (C { Es } -> size())
  rule C:CollectionType { .Exps } -> size() => 0

  //@ Particular case for collect.
  rule self->collect(X:Exp) => self . X [structural]

  /*@ Iterate\\
    Base case: the iterator does not appear in the expression to be evaluated.
    For each iteration, save the data in the environment, evaluate expression, continue the iteration such that the result includes the previous evaluation
  */ 
  syntax Exp ::= Data
  syntax K ::= "restore" "(" Exps "," Id "," Id "," Exp ")" [function]
  rule <k> C:CollectionType { E:Exp, Es:Exps } -> iterate(X:Id ; Y:Id : V:Data | E':Exp ) =>
           (X : E) ~> (Y : V) ~> E' ~> restore(Es, X, Y, E') ...</k>
       <env> _ => . </env>
  rule <k> C:CollectionType { .Exps } -> iterate(X:Id ; Y:Id : V:Data | E':Exp ) => V ...</k>
       <env> _ => . </env>

  rule <k> X:Id : E:Exp => . ...</k>
       <env>... . => X |-> E </env>
       
  rule <k> X:Id => V ...</k>
       <env>... X |-> V:Exp ...</env> 
  
  syntax Exp ::= BuiltinSort
  syntax BuiltinSort ::= Int | Bool | String
  rule <k> E:BuiltinSort ~> restore(Es:Exps, X:Id, Y:Id, E':Exp) => Collection { Es } -> iterate(X; Y : E | E') ...</k>
       <env> _ => . </env>
       <stack> . </stack>
  /*@
    Case: the iterator is part of the expression.
    Whenever an instance must be evaluated, set it as being the current instance and save the old instance into a stack.
  */
  syntax ListItem ::= "StackItem" "(" K "," Bag "," List ")"
  rule <k> Inst:Id => self ...</k>
       <instances>...
         <instance>
	   <instanceName> Inst </instanceName>
	   <ofClass> C </ofClass>
	   Rest:Bag
         </instance>
       ...</instances>
       <currentClass> Cls => C </currentClass>
       <currentInstances> All:List => ListItem(Inst) </currentInstances>
       <currentInstance> CI:Bag => <instance> <instanceName> Inst </instanceName> 
       			 	   <ofClass> C </ofClass> Rest </instance> </currentInstance>
       <stack>... . => StackItem(Cls, CI, All)</stack>

  rule <k> E:BuiltinSort ~> restore(Es:Exps, X:Id, Y:Id, E':Exp) => Collection { Es } -> iterate(X; Y : E | E') ...</k>
       <env> _ => . </env>
       <currentInstances> _ => All </currentInstances>
       <currentInstance> _ => CI </currentInstance>
       <currentClass> _ => Cls </currentClass>
       <stack>... StackItem(Cls, CI:Bag, All:List) => . </stack>

  //@ forAll
  rule <k> C:Collection->forAll(X:Id | E:Exp) => C->iterate(X; Y : true | Y and E) ...</k> when fresh(Y:Id)

  //@ exists
  rule <k> C:Collection->exists(X:Id | E:Exp) => C->iterate(X; Y : false | Y or E) ...</k> when fresh(Y:Id)


  //@ Collect method constraints: pre and post conditions
  rule <k> (Method:Id ~> (pre: E:Exp) Ps:Properties) => Method ~> Ps ...</k>
       <currentClass> ClassName </currentClass>
       <class>...
         <className> ClassName </className>
	 <method>...
	   <methodName> Method </methodName>
	   <pre> _ => E </pre>
	 ...</method>
       ...</class>
  rule <k> (Method:Id ~> (post: E:Exp) Ps:Properties) => Method ~> Ps ...</k>
       <currentClass> ClassName </currentClass>
       <class>...
         <className> ClassName </className>
	 <method>...
	   <methodName> Method </methodName>
	   <post> _ => E </post>
	 ...</method>
       ...</class>
  rule <k> (_:Id ~> .Properties ~> done) => . ...</k>
       <currentClass> _ => . </currentClass>

  //@ Return: the list of all instances of a class.
  syntax List ::= "collectAllInstances" "(" Id "," Bag "," Bag ")" [function]  
  //@ Base case
  rule collectAllInstances(CName:Id, 
       	 (<instance> 
	   <instanceName> IName:Id </instanceName>
	   <ofClass> CName:Id </ofClass>
	   _
	 </instance>
	 Rest:Bag), Cls:Bag) => ListItem(IName) collectAllInstances(CName, Rest, Cls) 
  //@ Inheritance case
  rule collectAllInstances(CName:Id, 
       	 (<instance> 
	   <instanceName> IName:Id </instanceName>
	   <ofClass> C:Id </ofClass>
	   _
	 </instance>
	 Rest:Bag), Cls:Bag) => ListItem(IName) collectAllInstances(CName, Rest, Cls) when inherits(C, CName, Cls) 
  rule collectAllInstances(CName:Id, 
       	 (<instance> 
	   <instanceName> IName:Id </instanceName>
	   <ofClass> C:Id </ofClass>
	   _
	 </instance>
	 Rest:Bag), Cls:Bag) => collectAllInstances(CName, Rest, Cls)
  when notBool(inherits(C, CName, Cls))
  rule collectAllInstances(_, .Bag, _) => .List

  // Return: true if \$1 inherits \$2 in Bag
  syntax Bool ::= "inherits" "(" Id "," Id "," Bag ")" [function]
  rule inherits(C:Id, P:Id, <class> <className> C </className> <inherit> P </inherit> _ </class> Rest:Bag) => true
  rule inherits(C:Id, P:Id, <class> <className> C </className> <inherit> C':Id </inherit> _ </class> Rest:Bag) => inherits(C', P, Rest)
  rule inherits(C:Id, P:Id, <class> <className> C </className> <inherit> object </inherit> _ </class> Rest:Bag) => false

endmodule
