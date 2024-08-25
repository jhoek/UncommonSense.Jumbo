<#
.EXAMPLE
Get-JumboStore -ID jumbo-veenendaal-huibers, jumbo-aalsmeer-ophelialaan
#>
function Get-JumboStore
{
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$ID
    )

    begin
    {
        $DutchCulture = Get-Culture 'nl-NL'
        $Today = (Get-Date).Date
    }

    process
    {
        $ID.ForEach{
            $Document = ConvertTo-HtmlDocument -Uri "https://www.jumbo.com/winkel/$_"
            $Name = $Document | Select-HtmlNode -CssSelector 'h1 strong' | Get-HtmlNodeText
            $DatesAsText = $Document | Select-HtmlNode -CssSelector '.opening-hours__line .date' -All | Get-HtmlNodeText
            $TimesAsText = $Document | Select-HtmlNode -CssSelector '.opening-hours__line .time' -All | Get-HtmlNodeText

            $AfterToday = $false
            $OpeningHours = @()

            $DateEnumerator = $DatesAsText.GetEnumerator()
            $TimeEnumerator = $TimesAsText.GetEnumerator()

            while ($DateEnumerator.MoveNext())
            {
                $TimeEnumerator.MoveNext() | Out-Null

                $Date = [DateTime]::ParseExact($DateEnumerator.Current, "d MMMM", $DutchCulture)
                if ($Date -eq $Today) { $AfterToday = $true }

                # Correct for missing year
                switch ($AfterToday)
                {
                    ($true) { if ($Date -lt $Today) { $Date = $Date.AddYears(1); break } }
                    ($false) { if ($Date -gt $Today) { $Date = $Date.AddYears(-1); break } }
                }

                $Match = $TimeEnumerator.Current | Select-String -Pattern '^(?<From>\d{2}:\d{2})\s\-\s(?<To>\d{2}:\d{2})$'

                if ($Match.Matches -and $Match.Matches[0].Success)
                {
                    $FromTime = $Match.Matches[0].Groups['From'].Value
                    $ToTime = $Match.Matches[0].Groups['To'].Value

                    $OpeningHour = [PSCustomObject]@{
                        PSTypeName = 'UncommonSense.Jumbo.OpeningHours'
                        From       = $Date.Add($FromTime)
                        To         = $Date.Add($ToTime)
                    }

                    $OpeningHours += $OpeningHour
                }
            }

            [PSCustomObject]@{
                PSTypeName   = 'UncommonSense.Jumbo.Store'
                ID           = $_
                Name         = $Name
                OpeningHours = $OpeningHours
            }
        }
    }
}