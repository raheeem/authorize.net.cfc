<cfset user.id = "568">
<cfset user.email = "raheeem@gmail.com">
<cfset user.description = "">
<cfset user.customerType = "individual">
<cfset user.cardNumber = "4111111111111111">
<cfset user.expirationDate = "2020-12">
<cfset user.cardCode = "999">
<cfset user.firstName = "Abdul">
<cfset user.lastName = "Raheem">
<cfset user.company = "XYZ Company">
<cfset user.address = "my Address">
<cfset user.city = "New York">
<cfset user.zip = "00501">
<cfset user.state = "New York">
<cfset user.country = "United States">
<cfset user.phoneNumber = "+123 223 9998">
<cfset user.faxNumber = "">

<cfset authCFC = createObject("component", "api.authorize").init("TEST")>
<Cfset myResult = authCFC.createCustomerProfileRequest(argumentCollection = user)>
<cfdump var="#myResult#">
