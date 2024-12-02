function Get-Mapping {
    param ([string]$token)

    # Define mappings
    $mapping = @{
        "A" = @{"color" = "blue"; "file" = "[[File:TVC-L.png|50px]]"}
        "B" = @{"color" = "yellow"; "file" = "[[File:TVC-M.png|50px]]"}
        "C" = @{"color" = "red"; "file" = "[[File:TVC-H.png|50px]]"}
        "P" = @{"color" = "green"; "file" = "[[File:TVC-P.png|50px]]"}
        "X" = @{"color" = "green"; "file" = "[[File:TVC-AT.png|50px]]"}
        "BBQ" = @{"color" = "bbq"; "file" = "[[File:TVC-BBQ.png|50px]]"}
        "TK" = @{"color" = "white"; "file" = "[[File:TVC-TK.png|50px]]"}
        "SJC" = @{"color" = "white"; "file" = "[[File:TVC-SJC.png|50px]]"}
    }

    $motions = @{
        "5" = "[[File:TVC-neutral.png|50px]]"
        "2" = "[[File:TVC-2.png|50px]]"
        "8" = "[[File:TVC-8.png|50px]]"
        "4" = "[[File:TVC-4.png|50px]]"
        "6" = "[[File:TVC-6.png|50px]]"
        "1" = "[[File:TVC-1.png|50px]]"
        "3" = "[[File:TVC-3.png|50px]]"
        "7" = "[[File:TVC-7.png|50px]]"
        "9" = "[[File:TVC-9.png|50px]]"
        "236" = "[[File:TVC-236.png|50px]]"
        "214" = "[[File:TVC-214.png|50px]]"
        "623" = "[[File:TVC-623.png|50px]]"
        "421" = "[[File:TVC-421.png|50px]]"
        "41236" = "[[File:TVC-41236.png|50px]]"
        "63214" = "[[File:TVC-63214.png|50px]]"
        "360" = "[[File:TVC-360.png|50px]]"
    }
	if ($token -eq "BBQ") {
    $color = "linear-gradient(to right, #FF69B4, #FF1493, #FFA500, #FFD700, #00CED1)"
    $file = "[[File:TVC-BBQ.png|50px]]"
    return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
}


    return @{"mapping" = $mapping; "motions" = $motions}
}

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

        # Special handling for BBQ with gradient
        if ($token -eq "BBQ") {
            $color = "linear-gradient(to right, #FF69B4, #FF1493, #FFA500, #FFD700, #00CED1)"
        }

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
            $notation = "{{TvCUnderline|color=$buttonColor|$motionFile $buttonFile}}"
            $color = "{{TvC-Colors|$buttonColor|$motion$button}}" # Include motion + button in TvC-Colors
            return @($notation, $color)
        }
    }

    # Handle standalone tokens (e.g., A, B, C)
    if ($mapping.ContainsKey($token)) {
        $file = $mapping[$token]['file']
        $color = $mapping[$token]['color']
        return @("{{TvCUnderline|color=$color|$file}}", "{{TvC-Colors|$color|$token}}")
    }

    # Handle standalone motions (e.g., 236, 214)
    if ($motions.ContainsKey($token)) {
        $motionFile = $motions[$token]
        $notation = "{{TvCUnderline|color=white|$motionFile}}" # Motions default to white
        $color = "{{TvC-Colors|white|$token}}"
        return @($notation, $color)
    }

    return @($null, $null) # Return null if not recognized
}


while ($true) {
    Write-Host "==================================================="
    Write-Host "TvC Wiki Numpad Notation Converter"
    Write-Host "==================================================="
    $input = Read-Host "Enter a numpad notation sequence (e.g., A B 236C) or type 'exit' to quit"

    if ($input -eq "exit") {
        break
    }

    # Load mapping data
    $mappingData = Get-Mapping

    # Tokenize the input
    $tokens = $input.ToUpper() -split ' '

    # Process each token
    $notationResult = @()
    $colorResult = @()

  # Process each token
foreach ($token in $tokens) {
    $results = Process-Token -token $token -mappingData $mappingData
    if ($results[0] -ne $null) {
        $notationResult += $results[0]
    }
    if ($results[1] -ne $null) {
        $colorResult += $results[1]
    }
}

# Output results
Write-Host "|notation= $($notationResult -join ' ')"
if ($colorResult.Count -gt 0) {
    Write-Host "`n$($colorResult -join ' &ensp; ')"
}

    Write-Host ""
}



