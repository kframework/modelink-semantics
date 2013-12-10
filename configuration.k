module CONFIGURATION
  configuration <T>
		  <k> $PGM:K </k>
		  <currentClass> .K </currentClass>
		  <currentInstances> .List </currentInstances>
		  <currentInstance> .Bag </currentInstance>
		  <currentConstraint> .K </currentConstraint>
		  <br/>
		  <failures> .Map </failures>
	          <env> .Map </env> 
		  <stack> .List </stack>
		  <condition> true </condition>
		  <scenarios> .Map </scenarios>
		  <currentScenario> .K </currentScenario>
		  <br/>
		  <metamodel>
		    <metamodelName> "" </metamodelName>
		    <enumerations>
		      <enum multiplicity="*" color="black">
		      	<enumName> "" </enumName>
			<item multiplicity="*"> .K </item>
		      </enum>
		    </enumerations> <br/>
		    <classes>
		      <class multiplicity="*" color="red">
		        <className> "" </className>
		        <attributes color="green"> .Map </attributes>
			<classConstraints> .K </classConstraints>
			<inherit color="cyan"> .K </inherit>
			<br/>
		        <references color="brown">
			  <reference multiplicity="*">
			    <referenceName> "" </referenceName>
			    <referenceType> .K </referenceType>
			    <br/>
			    <leftbound> .K </leftbound>
			    <rightbound> .K </rightbound>
			  </reference>
			</references><br/>
		        <methods color="yellow">
			  <method multiplicity="*" color="blue">
			    <methodName> .K </methodName>
			    <returnType> .K </returnType>
			    <params> .K </params>
			    <pre> .K </pre>
			    <post> .K </post>
			  </method>
		        </methods>
		      </class>
		    </classes>
		  </metamodel> <br/>
		  <model> 
		    <modelName> .K </modelName>
		    <ofMetamodel> .K </ofMetamodel>
		    <br/>
		    <instances>
		      <instance multiplicity="*">
		        <instanceName> .K </instanceName>
		        <ofClass> .K </ofClass>
		        <fields> .Map </fields>
		      </instance>
		    </instances>
		  </model>
		</T>
endmodule