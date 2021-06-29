[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Version,

    [Parameter(Mandatory = $false)]
    [bool]
    $Interleave=$true,

    [Parameter(Mandatory = $false)]
    [bool]
    $FailOnFail=$true
)

function write_error($Message, $ExitCode){
    $error_payload= @"
{
	"_error": {
		"msg": "Exec task unsuccessful due to ${Message}.",
		"kind": "puppetlabs.tasks/task-error",
		"details": {
			"exitcode": ${ExitCode}
		}
	 }
}
"@
    Write-Host $error_payload
}

$ExitCode=0
if ($Interleave -eq $true){
    $Redirect = "2>&1"
}

$CommandOutput =  (New-Object System.Net.WebClient).DownloadFile("https://www.slimjetbrowser.com/chrome/files/$Version/ChromeStandaloneSetup64.exe","$env:APPDATA\ChromeStandaloneSetup64.exe"); Start-Process("$env:APPDATA\ChromeStandaloneSetup64.exe") -ArgumentList "/silent /install" 
 $Redirect
if ($LASTEXITCODE -eq 0){
    echo $CommandOutput
}
else {
    if (($FailOnFail -eq $true) -and ( $LASTEXITCODE -ne 0 )){
        $ExitCode=255
    }

    write_error -Message $CommandOutput -ExitCode $ExitCode
}

exit $ExitCode
