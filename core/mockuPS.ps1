$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. $here/utilities.ps1
. $here/context.ps1

# call as Add-MockFunction functionName returnValue parameterName1 parameterName2 ...
# if no return value is required then set it to $null: -ReturnValue $null
function Add-MockFunction($functionName, $returnValue)
{
	$argList = Build-ArgsList $args
		
	AddFunctionToContext $functionName $returnValue $args
	
	$newFunc = 
@"
		function global:$functionName( $argList )
		{
			#echo 'in $functionName'
			LogFunctionCall $functionName `$args `$PSBoundParameters
			LookupReturnValueFromContext $functionName
		}
"@
	Invoke-Expression $newFunc
}

# Check that $functionName was called:
#     Assert-FunctionCalled "myfunc"
function Assert-FunctionCalled($functionName)
{
	WasFunctionCalled $functionName
}
# Check that $functionName was called with the specified bound and unbound parameters:
#     Assert-FunctionCalledWithParameters myfunc @{parm1=val1;parm2=val2} @(val1,val2,val3)
function Assert-FunctionCalledWithParameters($functionName, $expectedBoundParameters = @{}, $expectedUnboundParameters = @())
{
	WasFunctionCalledWithParameters $functionName $expectedBoundParameters $expectedUnboundParameters
}

# Check that functions were called in the expected order:
#     Assert-SequenceOfFunctionCalls @("New-Organization","Set-ADOrganizationalUnit")
function Assert-SequenceOfFunctionCalls($expectedFunctionCallOrder)
{
	return FunctionsCalledInOrder $expectedFunctionCallOrder
}

# Reset the context for a new test
function StartNewTest
{
	ClearContext
}