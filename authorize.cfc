<cfcomponent>
	<cfset variables.loginID = "86Q6ARYRVdtS">
	<cfset variables.transactionKey = "32Tjn5LeM5qm383f">
	<cfset variables.gatewayURL = "">
	<cfset variables.funcAPIName = "">
	<cfset variables.validationMode = "testMode">

	<cffunction name="init" output="no">
		<cfargument name="mode">
		<cfswitch expression="#arguments.mode#">
			<cfcase value="LIVE">
				<cfset variables.gatewayURL = "https://api.authorize.net/xml/v1/request.api">
				<cfset variables.validationMode = "liveMode">
			</cfcase>
			<cfcase value="TEST">
				<cfset variables.gatewayURL = "https://apitest.authorize.net/xml/v1/request.api">
				<cfset variables.validationMode = "testMode">
			</cfcase>
			<cfdefaultcase>
				<cfthrow  message = "You must specify either LIVE or TEST in the init() method.">
			</cfdefaultcase>
		</cfswitch>
		<cfreturn this>
	</cffunction>

	<cffunction name="createCustomerProfileRequest" access="public" output="false">
		<cfargument name="id" default="1231">
		<cfargument name="email" default="raheem@creationnext.com">
		<cfargument name="description" default="">
		<cfargument name="customerType" default="individual">
		<cfargument name="cardNumber" default="4111111111111111">
		<cfargument name="expirationDate" default="2020-12">
		<cfargument name="cardCode" default="999">
		<cfargument name="firstName" default="Jhon">
		<cfargument name="lastName" default="Doe">
		<cfargument name="company" default="XYZ Company">
		<cfargument name="address" default="my Address">
		<cfargument name="city" default="New York">
		<cfargument name="zip" default="00501">
		<cfargument name="state" default="New York">
		<cfargument name="country" default="United States">
		<cfargument name="phoneNumber" default="+123 223 9998">
		<cfargument name="faxNumber" default="">

		<cfset var xmlReq = "">
		<cfset var profileId = 0>
		<cfset var response = "">
		<cfset user = arguments>
		
		<cfoutput> 	
			<cfsavecontent variable="xmlChunk">
			   <profile>
			     <merchantCustomerId>#user.id#</merchantCustomerId>
			     <description>#user.description#</description>
			     <email>#user.email#</email>
			     <paymentProfiles>
			       <customerType>#user.customerType#</customerType>
			        <payment>
			          <creditCard>
			            <cardNumber>#user.cardNumber#</cardNumber>
			            <expirationDate>#user.expirationDate#</expirationDate>
			            <cardCode>#user.cardCode#</cardCode>
			          </creditCard>
			         </payment>
			      </paymentProfiles>
			      <shipToList>
				    	<firstName>#user.firstName#</firstName>
				    	<lastName>#user.lastName#</lastName>
				    	<company>#user.company#</company>
				    	<address>#user.address#</address>
				    	<city>#user.city#</city>
				    	<state>#user.state#</state>
				    	<zip>#user.zip#</zip>
				    	<country>#user.country#</country>
				    	<phoneNumber>#user.phoneNumber#</phoneNumber>
				    	<faxNumber>#user.faxNumber#</faxNumber>
				  </shipToList>
			    </profile>
			</cfsavecontent>
		</cfoutput>

		<cfset xmlString = buildXML("createCustomerProfileRequest", xmlChunk)>

		<cfset Result = execute(xmlString)>

		<cfreturn Result>

	</cffunction>

	<cffunction name="execute">
		<cfargument name="functionXMLPacket">
	
		<cfset var ret = structNew()>

		<cfhttp method="post" url="#variables.gatewayURL#">
		<cfhttpparam type="XML" value="#arguments.functionXMLPacket.Trim()#" />
		</cfhttp>
		
		<cfif Left(cfhttp.statusCode,3) EQ "200">
			<cfset response = XMLParse(cfhttp.filecontent)>
			<cfreturn ConvertXmlToStruct(ToString(response), structnew())>
		<cfelse>

			<cfreturn cfhttp>			

		</cfif>

		

	</cffunction>


	<cffunction name="buildXML">
		<cfargument name="funcAPIName">
		<cfargument name="xmlPacket">

		<cfset xmlString = '<?xml version="1.0" encoding="utf-8"?>
		<[FUNCAPI] xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">  
	    <merchantAuthentication><name>[LOGINID]</name>
	    <transactionKey>[TRANSACTIONKEY]</transactionKey>
	    </merchantAuthentication>[INTERNALBODY]<validationMode>[VALIDATIONMODE]</validationMode></[FUNCAPI]>'>

	    <cfset xmlString =  ReplaceNoCase(xmlString, "[LOGINID]", variables.loginID, "all")>
	    <cfset xmlString =  ReplaceNoCase(xmlString, "[TRANSACTIONKEY]", variables.transactionKey, "all")>
	    <cfset xmlString =  ReplaceNoCase(xmlString, "[FUNCAPI]", arguments.funcAPIName, "all")>
	    <cfset xmlString =  ReplaceNoCase(xmlString, "[VALIDATIONMODE]", variables.validationMode, "all")>
		<cfset xmlString =  ReplaceNoCase(xmlString, "[INTERNALBODY]", arguments.xmlPacket, "all")>
	  		
		<cfreturn xmlString>
	</cffunction>


	<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="false"
					hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
		<cfargument name="xmlNode" type="string" required="true" />
		<cfargument name="str" type="struct" required="true" />
		<!---Setup local variables for recurse: --->
		<cfset var i = 0 />
		<cfset var axml = arguments.xmlNode />
		<cfset var astr = arguments.str />
		<cfset var n = "" />
		<cfset var tmpContainer = "" />
		
		<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
		<cfset axml = axml[1] />
		<!--- For each children of context node: --->
		<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
			<!--- Read XML node name without namespace: --->
			<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
			<!--- If key with that name exists within output struct ... --->
			<cfif structKeyExists(astr, n)>
				<!--- ... and is not an array... --->
				<cfif not isArray(astr[n])>
					<!--- ... get this item into temp variable, ... --->
					<cfset tmpContainer = astr[n] />
					<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
					<cfset astr[n] = arrayNew(1) />
					<!--- ... and reassing temp item as a first element of new array: --->
					<cfset astr[n][1] = tmpContainer />
				<cfelse>
					<!--- Item is already an array: --->
					
				</cfif>
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
						<!--- recurse call: get complex item: --->
						<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
					<cfelse>
						<!--- else: assign node value as last element of array: --->
						<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
				</cfif>
			<cfelse>
				<!---
					This is not a struct. This may be first tag with some name.
					This may also be one and only tag with this name.
				--->
				<!---
						If context child node has child nodes (which means it will be complex type): --->
				<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<!--- if there are any attributes on this element--->
					<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
						<!--- assign the text --->
						<cfset astr[n] = axml.XmlChildren[i].XmlText />
							<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
						 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
						 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
							 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
								 <!--- remove any namespace attributes--->
								<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
							 </cfif>
						 </cfloop>
						 <!--- if there are any atributes left, append them to the response--->
						 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
							 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
						</cfif>
					<cfelse>
						 <cfset astr[n] = axml.XmlChildren[i].XmlText />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<!--- return struct: --->
		<cfreturn astr />
	</cffunction>
</cfcomponent>