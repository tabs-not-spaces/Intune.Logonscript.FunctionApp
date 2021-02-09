# Intune.LogonScript.FunctionApp

Azure Function App to serve as midddleware for a logon script solution for cloud managed devices.

## Folder overview

- function-app contains the function app code that will be deployed to Azure
- logonscript contains the code that will be packaged and deployed via Intune
- tests contains the pester tests to be used for interactive testing OR ci/cd deployment

## Pre-Reqs for local function app development and deployment

To develop and deploy the function app contained within this repository, please make sure you have the following reqs on your development environment.

- [Visual Studio Code](https://code.visualstudio.com/)
- The [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#install-the-azure-functions-core-tools) version 2.x or later. The Core Tools package is downloaded and installed automatically when you start the project locally. Core Tools includes the entire Azure Functions runtime, so download and installation might take some time.
- [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows) recommended.
- Both [.NET Core 3.1](https://www.microsoft.com/net/download) runtime and [.NET Core 2.1 runtime](https://dotnet.microsoft.com/download/dotnet-core/2.1).
- The [PowerShell extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell).
- The [Azure Functions extension for Visual Studio Code](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=powershell#install-the-azure-functions-extension)
