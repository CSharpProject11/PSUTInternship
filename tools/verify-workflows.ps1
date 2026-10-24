param([string]$ExportPath = "")
$ErrorActionPreference = 'Stop'
$repository = Split-Path -Parent $PSScriptRoot
$project = Join-Path $repository 'PSUTInternship\PSUTInternship'
$verification = Join-Path $repository '.verification'
New-Item -ItemType Directory -Path $verification -Force | Out-Null
$visualStudio = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
if (!$visualStudio) { throw 'Install Visual Studio with ASP.NET and web development tools.' }
$compiler = Join-Path $visualStudio 'MSBuild\Current\Bin\Roslyn\csc.exe'
$sources = @('PortalPage.cs','OpportunityCapacity.cs','SpreadsheetExport.cs','ContactReplyMailer.cs','CoordinatorData.cs','PortalRepository.cs','DatabaseSchema.cs','TaskWorkflow.cs','TrainingHoursWorkflow.cs','CompletionWorkflow.cs','CompletionReportPdf.cs','EvaluationPolicy.cs','OpportunityEligibility.cs','OpportunityPresentation.cs','TaskProgressSummary.cs','CompletionCertificateStore.cs','TaskFileStore.cs','PercentageRules.cs','AcademicCatalog.cs','AcademicAssignments.cs') | ForEach-Object { Join-Path $project "Shared\$_" }
$sources += @('Opportunity.cs','CompanyModels.cs','Application.cs','StudentTask.cs','TaskSubmission.cs','Studentinfo.cs') | ForEach-Object { Join-Path $project "Models\$_" }
$sources += Join-Path $PSScriptRoot 'WorkflowTests.cs'
$executable = Join-Path $verification 'WorkflowTests.exe'
$jsonAssembly = Join-Path $project 'bin\Newtonsoft.Json.dll'
if (!(Test-Path -LiteralPath $jsonAssembly)) { throw 'Build the web project before running the tests.' }
& $compiler /nologo /target:exe "/out:$executable" /r:System.Web.dll /r:System.Web.Extensions.dll /r:System.Net.Http.dll /r:System.Configuration.dll /r:System.Drawing.dll /r:System.IO.Compression.dll "/r:$jsonAssembly" $sources
if ($LASTEXITCODE -ne 0) { throw 'Workflow test compilation failed.' }
Copy-Item -LiteralPath $jsonAssembly -Destination $verification -Force
[xml]$webConfig = Get-Content -LiteralPath (Join-Path $project 'Web.config')
$settings = $webConfig.configuration.appSettings.OuterXml
[IO.File]::WriteAllText("$executable.config", "<configuration>$settings</configuration>")
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'fixtures\database-shape.json') -Destination $verification -Force
& $executable $verification $ExportPath
if ($LASTEXITCODE -ne 0) { throw 'Workflow tests failed.' }
