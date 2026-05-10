function Write-GitHubErrorAnnotation {
  param(
    [Parameter(Mandatory)][string]$Title,
    [Parameter(Mandatory)][string]$Message
  )

  # Only emit when running inside GitHub Actions
  if (-not $env:GITHUB_ACTIONS) { return }

  # Flatten whitespace so the workflow command stays on one line
  $msg = ($Message -replace '\s+', ' ').Trim()
  if ([string]::IsNullOrWhiteSpace($msg)) { $msg = 'Check failed.' }

  # GitHub Actions workflow command for an error annotation
  Write-Output "::error title=$Title::$msg"
}
