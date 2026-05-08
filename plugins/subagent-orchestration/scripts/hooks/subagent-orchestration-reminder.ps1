$ErrorActionPreference = 'Stop'

$inputText = [Console]::In.ReadToEnd()
$promptText = $inputText

if (-not [string]::IsNullOrWhiteSpace($inputText)) {
    try {
        $payload = $inputText | ConvertFrom-Json -ErrorAction Stop
        $fields = @('prompt', 'message', 'input', 'text')
        foreach ($field in $fields) {
            if ($payload.PSObject.Properties.Name -contains $field) {
                $value = [string]$payload.$field
                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    $promptText = $value
                    break
                }
            }
        }
    } catch {
        $promptText = $inputText
    }
}

if ([string]::IsNullOrWhiteSpace($promptText)) {
    exit 0
}

$pattern = '(?i)\b(sub-?agent|multi_agent_v2|parallel agents?|delegate|delegation|orchestrat\w*|swarm|lead agents?|leaf agents?)\b'
if ($promptText -match $pattern) {
    Write-Output 'Subagent orchestration is available. Use the subagent-orchestration skill for multi_agent_v2 spawn plans, root-thread/lead/leaf roles, fork_turns choices, wait/list/close handling, and concise integration summaries.'
}
