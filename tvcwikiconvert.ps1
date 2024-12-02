# Function to define mappings for buttons and motions
function Get-Mapping {
    param ([string]$token)

    # Define button mappings
    # Each button is associated with a color and a file reference
    $mapping = @{
        "A" = @{"color" = "blue"; "file" = "[[File:TVC-L.png|50px]]"}    # Light attack
        "B" = @{"color" = "yellow"; "file" = "[[File:TVC-M.png|50px]]"}  # Medium attack
        "C" = @{"color" = "red"; "file" = "[[File:TVC-H.png|50px]]"}     # Heavy attack
        "P" = @{"color" = "green"; "file" = "[[File:TVC-P.png|50px]]"}   # Partner/Assist
        "X" = @{"color" = "green"; "file" = "[[File:TVC-AT.png|50px]]"}  # Special action
        "BBQ" = @{"color" = "bbq"; "file" = "[[File:TVC-BBQ.png|50px]]"} # Burst mechanics with a gradient
        "TK" = @{"color" = "white"; "file" = "[[File:TVC-TK.png|50px]]"} # Tiger Knee motion
        "SJC" = @{"color" = "white"; "file" = "[[File:TVC-SJC.png|50px]]"} # Super Jump Cancel
    }

    # Define motion mappings
    # Motions are numerical sequences representing directional inputs
    $motions = @{
        "5" = "[[File:TVC-neutral.png|50px]]"       # Neutral position
        "2" = "[[File:TVC-2.png|50px]]"            # Down direction
        "8" = "[[File:TVC-8.png|50px]]"            # Up direction
        "4" = "[[File:TVC-4.png|50px]]"            # Backward direction
        "6" = "[[File:TVC-6.png|50px]]"            # Forward direction
        "1" = "[[File:TVC-1.png|50px]]"            # Down-back
        "3" = "[[File:TVC-3.png|50px]]"            # Down-forward
        "7" = "[[File:TVC-7.png|50px]]"            # Up-back
        "9" = "[[File:TVC-9.png|50px]]"            # Up-forward
        "236" = "[[File:TVC-236.png|50px]]"        # Quarter circle forward
        "214" = "[[File:TVC-214.png|50px]]"        # Quarter circle backward
        "623" = "[[File:TVC-623.png|50px]]"        # Dragon punch motion
        "421" = "[[File:TVC-421.png|50px]]"        # Reverse dragon punch
        "41236" = "[[File:TVC-41236.png|50px]]"    # Half-circle forward
        "63214" = "[[File:TVC-63214.png|50px]]"    # Half-circle backward
        "360" = "[[File:TVC-360.png|50px]]"        # Full-circle motion
    }

    # Special case: BBQ (with a gradient color background)
    # Returns formatted output for BBQ specifically
    if ($token -eq "BBQ") {
        $color = "linear-gradient(to right, #FF69B4, #FF1493, #FFA500, #FFD700, #00CED1)"
        $file = "[[File:TVC-BBQ.png|50px]]"
        return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
    }

    # Return both mappings in a hashtable
    return @{"mapping" = $mapping; "motions" = $motions}
}

# Function to process individual tokens (e.g., A, 236A, BBQ)
function Process-Token {
    param (
        [string]$token,      # Input token (e.g., A, 236A)
        [hashtable]$mappingData # Hashtable of mappings (buttons and motions)
    )

    # Extract button and motion mappings from input hashtable
    $mapping = $mappingData["mapping"]
    $motions = $mappingData["motions"]

    # Handle special tokens like BBQ, TK, SJC
    if ($mapping.ContainsKey($token)) {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']

        # Special handling for BBQ to apply gradient underline
        if ($token -eq "BBQ") {
            $color = "linear-gradient(to right, #FF69B4, #FF1493, #FFA500, #FFD700, #00CED1)"
        }

        # Return notation and color formatting for the token
        return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
    }

    # Handle mixed tokens (e.g., motion + button like 236A)
    if ($token -match "^([0-9]+)([A-Z]+)$") {
        $motion = $matches[1]  # Extract motion (e.g., 236)
        $button = $matches[2]  # Extract button (e.g., A)

        # Check if both motion and button are defined
        if ($motions.ContainsKey($motion) -and $mapping.ContainsKey($button)) {
            $motionFile = $motions[$motion]              # Motion file
            $buttonFile = $mapping[$button]['file']      # Button file
            $buttonColor = $mapping[$button]['color']    # Button color

            # Format the combined output for notation and color
            $notation = "{{TvCUnderline|color=$buttonColor|$motionFile $buttonFile}}"
            $color = "{{TvC-Colors|$buttonColor|$motion$button}}" # Motion + button formatting
            return @($notation, $color)
        }
    }

    # Handle standalone buttons (e.g., A, B, C)
    if ($mapping.ContainsKey($token)) {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']

        # Return formatting for standalone buttons
        return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
    }

    # Handle standalone motions (e.g., 236, 214)
    if ($motions.ContainsKey($token)) {
        $motionFile = $motions[$token]

        # Default motion color is white
        $notation = "{{TvCUnderline|color=white|$motionFile}}"
        $color = "{{TvC-Colors|white|$token}}"
        return @($notation, $color)
    }

    # Return null values if the token is not recognized
    return @($null, $null)
}

# Main loop for user interaction
while ($true) {
    Write-Host "==================================================="
    Write-Host "TvC Wiki Numpad Notation Converter"
    Write-Host "==================================================="

    # Prompt user for input or exit
    $input = Read-Host "Enter a numpad notation sequence (e.g., A B 236C) or type 'exit' to quit"

    # Break loop if the user chooses to exit
    if ($input -eq "exit") {
        break
    }

    # Load mappings for buttons and motions
    $mappingData = Get-Mapping

    # Tokenize the user input by spaces and convert to uppercase
    $tokens = $input.ToUpper() -split ' '

    # Initialize results for formatted outputs
    $notationResult = @()
    $colorResult = @()

    # Process each token individually
    foreach ($token in $tokens) {
        $results = Process-Token -token $token -mappingData $mappingData
        if ($results[0] -ne $null) {
            $notationResult += $results[0]  # Add to notation output
        }
        if ($results[1] -ne $null) {
            $colorResult += $results[1]     # Add to color output
        }
    }

    # Output the formatted results for notation and color
    Write-Host "|notation= $($notationResult -join ' ')"
    if ($colorResult.Count -gt 0) {
        Write-Host "`n$($colorResult -join ' &ensp; ')"
    }

    # Add a blank line for spacing
    Write-Host ""
}
