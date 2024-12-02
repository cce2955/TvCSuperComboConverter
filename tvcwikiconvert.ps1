function Get-Mapping {
    param ([string]$token)
    $imageSize = "30px"  # Adjustable size for image files

    # Define button mappings for numpad notation colors and file paths
    $mapping = @{
        "A" = @{color="blue"; file="[[File:TVC-L.png|$imageSize]]"}    # Light attack
        "B" = @{color="yellow"; file="[[File:TVC-M.png|$imageSize]]"}  # Medium attack
        "C" = @{color="red"; file="[[File:TVC-H.png|$imageSize]]"}     # Heavy attack
        "P" = @{color="green"; file="[[File:TVC-P.png|$imageSize]]"}   # Partner/Assist
        "X" = @{color="purple"; file="[[File:TVC-AT.png|$imageSize]]"} # Special action
        "XX" = @{color="green"; file="[[File:TVC-AT.png|$imageSize]] [[File:TVC-AT.png|$imageSize]]"} # Double special
        "BBQ" = @{color="orange"; file="[[File:TVC-BBQ.png|$imageSize]]"} # Burst mechanics
        "TK" = @{color="gray"; file="[[File:TVC-TK.png|$imageSize]]"}  # Tiger Knee motion
        "SJC" = @{color="cyan"; file="[[File:TVC-SJC.png|$imageSize]]"} # Super Jump Cancel
        "drill" = @{color="pink"; file="[[File:TVC-L.png|$imageSize]] [[File:TVC-M.png|$imageSize]] -> [[File:TVC-L.png|$imageSize]] [[File:TVC-M.png|$imageSize]] -> [[File:TVC-M.png|$imageSize]] [[File:TVC-H.png|$imageSize]]"}
        "charge" = @{color="blue"; file="[[File:TVC-charge.png|50px]]"} # Charge command
    }

    # Define special underline colors for visual distinction
    $underlineMapping = @{
        "A" = "yellow"
        "B" = "green"
        "C" = "blue"
        "P" = "purple"
        "X" = "purple"
        "XX" = "purple"
        "BBQ" = "orange"
        "TK" = "gray"
        "SJC" = "cyan"
        "drill" = "pink"
        "charge" = "blue"
    }

    # Define motion mappings for directional inputs
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

    # Return a structured mapping object
    return @{"mapping" = $mapping; "underlineMapping" = $underlineMapping; "motions" = $motions}
}

function Process-Token {
    param (
        [string]$token,
        [hashtable]$mappingData
    )

    $mapping = $mappingData["mapping"]
    $underlineMapping = $mappingData["underlineMapping"]
    $motions = $mappingData["motions"]

    # Check for "j." prefix and remove it temporarily for processing
    $isJump = $token.StartsWith("J.")
    if ($isJump) {
        $token = $token.Substring(2)  # Remove the "j." prefix
    }

    # Handle macro tokens like "drill"
    if ($token -eq "drill") {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']
        $underlineColor = $underlineMapping[$token]

        # Add "j." prefix back if applicable
        $prefix = ""
        if ($isJump) { $prefix = "j." }

        return @(
            "{{TvCUnderline|color=$underlineColor|$prefix$file}}",
            "{{TvC-Colors|$color|${prefix}LM->LM->MH}}"
        )
    }

    # Handle special tokens (e.g., BBQ, TK, SJC, XX)
    if ($mapping.ContainsKey($token)) {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']
        $underlineColor = $underlineMapping[$token]

        # Add "j." prefix back if applicable
        $prefix = ""
        if ($isJump) { $prefix = "j." }

        return @(
            "{{TvCUnderline|color=$underlineColor|$prefix$file}}",
            "{{TvC-Colors|$color|$prefix$token}}"
        )
    }

    # Handle mixed tokens (e.g., 236A, 236XX)
    if ($token -match "^([0-9]+)([A-Z]+)$") {
        $motion = $matches[1]
        $button = $matches[2]

        if ($motions.ContainsKey($motion) -and $mapping.ContainsKey($button)) {
            $motionFile = $motions[$motion]
            $buttonFile = $mapping[$button]['file']
            $buttonColor = $mapping[$button]['color']
            $underlineColor = $underlineMapping[$button]

            # Add "j." prefix back if applicable
            $prefix = ""
            if ($isJump) { $prefix = "j." }

            # Special case: 236XX maps to 236XX/236ATAT
            if ($button -eq "XX") {
                $groupedFile = "$motionFile $buttonFile"
                return @(
                    "{{TvCUnderline|color=$underlineColor|$prefix$groupedFile}}",
                    "{{TvC-Colors|$buttonColor|${prefix}${motion}$button}}"
                )
            }

            return @(
                "{{TvCUnderline|color=$underlineColor|$prefix$motionFile $buttonFile}}",
                "{{TvC-Colors|$buttonColor|${prefix}${motion}$button}}"
            )
        }
    }

    # Handle standalone motions
    if ($motions.ContainsKey($token)) {
        $motionFile = $motions[$token]
        # Add "j." prefix back if applicable
        $prefix = ""
        if ($isJump) { $prefix = "j." }

        return @("{{TvCUnderline|color=white|$prefix$motionFile}}", "{{TvC-Colors|white|$prefix$token}}")
    }

    # Return null if the token is unrecognized
    return @($null, $null)
}



# Main loop for user interaction
while ($true) {
   Write-Host "==================================================="
Write-Host "TvC Wiki Numpad Notation Converter"
Write-Host "==================================================="
Write-Host ""
Write-Host "Tutorial:"
Write-Host "This tool converts TvC numpad notation sequences into a super combo ready format for Tatsunoko Vs Capcom: Ultimate All Stars"
Write-Host ""
Write-Host "How to Use:"
Write-Host "1. Enter a sequence of inputs (e.g., A B 236C)."
Write-Host "2. Special commands can be used for advanced notations:"
Write-Host "   - 'charge': Represents a charging mechanic, outputs the appropriate image and color."
Write-Host "   - 'drill': A macro representing the sequence LM -> LM -> MH."
Write-Host "3. Mixed motions and inputs like 236XX are also supported."
Write-Host ""
Write-Host "Examples:"
Write-Host "A B C 236X outputs the icons for A B C with a hadouken motion and an attack icon, while also giving the numpad underneath"
Write-Host ""
Write-Host "Type 'exit' to quit the tool."
Write-Host ""


    $input = Read-Host "Enter a numpad notation sequence (e.g., A B 236C) or type 'exit' to quit"
    if ($input -eq "exit") { break }

    $mappingData = Get-Mapping
    $tokens = $input.ToUpper() -split ' '

    $notationResult = @()
    $colorResult = @()

    foreach ($token in $tokens) {
        $results = Process-Token -token $token -mappingData $mappingData

        if ($results[0] -ne $null) {
            # Append tab-like space (&emsp;) after each notation for better formatting
            $notationResult += "$($results[0]) &emsp;"
        }
        if ($results[1] -ne $null) {
            # Add tab-like spacing for color-coded output
            $colorResult += "$($results[1]) &emsp;"
        }
    }

    # Join results with tab-like spaces and trim trailing characters
    $notationOutput = ($notationResult -join '').TrimEnd('&emsp;')
    $colorOutput = ($colorResult -join '').TrimEnd('&emsp;')

    # Display formatted output
    Write-Host ""
	Write-Host "==================================================="
	Write-Host "Output"
	Write-Host "==================================================="
	Write-Host ""
    Write-Host "|notation= $notationOutput"
    Write-Host "`n$colorOutput"
    Write-Host ""
	Write-Host ""
	Write-Host "==================================================="
	Write-Host "Press enter to restart or type 'exit' to quit."
	Write-Host "==================================================="
    $pauseInput = Read-Host
    if ($pauseInput -eq "exit") { break }
}
