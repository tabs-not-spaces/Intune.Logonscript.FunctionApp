BeforeDiscovery {
    function Get-TestEnv {
        [cmdletbinding()]
        param (
            $envVar
        )
        $localEnv = get-content ".\tests\.localenv" -Raw | ConvertFrom-Json
        return $localEnv.$envVar
    }
    if (!$env:FA_ENDPOINT_UAT) {
        $env:FA_ENDPOINT_UAT = Get-TestEnv 'endpoint'
    }
    if (!$env:SAMPLE_USER) {
        $env:SAMPLE_USER = Get-TestEnv 'user'
    }
    if (!$env:JSON_PATH) {
        $env:JSON_PATH = ".\function-app\aad-sec-grp-qry\drivemaps.json"
    }
}
Describe "Function App Call" {
    Context "Checking result of REST call" {
        BeforeAll {
            $iwr = Invoke-WebRequest -Method Get -Uri "$($env:FA_ENDPOINT_UAT)&user=$env:SAMPLE_USER"
            $toMap = $iwr.Content | ConvertFrom-Json
            $hash = (Get-FileHash "$env:JSON_PATH").Hash
            $hashCheck = $hash.Substring($hash.Length -6, 6)
        }
        it 'Function call should return 200' { $iwr.StatusCode | Should -Be 200 }
        it 'Function content should be well formed JSON' { $toMap | should -Not -Be $null }
        it 'We should have some base drives' { $toMap.drives.count | Should -Not -Be $null }
        it 'The configuration JSON should match' { $hashCheck | should -Be $toMap.hash}
    }
}