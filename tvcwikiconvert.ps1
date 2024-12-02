function Get-Mapping {
    param ([string]$token)
    $imageSize = "30px"  # Adjustable size for image files

    # Define button mappings for unified colors and file paths
    $mapping = @{
        "A" = @{color="yellow"; file="[[File:TVC-L.png|$imageSize]]"}    # Light attack
        "B" = @{color="green"; file="[[File:TVC-M.png|$imageSize]]"}     # Medium attack
        "C" = @{color="blue"; file="[[File:TVC-H.png|$imageSize]]"}      # Heavy attack
        "P" = @{color="red"; file="[[File:TVC-P.png|$imageSize]]"}       # Partner/Assist
        "X" = @{color="purple"; file="[[File:TVC-AT.png|$imageSize]]"}   # Special action
        "XX" = @{color="purple"; file="[[File:TVC-AT.png|$imageSize]] [[File:TVC-AT.png|$imageSize]]"} # Double special
        "BBQ" = @{color="gradient"; file="[[File:TVC-baroque.png|80px]]"} # Burst mechanics
        "TK" = @{color="gray"; file="[[File:TVC-TK.png|$imageSize]]"}    # Tiger Knee motion
        "SJC" = @{color="cyan"; file="[[File:TVC-SJC.png|$imageSize]]"}  # Super Jump Cancel
        "drill" = @{color="pink"; file="[[File:TVC-L.png|$imageSize]] [[File:TVC-M.png|$imageSize]] -> [[File:TVC-L.png|$imageSize]] [[File:TVC-M.png|$imageSize]] -> [[File:TVC-M.png|$imageSize]] [[File:TVC-H.png|$imageSize]]"}
        "charge" = @{color="white"; file="[[File:TVC-charge.png|50px]]"} # Charge command (inherits color from button grouping)
        "hold" = @{color="orange"; file="[[File:TvC-hold.png|75px]]"} # Hold down
        "release" = @{color="purple"; file="[[File:TVC-Release.png|50px]]"} # Release button
    }

    # Define special underline colors (same as numpad colors)
    $underlineMapping = @{
        "A" = "yellow"   # Light attack
        "B" = "green"    # Medium attack
        "C" = "blue"     # Heavy attack
        "P" = "red"      # Partner/Assist
        "X" = "purple"   # Special action
        "XX" = "purple"  # Double special
        "BBQ" = "linear-gradient(90deg, red, orange, yellow, green, blue, indigo, violet)" # Rainbow gradient
        "TK" = "gray"    # Tiger Knee motion
        "SJC" = "cyan"   # Super Jump Cancel
        "drill" = "pink" # Drill macro
        "charge" = "white" # Charge motion, overrides when grouped
        "hold" = "orange" # Hold down
        "release" = "purple" # Release button
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

    # Handle grouped motions with buttons (e.g., 66, 66A, 22, 22C, etc.)
    if ($token -match "^(22|66|44)([A-Z]*)$") {
        $motion = $matches[1]
        $button = $matches[2]

        $motionFile = "$($motions[$motion.Substring(0, 1)]) $($motions[$motion.Substring(0, 1)])" # Duplicate motion file

        # If there's a button (e.g., 66A, 22C)
        if ($button -ne "") {
            if ($mapping.ContainsKey($button)) {
                $buttonFile = $mapping[$button]['file']
                $buttonColor = $mapping[$button]['color']
                $underlineColor = $underlineMapping[$button]

                # Add "j." prefix back if applicable
                $prefix = ""
                if ($isJump) { $prefix = "j." }

                return @(
                    "{{TvCUnderline|color=$underlineColor|$prefix$motionFile $buttonFile}}",
                    "{{TvC-Colors|$buttonColor|${prefix}${motion}$button}}"
                )
            }
        } else {
            # Handle standalone 66, 22, 44
            return @(
                "{{TvCUnderline|color=white|$motionFile}}",
                "{{TvC-Colors|white|$motion}}"
            )
        }
    }

    # Handle charge groups (e.g., 2charge8, 4charge6, etc.)
    if ($token -match "^([0-9])charge([0-9])([A-Z]*)$") {
        $startDirection = $matches[1]
        $endDirection = $matches[2]
        $button = $matches[3]

        if ($motions.ContainsKey($startDirection) -and $motions.ContainsKey($endDirection)) {
            $startFile = $motions[$startDirection]
            $endFile = $motions[$endDirection]
            $chargeFile = $mapping["charge"]['file']
            $chargeColor = $mapping["charge"]['color']

            $prefix = ""
            if ($isJump) { $prefix = "j." }

            # If there's a button (e.g., 4charge6A)
            if ($button -ne "") {
                if ($mapping.ContainsKey($button)) {
                    $buttonFile = $mapping[$button]['file']
                    $buttonColor = $mapping[$button]['color']

                    return @(
                        "{{TvCUnderline|color=$buttonColor|$prefix$startFile $chargeFile $endFile $buttonFile}}",
                        "{{TvC-Colors|$buttonColor|${prefix}${startDirection}charge${endDirection}$button}}"
                    )
                }
            } else {
                # Handle standalone charge (e.g., 4charge6)
                return @(
                    "{{TvCUnderline|color=$chargeColor|$prefix$startFile $chargeFile $endFile}}",
                    "{{TvC-Colors|$chargeColor|${prefix}${startDirection}charge${endDirection}}}"
                )
            }
        }
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
    $underlineColor = $underlineMapping[$token] # Fetch the underline color, now includes gradient

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
	# Handle "Hold Down" and "Release" commands
if ($token -match "^(hold|release)([A-Z]*)$") {
    $command = $matches[1]
    $button = $matches[2]

    $file = $mapping[$command]['file']
    $color = $mapping[$command]['color']
    $underlineColor = $underlineMapping[$command]

    if ($button -ne "") {
        if ($mapping.ContainsKey($button)) {
            $buttonFile = $mapping[$button]['file']
            $buttonColor = $mapping[$button]['color']
            $buttonUnderlineColor = $underlineMapping[$button]

            return @(
                "{{TvCUnderline|color=$underlineColor|$file $buttonFile}}",
                "{{TvC-Colors|$buttonColor|$command$button}}"
            )
        }
    }

    return @(
        "{{TvCUnderline|color=$underlineColor|$file}}",
        "{{TvC-Colors|$color|$command}}"
    )
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
Write-Host "==================================================="
Write-Host "==================================================="
Write-Host "==================================================="
Write-Host "Look I know this is a lot I'm about to just put all this on a wiki page and reference the hyperlink here momentarily"
Write-Host "==================================================="
Write-Host "==================================================="
Write-Host "==================================================="
Write-Host "==================================================="
Write-Host ""
Write-Host "Tutorial:"
Write-Host "This tool converts TvC numpad notation sequences into a super combo-ready format for Tatsunoko vs. Capcom: Ultimate All Stars."
Write-Host ""
Write-Host "How to Use:"
Write-Host "1. Enter a sequence of inputs using standard TvC numpad notation (e.g., A B 236C)."
Write-Host "2. Use the following commands for advanced inputs:"
Write-Host ""
Write-Host "   Charge Commands:"
Write-Host "   - Use 'charge' to represent charging motions combined with directions."
Write-Host "     Example: 4charge6 outputs as a grouped charge motion from back to forward."
Write-Host "     Example: 2charge8 outputs as a grouped charge motion from down to up."
Write-Host "     You can also group charge with a button:"
Write-Host "     Example: 4charge6A outputs the grouped charge motion combined with a Light (L) attack."
Write-Host ""
Write-Host "   Directional Groupings:"
Write-Host "   - Inputs like 22, 66, or 44 represent repeated directional motions."
Write-Host "     Example: 66 outputs a double forward motion."
Write-Host "     Example: 22C outputs a repeated down motion combined with a Heavy (H) attack."
Write-Host "   - You can also prefix motions with 'j.' to represent jumping motions."
Write-Host "     Example: j.66 outputs a double forward motion while jumping."
Write-Host "     Example: j.22C outputs a repeated down motion combined with a Heavy (H) attack while jumping."
Write-Host ""
Write-Host "   Special Commands:"
Write-Host "   - 'drill': Outputs a macro representing the sequence LM -> LM -> MH."
Write-Host "     Example: drill outputs the entire sequence grouped."
Write-Host "   - 'BBQ': Outputs the Burst mechanic with its gradient color and icon."
Write-Host ""
Write-Host "Examples:"
Write-Host "   Input: A B C 236X"
Write-Host "   Output: Icons and numpad notation for Light (A), Medium (B), Heavy (C), and a Hadouken motion with a Special (X) action."
Write-Host ""
Write-Host "   Input: 4charge6B"
Write-Host "   Output: Icons and numpad notation for a charge motion from back to forward combined with a Medium (M) attack."
Write-Host ""
Write-Host "   Input: j.22C"
Write-Host "   Output: Icons and numpad notation for a repeated down motion combined with a Heavy (H) attack while jumping."
Write-Host ""
Write-Host "   Input: drill"
Write-Host "   Output: Icons and notation for LM -> LM -> MH macro."
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
