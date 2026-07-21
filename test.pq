/*
NormalizeText
Purpose:
- Normalize whitespace in a text value.
- Trim leading and trailing whitespace, replace non-breaking spaces and tabs with regular spaces,
  and collapse multiple internal spaces into a single space.

Parameters:
- txt (nullable text): input text to normalize.

Returns:
- nullable text: normalized text or null if input is null.

Example:
- NormalizeText(" BUS  101 ") => "BUS 101"
*/
// Main function definition: accepts nullable text and returns nullable text
let
    NormalizeText = (txt as nullable text) as nullable text =>
        let
            // Step 1: Normalize characters and whitespace characters to regular spaces
            // If input is null, preserve null
            Cleaned =
                if txt = null then
                    null
                else
                    // Use Text.Clean to remove non-printable control characters (keeps printable characters)
                    // Replace non-breaking space (char code 160) with a regular space
                    // Replace tab (char code 9) with a regular space
                    Text.Replace(
                        Text.Replace(Text.Clean(txt), Character.FromNumber(160), " "), Character.FromNumber(9), " "
                    ),
            // Step 2: Trim leading/trailing spaces and collapse multiple internal spaces
            Result =
                if Cleaned = null then
                    null
                else
                    Text.Combine(
                        List.Select(
                            Text.Split(Text.Trim(Cleaned), " "), each _ <> ""
                            // remove empty tokens produced by consecutive spaces
                        ), " "
                        // join tokens with a single space
                    )
        in
            Result
in
    NormalizeText
