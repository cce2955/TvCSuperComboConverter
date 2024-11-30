# TvC Wiki Converter

A script designed to assist in converting fighting game numpad notations into TvC (Tatsunoko vs. Capcom) Wiki-compatible formats. The script supports defining special motion inputs, strength-based colors, and outputting in the proper TvC Wiki syntax.

---

## Features

- Converts numpad notation (e.g., `236A`) into formatted Wiki output.
- Handles special motions like `236`, `214`, and more, allowing user-defined names and custom colors.
- Automatically applies strength-based colors for `A`, `B`, and `C` buttons.
- Supports custom `TvC-Colors` formatting in the `{definition} {strength}` style.

---

## Requirements

- **PowerShell**: The script is written in PowerShell and should run on any system with PowerShell installed (Windows, macOS, Linux).

---

## Installation

1. Download the `tvcwikiconvert.ps1` script.
2. Save it to a directory of your choice.

---

## Usage

### Running the Script

1. Open a terminal (PowerShell).
2. Navigate to the directory containing the script:
   ```
   cd path\to\script
   ```
3. Run the script:
   ```
   .\tvcwikiconvert.ps1
   ```

### Input Format

The script expects a sequence of numpad notations. For example:

```
A B 236A BBQ TK SJC 214C
```

---

### Output Example

#### Input:
```
A B 236A 214C
```

#### Prompts:
```
Enter a name for 236 (leave blank to keep as 236): hado
Should hado be green? (yes/no): n

Enter a name for 214 (leave blank to keep as 214): tatsu
Should tatsu be green? (yes/no): y
```

#### Result:
```
|notation= [[File:TVC-L.png|50px]] [[File:TVC-M.png|50px]] [[File:TVC-236.png|50px]] [[File:TVC-L.png|50px]] [[File:TVC-214.png|50px]] [[File:TVC-H.png|50px]]

{{TvC-Colors|blue|A}} &ensp; {{TvC-Colors|yellow|B}} &ensp; {{TvC-Colors|default|hado A}} &ensp; {{TvC-Colors|green|tatsu C}}
```

---

### Features in Detail

#### Strength-Based Colors:

- Automatically assigns colors based on button strength:
  - `A`: Blue
  - `B`: Yellow
  - `C`: Red

#### Customizable Motions:

- Prompts the user for special motions like `236` or `214`:
  - Assign a custom name (e.g., `hado`, `tatsu`).
  - Choose whether the motion should appear green in the Wiki.

#### Numpad to Wiki Conversion:

- Converts `236A` into Wiki-compatible syntax with proper formatting.

---

## Known Limitations

- Does not handle improperly formatted input (e.g., missing spaces between tokens).
- Case-sensitive input may require adjustment (e.g., `a` vs. `A`).

---

## Contributing

Feel free to suggest features or report bugs. Fork the repository and submit a pull request with your changes.

---

## License

This script is open-source and provided under the MIT License. Use it as you see fit!
