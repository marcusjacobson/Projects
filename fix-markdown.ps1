# PowerShell script to fix markdown formatting issues
$filePath = "Microsoft\Azure Ai Security Skills Challenge\02 - AI Integration & Enhanced Security Operations\deploy-azure-openai-service-azure-portal.md"

# Read the file
$content = Get-Content $filePath -Raw

# Fix 1: Reset numbered lists to start with 1 in each section
# This regex targets numbered lists and resets them to 1
$content = $content -replace '(?m)^[2-9]\. \*\*([^*]+)\*\*:', '1. **$1**:'

# Fix 2: Add blank line before numbered lists (when missing)
$content = $content -replace '(?m)^([^\r\n]*[^\r\n\s])\r?\n(\d+\. \*\*)', '$1' + [Environment]::NewLine + [Environment]::NewLine + '$2'

# Fix 3: Add blank line after bullet point lists (when missing) 
$content = $content -replace '(?m)^(- [^\r\n]+)\r?\n([^\r\n\s-])', '$1' + [Environment]::NewLine + [Environment]::NewLine + '$2'

# Fix 4: Add blank line before bullet point lists (when missing)
$content = $content -replace '(?m)^([^\r\n]*[^\r\n\s])\r?\n(- [^\r\n]+)', '$1' + [Environment]::NewLine + [Environment]::NewLine + '$2'

# Save the file
$content | Set-Content $filePath -NoNewline

Write-Host "Markdown formatting fixes applied successfully!"
