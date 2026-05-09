$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$pluginRoot = Join-Path $repoRoot 'plugins\subagent-orchestration'
$errors = New-Object System.Collections.Generic.List[string]

function Add-ValidationError([string]$message) {
    $script:errors.Add($message) | Out-Null
}

function Require-File([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-ValidationError "Missing file: $path"
    }
}

function Read-Json([string]$path) {
    Require-File $path
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return $null
    }
    try {
        return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Add-ValidationError "Invalid JSON: $path :: $($_.Exception.Message)"
        return $null
    }
}

function Read-TomlFields([string]$path) {
    $fields = @{}
    $content = Get-Content -Raw -LiteralPath $path
    foreach ($name in @('name', 'description', 'developer_instructions', 'model', 'model_reasoning_effort', 'sandbox_mode')) {
        if ($content -match "(?ms)^$name\s*=\s*(`"`"`"|`"|'')") {
            $fields[$name] = $true
        } elseif ($content -match "(?m)^$name\s*=\s*`"") {
            $fields[$name] = $true
        } else {
            $fields[$name] = $false
        }
    }
    return $fields
}

function Read-TomlStringValue([string]$content, [string]$fieldName) {
    if ($content -match "(?m)^$fieldName\s*=\s*`"([^`"]+)`"") {
        return $Matches[1]
    }
    return $null
}

$marketplacePath = Join-Path $repoRoot '.agents\plugins\marketplace.json'
$pluginManifestPath = Join-Path $pluginRoot '.codex-plugin\plugin.json'
$hooksPath = Join-Path $pluginRoot 'hooks.json'
$skillPath = Join-Path $pluginRoot 'skills\subagent-orchestration\SKILL.md'
$hookScriptPath = Join-Path $pluginRoot 'scripts\hooks\subagent-orchestration-reminder.py'
$agentsPath = Join-Path $pluginRoot 'agents'
$iconPath = Join-Path $pluginRoot 'assets\icon.svg'

$marketplace = Read-Json $marketplacePath
if ($marketplace) {
    if ($marketplace.name -ne 'novotnyllc') { Add-ValidationError 'Marketplace name must be novotnyllc.' }
    $entry = @($marketplace.plugins | Where-Object { $_.name -eq 'subagent-orchestration' }) | Select-Object -First 1
    if (-not $entry) {
        Add-ValidationError 'Marketplace missing subagent-orchestration entry.'
    } else {
        if ($entry.source.source -ne 'local') { Add-ValidationError 'Marketplace source.source must be local.' }
        if ($entry.source.path -ne './plugins/subagent-orchestration') { Add-ValidationError 'Marketplace source.path must be ./plugins/subagent-orchestration.' }
        if (-not $entry.policy.installation) { Add-ValidationError 'Marketplace entry missing policy.installation.' }
        if (-not $entry.policy.authentication) { Add-ValidationError 'Marketplace entry missing policy.authentication.' }
        if (-not $entry.category) { Add-ValidationError 'Marketplace entry missing category.' }
    }
}

$manifest = Read-Json $pluginManifestPath
if ($manifest) {
    foreach ($field in @('name', 'version', 'description', 'author', 'homepage', 'repository', 'license', 'skills', 'hooks', 'interface')) {
        if (-not $manifest.PSObject.Properties.Name.Contains($field)) {
            Add-ValidationError "Plugin manifest missing $field."
        }
    }
    if ($manifest.name -ne 'subagent-orchestration') { Add-ValidationError 'Plugin manifest name mismatch.' }
    if ($manifest.skills -ne './skills/') { Add-ValidationError 'Plugin manifest skills must be ./skills/.' }
    if ($manifest.hooks -ne './hooks.json') { Add-ValidationError 'Plugin manifest hooks must be ./hooks.json.' }
    foreach ($relative in @($manifest.skills, $manifest.hooks, $manifest.interface.composerIcon, $manifest.interface.logo)) {
        if ($relative) {
            $resolved = Join-Path $pluginRoot ($relative -replace '^./', '')
            if (-not (Test-Path -LiteralPath $resolved)) {
                Add-ValidationError "Manifest path does not exist: $relative"
            }
        }
    }
}

$hooks = Read-Json $hooksPath
if ($hooks) {
    if (-not $hooks.hooks.UserPromptSubmit) { Add-ValidationError 'hooks.json must define UserPromptSubmit.' }
    $hookText = Get-Content -Raw -LiteralPath $hooksPath
    if ($hookText -match '(?i)\bpwsh\b|\.ps1') { Add-ValidationError 'hooks.json hook command must not use PowerShell.' }
    if ($hookText -notmatch '(?i)\b(python3|python)\b.*subagent-orchestration-reminder\.py') { Add-ValidationError 'hooks.json must explicitly invoke Python for subagent-orchestration-reminder.py.' }
}

Require-File $skillPath
if (Test-Path -LiteralPath $skillPath -PathType Leaf) {
    $skill = Get-Content -Raw -LiteralPath $skillPath
    if ($skill -notmatch '(?s)^---\s*\nname:\s*subagent-orchestration\s*\ndescription:') {
        Add-ValidationError 'Skill frontmatter missing name/description.'
    }
    foreach ($term in @('multi_agent_v2', 'spawn_agent', 'send_message', 'followup_task', 'wait_agent', 'list_agents', 'close_agent')) {
        if ($skill -notmatch [regex]::Escape($term)) {
            Add-ValidationError "Skill missing required term: $term"
        }
    }
}

Require-File $hookScriptPath
Require-File $iconPath

if (-not (Test-Path -LiteralPath $agentsPath -PathType Container)) {
    Add-ValidationError "Missing agents directory: $agentsPath"
} else {
    $seen = @{}
    $agentDefaultEfforts = @{}
    $agentFiles = Get-ChildItem -LiteralPath $agentsPath -Filter '*.toml' -File
    if ($agentFiles.Count -lt 10) {
        Add-ValidationError 'Expected at least 10 bundled agent TOML files.'
    }
    foreach ($file in $agentFiles) {
        $fields = Read-TomlFields $file.FullName
        foreach ($field in @('name', 'description', 'developer_instructions', 'model', 'model_reasoning_effort', 'sandbox_mode')) {
            if (-not $fields[$field]) {
                Add-ValidationError "$($file.Name) missing $field."
            }
        }
        $content = Get-Content -Raw -LiteralPath $file.FullName
        $name = Read-TomlStringValue $content 'name'
        if ($name) {
            if ($seen.ContainsKey($name)) {
                Add-ValidationError "Duplicate agent name: $name"
            } else {
                $seen[$name] = $true
            }
            $model = Read-TomlStringValue $content 'model'
            if ($model -ne 'gpt-5.5') {
                Add-ValidationError "$($file.Name) must use model gpt-5.5."
            }
            $effort = Read-TomlStringValue $content 'model_reasoning_effort'
            if ($effort -notin @('low', 'medium', 'high', 'xhigh')) {
                Add-ValidationError "$($file.Name) has invalid model_reasoning_effort: $effort"
            } else {
                $agentDefaultEfforts[$name] = $effort
            }
        }
    }

    $skillFiles = Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Filter 'SKILL.md' -Recurse -File
    foreach ($skillFile in $skillFiles) {
        if ($skillFile.Directory.Name -like '*-cli*') {
            Add-ValidationError "CLI skill is not allowed in this plugin: $($skillFile.Directory.Name)"
        }

        $content = Get-Content -Raw -LiteralPath $skillFile.FullName
        $spawnMatches = [regex]::Matches($content, '(?s)\{\s*"tool"\s*:\s*"spawn_agent"\s*,\s*"args"\s*:\s*\{.*?\}\s*\}')
        foreach ($spawn in $spawnMatches) {
            $block = $spawn.Value
            $line = (($content.Substring(0, $spawn.Index) -split "`n").Count)
            if ($block -match '"agent_type"\s*:\s*"([^"]+)"') {
                $agentType = $Matches[1]
                if (-not $seen.ContainsKey($agentType)) {
                    Add-ValidationError "$($skillFile.Directory.Name):$line references unknown agent_type: $agentType"
                }
            } else {
                Add-ValidationError "$($skillFile.Directory.Name):$line spawn_agent call missing agent_type."
                $agentType = $null
            }

            if ($block -match '"reasoning_effort"\s*:\s*"([^"]+)"') {
                $reasoningEffort = $Matches[1]
                if ($agentType -and $agentDefaultEfforts.ContainsKey($agentType) -and $agentDefaultEfforts[$agentType] -ne $reasoningEffort) {
                    Add-ValidationError "$($skillFile.Directory.Name):$line uses $agentType with reasoning_effort '$reasoningEffort' but agent default is '$($agentDefaultEfforts[$agentType])'."
                }
            } else {
                Add-ValidationError "$($skillFile.Directory.Name):$line spawn_agent call missing reasoning_effort."
            }

            if ($block -notmatch '"fork_turns"\s*:\s*"none"') {
                Add-ValidationError "$($skillFile.Directory.Name):$line spawn_agent call must use fork_turns `"none`"."
            }
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Error ("Validation failed:`n - " + ($errors -join "`n - "))
    exit 1
}

Write-Output 'subagent-orchestration plugin validation passed.'
