# Function to define mappings for buttons and motions
function Get-Mapping {
    param ([string]$token)
    $imageSize = "30px"  # You can adjust this value as needed
    # Define button mappings
    $mapping = @{
        "A" = @{color="blue"; file="[[File:TVC-L.png|$imageSize]]"}    # Light attack
        "B" = @{color="yellow"; file="[[File:TVC-M.png|$imageSize]]"}  # Medium attack
        "C" = @{color="red"; file="[[File:TVC-H.png|$imageSize]]"}     # Heavy attack
        "P" = @{color="green"; file="[[File:TVC-P.png|$imageSize]]"}   # Partner/Assist
        "X" = @{color="green"; file="[[File:TVC-AT.png|$imageSize]]"}  # Special action
        "BBQ" = @{color="bbq"; file="[[File:TVC-BBQ.png|$imageSize]]"} # Burst mechanics
        "TK" = @{color="white"; file="[[File:TVC-TK.png|$imageSize]]"} # Tiger Knee motion
        "SJC" = @{color="white"; file="[[File:TVC-SJC.png|$imageSize]]"} # Super Jump Cancel
    }

    $motions = @{
        "5" = "[[File:TVC-neutral.png|$imageSize]]"       # Neutral position
        "2" = "[[File:TVC-2.png|$imageSize]]"            # Down direction
        "8" = "[[File:TVC-8.png|$imageSize]]"            # Up direction
        "4" = "[[File:TVC-4.png|$imageSize]]"            # Backward direction
        "6" = "[[File:TVC-6.png|$imageSize]]"            # Forward direction
        "1" = "[[File:TVC-1.png|$imageSize]]"            # Down-back
        "3" = "[[File:TVC-3.png|$imageSize]]"            # Down-forward
        "7" = "[[File:TVC-7.png|$imageSize]]"            # Up-back
        "9" = "[[File:TVC-9.png|$imageSize]]"            # Up-forward
        "236" = "[[File:TVC-236.png|$imageSize]]"        # Quarter circle forward
        "214" = "[[File:TVC-214.png|$imageSize]]"        # Quarter circle backward
        "623" = "[[File:TVC-623.png|$imageSize]]"        # Dragon punch motion
        "421" = "[[File:TVC-421.png|$imageSize]]"        # Reverse dragon punch
        "41236" = "[[File:TVC-41236.png|$imageSize]]"    # Half-circle forward
        "63214" = "[[File:TVC-63214.png|$imageSize]]"    # Half-circle backward
        "360" = "[[File:TVC-360.png|$imageSize]]"        # Full-circle motion
    }

    return @{"mapping" = $mapping; "motions" = $motions}
}

# Function to process individual tokens (e.g., A, 236A, BBQ)
# Function to process individual tokens (e.g., A, 236A, BBQ)
function Process-Token {
    param (
        [string]$token,
        [hashtable]$mappingData
    )

    $mapping = $mappingData["mapping"]
    $motions = $mappingData["motions"]

    # Handle special tokens like BBQ, TK, SJC
    if ($mapping.ContainsKey($token)) {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']

        return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
    }

    # Handle mixed tokens (e.g., 236A)
    if ($token -match "^([0-9]+)([A-Z]+)$") {
        $motion = $matches[1]
        $button = $matches[2]

        if ($motions.ContainsKey($motion) -and $mapping.ContainsKey($button)) {
            $motionFile = $motions[$motion]
            $buttonFile = $mapping[$button]['file']
            $buttonColor = $mapping[$button]['color']

            return @(
                "{{TvCUnderline|color=$buttonColor|$motionFile $buttonFile}}", 
                "{{TvC-Colors|$buttonColor|$motion$button}}"
            )
        }
    }

    # Handle standalone motions
    if ($motions.ContainsKey($token)) {
        $motionFile = $motions[$token]
        return @("{{TvCUnderline|color=white|$motionFile}}", "{{TvC-Colors|white|$token}}")
    }

    return @($null, $null) # If unrecognized
}

# Main loop for user interaction
while ($true) {
    Write-Host "==================================================="
    Write-Host "TvC Wiki Numpad Notation Converter"
    Write-Host "==================================================="

    $input = Read-Host "Enter a numpad notation sequence (e.g., A B 236C) or type 'exit' to quit"
    if ($input -eq "exit") { break }

    $mappingData = Get-Mapping
    $tokens = $input.ToUpper() -split ' '

    $notationResult = @()
    $colorResult = @()

    foreach ($token in $tokens) {
        $results = Process-Token -token $token -mappingData $mappingData

        if ($results[0] -ne $null) {
            # Append tab-like space (&emsp;) after each notation
            $notationResult += "$($results[0]) &emsp;"  # Tab space added explicitly
        }
        if ($results[1] -ne $null) {
            # Add tab-like spacing for color-coded output
            $colorResult += "$($results[1]) &emsp;"
        }
    }

    # Join results, which already have explicit tab-like spaces, and trim any trailing spaces
    $notationOutput = ($notationResult -join '').TrimEnd('&emsp;')
    $colorOutput = ($colorResult -join '').TrimEnd('&emsp;')

    Write-Host ""
    Write-Host "|notation= $notationOutput"
    Write-Host "`n$colorOutput"
    Write-Host ""
}
