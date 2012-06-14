$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. $here/utilities.ps1

$context = @{
	FunctionList = @()
	FunctionsCalled = @()
}

function ClearContext()
{
	$context.FunctionList = @()
	$context.FunctionsCalled = @()
}

function AddFunctionToContext($functionName, $returnValue, $namedArgs)
{
	$funcObject = @{
		FunctionName = $functionName
		ReturnValue = $returnValue
		NamedArguments = $namedArgs
	}
	
	$context.FunctionList += $funcObject
}

function LookupReturnValueFromContext($functionName)
{
	foreach($funcObject in $context.FunctionList)
	{
		if($funcObject.FunctionName -eq $functionName)
		{
			return $funcObject.ReturnValue
		}
	}	
}

function LogFunctionCall($functionName, $unboundArgs, $boundArgs)
{
	$returnValue = LookupReturnValueFromContext $functionName

	$callRecord = @{
		FunctionName = $functionName
		UnboundArguments = $unboundArgs
		BoundArguments = $boundArgs
		UnboundArgumentCount = $unboundArgs.count
		BoundArgumentCount = $boundArgs.count	
		ReturnValue = $returnValue
	}
	
	$context.FunctionsCalled += $callRecord	
}

function DumpFunctionList()
{
	write-host "Registered functions"
	write-host "===================="
	foreach($functionObject in $context.FunctionList)
	{
		$argList = Build-ArgsList $functionObject.NamedArguments
		write-host "Function Name: ",$functionObject.FunctionName
		write-host "Return Value: ",$functionObject.ReturnValue	
		write-host "Named Arguments: ",$argList
		write-host ""
	}
}

function DumpFunctionsCalled()
{
	write-host "Called functions"
	write-host "===================="
	foreach($functionObject in $context.FunctionsCalled)
	{
		write-host "Function Name: ",$functionObject.FunctionName
		write-host "Return Value: ",$functionObject.ReturnValue	
		write-host ""
	}	
}

function DumpContext()
{
	DumpFunctionList
	DumpFunctionsCalled
}

function WasFunctionCalled($functionName)
{
	foreach($func in $context.FunctionsCalled)
	{
		if($func.FunctionName -eq $functionName)
		{
			return $true
		}
	}
	
	return $false
}

function WasFunctionCalledWithParameters($functionName, $expectedBoundArguments, $expectedUnboundArguments)
{
	# loop through all functions because a function may have been called 
	# more than once with different arguments
	foreach($func in $context.FunctionsCalled)
	{
		if($func.FunctionName -eq $functionName)
		{
			# check parms
			if($expectedBoundArguments.count -ne $func.BoundArguments.count) {continue}
			if($expectedUnboundArguments.length -ne $func.UnboundArguments.length) {continue}
			
			# compare bound arguments
			$parmsMatch = $true
			foreach($boundKey in $expectedBoundArguments.keys)
			{
				if($expectedBoundArguments[$boundKey] -ne $func.BoundArguments[$boundKey]) 
				{
					$parmsMatch = $false
					break
				}
			}
			if($parmsMatch -eq $false) {continue}

			# compare unbound arguments
			$parmsMatch = $true
			for($i = 0; $i -lt $expectedUnboundArguments.Length; $i++)
			{
				if($expectedUnboundArguments[$i] -ne $func.UnboundArguments[$i]) 
				{
					$parmsMatch = $false
					break
				}
			}
			if($parmsMatch -eq $false) {continue}
			
			# found a function with matching bound and unbound arguments
			return $true
		}
	}
	
	return $false
}

function FunctionsCalledInOrder($expectedOrderList)
{
	for($i = 0; $i -lt $expectedOrderList.Length; $i++)
	{
		if($context.FunctionsCalled[$i].FunctionName -ne $expectedOrderList[$i])
		{
			return $false
		}
	}
	
	return $true
}