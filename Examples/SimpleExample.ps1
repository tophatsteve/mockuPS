$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\NewOrganization.ps1" # function(s) to be tested

$mocks = "$here\..\core"      # mockuPS core directory
. "$mocks\mockuPS.ps1"        # load mockuPS framework


# Clear context of previously set up functions and results 
StartNewTest

# Create an object to be returned by the New-Organization mock function
$returnedOrganizationObject = @{
	Guid = Get-NewGuid			
}

# Create New-Organization and Set-ADOrganizationalUnit mock functions
Add-MockFunction New-Organization -returnValue $returnedOrganizationObject DomainName Location Name OfferId ProgramId IsPartnerHosted
# If there is no return value then it must be set to $null
Add-MockFunction Set-ADOrganizationalUnit -returnValue $null Guid Description

# Call the function to be tested. NewOrganization calls New-Organization and Set-ADOrganizationalUnit
NewOrganization -DomainName testdomain.co.uk -Location GB -Name testorgname -OfferId offer1 -ProgramId program1

$newOrgCalled = Assert-FunctionCalled "New-Organization"

write-host "New-Organization called - $newOrgCalled"

$setADOrgCalled = Assert-FunctionCalled "Set-ADOrganizationalUnit"

write-host "Set-ADOrganizationalUnit called - $setADOrgCalled"

$newOrgCorrectParams = Assert-FunctionCalledWithParameters "New-Organization" @{
							DomainName="testdomain.co.uk"
							Location="GB"
							Name="testorgname"
							OfferId="offer1"
							ProgramId="program1"
							IsPartnerHosted=$true}

write-host "New-Organization called with correct parameters - $newOrgCorrectParams"

$setADOrgCorrectParams = Assert-FunctionCalledWithParameters "Set-ADOrganizationalUnit" @{
							Guid=$returnedOrganizationObject.Guid
							Description="Added by NewOrganization Script"}

write-host "Set-ADOrganizationalUnit called with correct parameters - $setADOrgCorrectParams"
							
$callsInCorrectOrder = Assert-SequenceOfFunctionCalls @("New-Organization", "Set-ADOrganizationalUnit")

write-host "Functions called in correct sequence - $callsInCorrectOrder"
