$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\NewOrganization.ps1" # function(s) to be tested

$mocks = "$here\..\core"      # mockuPS core directory
. "$mocks\mockuPS.ps1"        # mockuPS framework


    Describe "NewOrganization" {
	
		# Clear context of previously set up functions and results 
		StartNewTest
	
		# Create an object to be returned by the New-Organization mock function
		$returnedOrganizationObject = @{
			Guid = Get-NewGuid			
		}

		# Create New-Organization and Set-ADOrganizationalUnit mock functions
		Add-MockFunction New-Organization -returnValue $returnedOrganizationObject DomainName Location Name OfferId ProgramId IsPartnerHosted
		Add-MockFunction Set-ADOrganizationalUnit -returnValue $null Guid Description
		
		# Call the function to be tested. NewOrganization calls New-Organization and Set-ADOrganizationalUnit
		NewOrganization -DomainName testdomain.co.uk -Location GB -Name testorgname -OfferId offer1 -ProgramId program1
		
		# Test the results of the function call
        It "Calls the New-Organization function" {
			(Assert-FunctionCalled "New-Organization").should.be($true)			
        }
		
        It "Calls the Set-ADOrganizationalUnit function" {
			(Assert-FunctionCalled "Set-ADOrganizationalUnit").should.be($true)			
        }		
		
		It "Calls the New-Organization function passing in the correct parameters" {
			(Assert-FunctionCalledWithParameters "New-Organization" @{
					DomainName="testdomain.co.uk"
					Location="GB"
					Name="testorgname"
					OfferId="offer1"
					ProgramId="program1"
					IsPartnerHosted=$true}).should.be($true)
        }
		
		It "Calls the Set-ADOrganizationalUnit function passing in the correct parameters" {
			(Assert-FunctionCalledWithParameters "Set-ADOrganizationalUnit" @{
					Guid=$returnedOrganizationObject.Guid
					Description="Added by NewOrganization Script"}).should.be($true)
        }	

		It "Calls the functions in the correct sequence" {
			(Assert-SequenceOfFunctionCalls @("New-Organization", "Set-ADOrganizationalUnit")).should.be($true)	
        }
		
    }
