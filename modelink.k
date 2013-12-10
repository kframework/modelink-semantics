require "metamodel-syntax.k"
require "model-syntax.k"
require "configuration.k"
require "ocl-syntax.k"
require "ocl.k"
require "scenario.k"

module MODELINK-SYNTAX
  imports METAMODEL-SYNTAX
  imports MODEL-SYNTAX
  imports OCL-SYNTAX
  imports SCENARIO-SYNTAX

  syntax ModelinkSpecification ::= Metamodel Model OclConstraints Scenarios
  syntax OclConstraints ::= List{OclConstraint,""}
  syntax Scenarios ::= List{Scenario, ""}
endmodule

module LOADER
  imports MODELINK-SYNTAX
  imports CONFIGURATION

  /*@ Initial setup */
  rule <k> MM:Metamodel M:Model C:OclConstraints S:Scenarios => MM ~> M ~> C ~> S </k> [structural]

  /*@ Loading the metamodel*/
  rule <k> metamodel Name:Id { C:Classifiers } => C ...</k>
       <metamodel>...
	 <metamodelName> _ => Name </metamodelName>
       ...</metamodel> [structural]

  rule <k> .Classifiers => . ...</k> [structural]

  /*@ Load classes */
  rule <k> class Name:Id : T:Type { CI:ClassItems } C:Classifiers => CI ~> C ...</k>
       <currentClass> _ => Name </currentClass>
       <classes>...
	 . => <class>
		<className> Name </className>
		<attributes> .Map </attributes>
		<references> .Bag </references>
		<methods> .Bag </methods>
		<inherit> T </inherit>
		<classConstraints> true </classConstraints>
	      </class>
       </classes> [structural]

  rule <k> class Name:Id { CI:ClassItems } C:Classifiers => class Name : object  { CI } C ...</k>

  rule <k> attribute Name:Id : T:Type ; CI:ClassItems => CI ...</k>
       <currentClass> CName </currentClass>
       <class>...
	 <className> CName </className>
	 <attributes>... . => Name |-> T </attributes>
       ...</class> [structural]
  
  rule <k> reference Name:Id : T:Id [ Left:Int - Right:RightBound ] ; CI:ClassItems => CI ...</k>
       <currentClass> CName </currentClass>
       <class>...
	 <className> CName </className>
	 <references>...
	   . => <reference>
	     	  <referenceName> Name </referenceName>
		  <referenceType> T </referenceType>
		  <leftbound> Left </leftbound>
		  <rightbound> Right </rightbound>
	     	</reference>
	 </references>
       ...</class> [structural]

  rule <k> reference Name:Id : T:Id ; CI:ClassItems => reference Name : T [1 - 1] ; CI ...</k> [structural]

  rule <k> method T:Type : Name:Id ( P:Params ) ; CI:ClassItems => CI ... </k>
       <currentClass> CName </currentClass>
       <class>...
       	 <className> CName </className>
	 <methods>...
	   . => <method> 
	          <methodName> Name </methodName>
	          <returnType> T </returnType>
	          <params> P </params>
		  <pre> .K </pre>
		  <post> .K </post>
	        </method>
	 </methods>
       ...</class> [structural]


  /*@ Load enumerations */
  rule <k> enumeration Name:Id { E:EnumerationItems } C:Classifiers => E ~> C ...</k>
       <currentClass> _ => Name </currentClass>
       <enumerations>...
         . => <enum>
		<enumName> Name </enumName>
	      </enum>
       </enumerations> [structural]

  rule <k> E:EnumerationItem , EI:EnumerationItems => EI ...</k>
       <currentClass> Name </currentClass>
       <enum>
         <enumName> Name </enumName>
	 (Rest:Bag => Rest <item> E </item>)
       </enum> [structural]

  rule <k> .EnumerationItems => . ...</k> [structural]
  

  /*@ Loading model */
  rule <k> model MName:Id : MM:Id { I:Instances } => I ...</k>
       <modelName> _ => MName </modelName>
       <ofMetamodel> _ => MM </ofMetamodel> [structural]
  
  // Here, <currentClass> cell is used abusively: it contains an instance name not a class name     
  rule <k> instance Name:Id : ClassName:Id { F:Fields } IS:Instances => F ~> IS ...</k>
       <currentClass> _ => Name </currentClass>
       <instances>...
         . => <instance>
	        <instanceName> Name </instanceName>
		<ofClass> ClassName </ofClass>
		<fields> .Map </fields>
	      </instance>
       ...</instances> [structural]

  rule <k> F:Id = D:Data ; Fs:Fields => Fs ...</k>
       <currentClass> IName </currentClass>
       <instance>...
	 <instanceName> IName </instanceName>
	 <fields>... . => F |-> D </fields>
       ...</instance> [structural]
  rule <k> .Fields => . ...</k>
 
endmodule

module MODELINK
  imports LOADER
  imports OCL
  imports SCENARIO 

  rule <k> C:OclConstraint Rest:OclConstraints => C ~> Rest ...</k> [structural]
  rule <k> S:Scenario Ss:Scenarios => S ~> restoreInstances ~> Ss ...</k> [structural]
endmodule