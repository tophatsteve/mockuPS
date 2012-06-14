
function NewOrganization{
param(
    [string]$DomainName,
    [string]$Location,
    [string]$Name,
    [string]$OfferId,
    [string]$ProgramId
    )

	#Create a new organization
	$newOrganization = 
	@{
		DomainName = $DomainName
		Location = $Location
		Name = $Name
		OfferId = $OfferId
		ProgramId = $ProgramId
		IsPartnerHosted = $true
	}
	
	#Call Exchange cmdlet New-Organization
    if  ($org = New-Organization @newOrganization )
    {
		# Retrieve guid from newly created organization
        $guid = $org.guid.guid
		
		# Call Active Directory cmdlet Set-ADOrganizationalUnit
		Set-ADOrganizationalUnit $guid -Description "Added by NewOrganization Script"
	}
}
