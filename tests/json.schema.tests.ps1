BeforeDiscovery {
	$script:JsonPath = ".\function-app\aad-sec-grp-qry\drivemaps.json"
	$script:SchemaPath = '.\drivemaps_schema.json'
}
Describe "File Existence Test" {
	BeforeAll {
		function Test-JsonFileExists {
			[cmdletbinding()]
			param (
				$jsonPath = $script:JsonPath
			)
			return Get-ChildItem $jsonPath
		}
	}
	Context "JSON files Should Exist" {
		It 'File count should be greater than 0' {
			(Test-JsonFileExists).count | Should -Not -Be 0
		}
	}
}
Describe "'$(Split-Path $JsonPath -Leaf)' JSON File Syntax Test" {
	BeforeAll {
		function Test-JsonSyntax {
			[cmdletbinding()]
			param (
				$jsonPath = $script:JsonPath
			)
			$fileContent = Get-Content $jsonPath -Raw
			$res = ConvertFrom-Json -InputObject $fileContent -ErrorVariable parseError
			if ($parseError) {
				return $false
			}
			else {
				return $true
			}
		}
		function Test-JsonAgainstSchema {
			[cmdletbinding()]
			param (
				$jsonPath = $script:JsonPath,
				$jsonSchema = $script:SchemaPath
			)
			$fileContent = Get-Content -Path $jsonPath -Raw
			$Schema = Get-Content -Path $schemaPath -Raw
			Test-Json -Json $fileContent -Schema $Schema
		}
	}
	Context "JSON Syntax Test" {
		It 'Should be a valid JSON file' {
			Test-JsonSyntax | Should -Be $true
		}
	}
	Context "JSON Schema Test" {
		It 'Should be a valid JSON file against Schema' {
			Test-JsonAgainstSchema | Should -Be $true
		}
	}
}
