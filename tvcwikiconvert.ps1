# Function to wrap input in TvCInput format
function Get-TvCFormattedInput {
    param (
        [string]$inputString
    )
    # Return the wrapped format
    return "{{TvCInput|$inputString}}"
}

# Prompt user for input
Write-Host "Enter the TvCInput string (multiple inputs separated by spaces):"
$userInput = Read-Host

# Split the input into multiple strings and process each one
$outputs = @()
foreach ($input in $userInput -split '\s+') {
    $outputs += Get-TvCFormattedInput -inputString $input
}

# Combine the results into a single output string
$outputString = $outputs -join " "

# Output the result
Write-Host $outputString
