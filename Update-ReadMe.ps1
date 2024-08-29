Import-Module (Join-Path -Path $PSScriptRoot -ChildPath UncommonSense.Jumbo.psd1) -Force

Get-Command -Module UncommonSense.Jumbo |
    Convert-HelpToMarkDown `
        -Title 'UncommonSense.Jumbo' `
        -Description 'PowerShell module for retrieving Jumbo store information' |
    Out-File -FilePath (Join-Path -Path $PSScriptRoot -ChildPath README.md) -Encoding utf8