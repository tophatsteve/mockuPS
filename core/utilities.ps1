
function Get-NewGuid()
{
	return [guid]::NewGuid()
}

function Build-ArgsList($passedArgs)
{
	$argList = ""
	
	foreach($argName in $passedArgs)
	{
		if($argList.Length -gt 0)
		{
			$argList += ","
		}
		$argList += "`$" + $argName
	}
	
	return $argList
}