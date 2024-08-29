Describe 'Get-JumboStore' {
    BeforeAll {
        Import-Module "$PSScriptRoot/UncommonSense.Jumbo.psd1" -Force
    }

    It 'Returns valid return store information' {
        $Result = Get-JumboStore -ID jumbo-veenendaal-huibers

        $Result.id | Should -Be 'jumbo-veenendaal-huibers'
        $Result.Name | Should -Be 'Jumbo Veenendaal Huibers'
        $Result.OpeningHours.Count | Should -BeGreaterThan 7
        $Result.OpeningHours | ForEach-Object { $_.From | Should -Not -BeNullOrEmpty }
        $Result.OpeningHours | ForEach-Object { $_.To | Should -Not -BeNullOrEmpty }
    }
}