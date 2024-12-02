function Map-Notation {
    param (
        [string]$token
    )

    # Buttons with colors
    $mapping = @{
        "A" = @{"file" = "[[File:TVC-L.png|50px]]"; "color" = "blue"}
        "B" = @{"file" = "[[File:TVC-M.png|50px]]"; "color" = "yellow"}
        "C" = @{"file" = "[[File:TVC-H.png|50px]]"; "color" = "red"}
        "P" = @{"file" = "[[File:TVC-P.png|50px]]"; "color" = "green"}
        "X" = @{"file" = "[[File:TVC-AT.png|50px]]"; "color" = "purple"}
        "BBQ" = @{"file" = "[[File:TVC-BBQ.png|50px]]"; "color" = "BBQ"}
        "TK" = @{"file" = "[[File:TVC-TK.png|50px]]"; "color" = "TK"}
        "SJC" = @{"file" = "[[File:TVC-SJC.png|50px]]"; "color" = "SJC"}
    }

    # Directions (motions remain white)
    $mapping += @{
        "5" = @{"file" = "[[File:TVC-neutral.png|50px]]"; "color" = "white"}
        "2" = @{"file" = "[[File:TVC-2.png|50px]]"; "color" = "white"}
        "8" = @{"file" = "[[File:TVC-8.png|50px]]"; "color" = "white"}
        "4" = @{"file" = "[[File:TVC-4.png|50px]]"; "color" = "white"}
        "6" = @{"file" = "[[File:TVC-6.png|50px]]"; "color" = "white"}
        "1" = @{"file" = "[[File:TVC-1.png|50px]]"; "color" = "white"}
        "3" = @{"file" = "[[File:TVC-3.png|50px]]"; "color" = "white"}
        "7" = @{"file" = "[[File:TVC-7.png|50px]]"; "color" = "white"}
        "9" = @{"file" = "[[File:TVC-9.png|50px]]"; "color" = "white"}
        "236" = @{"file" = "[[File:TVC-236.png|50px]]"; "color" = "white"}
        "214" = @{"file" = "[[File:TVC-214.png|50px]]"; "color" = "white"}
        "623" = @{"file" = "[[File:TVC-623.png|50px]]"; "color" = "white"}
        "421" = @{"file" = "[[File:TVC-421.png|50px]]"; "color" = "white"}
        "41236" = @{"file" = "[[File:TVC-41236.png|50px]]"; "color" = "white"}
        "63214" = @{"file" = "[[File:TVC-63214.png|50px]]"; "color" = "white"}
        "360" = @{"file" = "[[File:TVC-360.png|50px]]"; "color" = "white"}
    }

    # Split mixed tokens (e.g., 236A)
    if ($token -match "^([0-9]+)([A-Z]+)$") {
        $direction = $matches[1]
        $button = $matches[2]
        return "{{TvCUnderline|color=$($mapping[$direction]['color'])|$($mapping[$direction]['file'])}} {{TvCUnderline|color=$($mapping[$button]['color'])|$($mapping[$button]['file'])}}"
    }

    # Map simple tokens
    return "{{TvCUnderline|color=$($mapping[$token]['color'])|$($mapping[$token]['file'])}}"
}



function Prompt-MotionNames {
    param (
        [array]$motions
    )
    $motionNames = @{}

    foreach ($motion in $motions) {
        $name = Read-Host "Enter a name for $motion (leave blank to keep as $motion)"
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = $motion
        }

        $isGreen = Read-Host "Should $name be green? (yes/no)"
        if ($isGreen -match "^(yes|y)$") {
            $motionNames[$motion] = "green|$name"
        } else {
            $motionNames[$motion] = "default|$name"
        }
    }

    return $motionNames
}

while ($true) {
    Write-Host "==================================================="
    Write-Host "TvC Wiki Numpad Notation Converter"
    Write-Host "==================================================="
    $input = Read-Host "Enter a numpad notation sequence (e.g., A B 236C) or type 'exit' to quit"

    if ($input -eq "exit") {
        break
    }

    # Convert input to uppercase
    $inputUpper = $input.ToUpper()

    # Tokenize the input
    $tokens = $inputUpper -split ' '

    # Extract unique motions (exclude single numbers like 2, 6 and 'X')
    $motionTokens = @()
    foreach ($token in $tokens) {
        if ($token -match "^([0-9]{3,})([A-Z]*)$") {
            $motion = $matches[1]
            if (-not ($motionTokens -contains $motion)) {
                $motionTokens += $motion
            }
        }
    }

    # Prompt for motion names and colors
    $motionNames = Prompt-MotionNames -motions $motionTokens

    # Process tokens and build result
    $notationResult = @()
    $colorResult = @()
foreach ($token in $tokens) {
    # Map to file notation
    $mapped = Map-Notation -token $token
    if ($null -ne $mapped) {
        $notationResult += $mapped
    }

    # Handle TvC-Colors for motions
    if ($token -match "^([0-9]+)([A-Z]*)$" -and $token -notmatch "^X$") {
        $motion = $matches[1]
        $button = $matches[2]
        if ($motionNames.ContainsKey($motion)) {
            $colorMapping = $motionNames[$motion]
            $parts = $colorMapping -split '\|'
            $color = $parts[0]
            $name = $parts[1]

            # Assign button-based color if not green
            if ($color -eq "default") {
                if ($button -eq "A") {
                    $color = "blue"
                } elseif ($button -eq "B") {
                    $color = "yellow"
                } elseif ($button -eq "C") {
                    $color = "red"
                }
            }

            if ($button -ne "") {
                $name = "$name $button" # Format as "{definition} {strength}"
            }

            # Wrap with TvCUnderline
            $colorResult += "{{TvC-Colors|$color|$name}}"
        }
    } elseif ($token -eq "X") {
        # Map X directly to a color and name, wrapped with TvCUnderline
        $colorResult += "{{TvC-Colors|purple|Assist}}"
    } elseif ($token -match "A$") {
        $colorResult += "{{TvC-Colors|blue|$token}}"
    } elseif ($token -match "B$") {
        $colorResult += "{{TvC-Colors|yellow|$token}}"
    } elseif ($token -match "C$") {
        $colorResult += "{{TvC-Colors|red|$token}}"
    }
}

    # Output the result
    Write-Host "|notation= $($notationResult -join ' ')"
    if ($colorResult.Count -gt 0) {
        Write-Host "`n$($colorResult -join ' &ensp; ')"
    }
    Write-Host ""
}
