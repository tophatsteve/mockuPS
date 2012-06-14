# mockuPS
A mocking framework for Powershell.

mockuPS allows you to add mock functions for use in testing your Powershell scripts, and then check that these mock functions where called correctly. It can also be used to mock out **cmdlets** in addition to functions because Powershell tries to resolve function names before it resolves cmdlet names.

It is best used in a unit testing framework, such as [scottmuc](https://github.com/scottmuc)'s excellent [Pester](https://github.com/scottmuc/Pester), but it can also be used standalone in your own scripts. The `Examples` folder contains demonstrations of both a Pester test and a simple script use of mockuPS. 

The examples show a Powershell script that calls the **Exchange** cmdlet `New-Organization` and the **Active Directory** cmdlet `Set-ADOrganizationalUnit`. We want to test the script without access to Exchange or Active Directory, so we create mock versions of the cmdlets as functions. 

Follow these steps to use mockuPS:

* Include the file `core/mockuPS.ps1` in your test script.
* Use Add-MockFunction to create your mock function. The names parameters to Add-MockFunction are `FunctionName` and `ReturnValue`. Anything after these parameters will be added to your mock function as named parameters. The following example creates a mock function called `myFunc` which returns a value of `"Finished"` and takes named parameters called `paramName1` and `paramName2`.
> Add-MockFunction -FunctionName myFunc -ReturnValue "Finished" paramName1 paramName2
* Run the script you want to test.
* Check that the stub functions where called as expected using one of the three `Assert-` functions:
    * `Assert-FunctionCalled functionName` - This returns true if the function `functionName` was called.
    * `Assert-FunctionCalledWithParameters functionName @{boundArguments} @(unboundArguments)` - Checks that function `functionName` was called with the bound arguments passed in the `boundArguments` dictionary and the unbound arguments passed in the `unboundArguments` array. The `boundArguments` dictionary should be in the format `@{paramName1=value1;paramName2=value2}`.
    * `Assert-SequenceOfFunctionCalls @("myFunc1", "myFunc2")` - Checks that `myFunc1` was called before `myFunc2`.






