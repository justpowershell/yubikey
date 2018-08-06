function Format-ModHex {
    <#
    .SYNOPSIS
    Convert a string of hexadecimal characters into a Yubikey's MODHEX format
    .DESCRIPTION
    The Modified Hexadecimal encoding scheme was invented to cope with potential keyboard mapping ambiguities, namely the 
    inconstant locations of keys between different keyboard layouts. The YubiKey uses this special data encoding format 
    known as "modhex" rather than normal hex encoding or base64 encoding. ModHex is similar to hex encoding but with a 
    different encoding alphabet. The reason is to achieve a keyboard layout independent encoding. This script will take a
    HEX string and convert it to MODHEX.
    .PARAMETER String 
    A HEX-formatted string of characters. Note, Yubikey's static password supports a default maximum of 32 characters. 
    .EXAMPLE
    Convert "abcdef1234" to MODHEX
    Format-Modhex "abcdef1234"
    .NOTES
    Because I use an ordered hashtable, Powershell 3.0 or greater is needed.
    Modhex character conversion map can be found at https://developers.yubico.com/yubikey-personalization/Manuals/ykpersonalize.1.html
    Testing conversion can be found at https://demo.yubico.com/modhex.php
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
            If ($_ -match "^[a-fA-F0-9\s]+$") {
                $True
            } else {
                Throw "$_ is not a valid HEX string. Please convert to HEX before formatting to MODHEX"
            }
        })]
        [string]$string
    )
    $conversiontable = [ordered]@{
        "f" = "v"
        "e" = "u"
        "d" = "t"
        "c" = "r"
        "b" = "n"
        "a" = "l"
        "0" = "c"
        "1" = "b"
        "2" = "d"
        "3" = "e"
        "4" = "f"
        "5" = "g"
        "6" = "h"
        "7" = "i"
        "8" = "j"
        "9" = "k"
    }
    $regexes = $conversiontable.keys | foreach {[System.Text.RegularExpressions.Regex]::Escape($_)}
    $regex = [regex]($regexes -join '|')

    $callback = { $conversiontable[$args[0].Value] }
    return $regex.Replace($string.ToLower(), $callback)
}
