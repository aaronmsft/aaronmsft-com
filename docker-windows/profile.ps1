# code-insiders $PsHome\profile.ps1
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted
function drun { 
    docker.exe run --rm `
        -v //var/run/docker.sock:/var/run/docker.sock `
        -v ${pwd}:/pwd/ `
        -w /pwd/ `
        -P `
        -it $args 
}
function dbash { drun drun bash }
function dubuntu { drun ubuntu bash }
function dalpine { drun alpine sh }
function dazure { drun mcr.microsoft.com/azure-cli }
function open { explorer $args }
function code { code-insiders $args }
function c { code-insiders $args }
