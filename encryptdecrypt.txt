function Get-DecryptedValuesFromFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$EncryptionKey
    )
    
    # Read the file contents
    $fileContents = Get-Content -Path $FilePath -Raw
    
    # Define the regular expression pattern
    $pattern = 'cryptdata="([^"]+)"'
    
    # Use the regular expression to find matches in the file contents
    $matches = [regex]::Matches($fileContents, $pattern)
    
    # Loop through the matches and extract the captured group
    $encryptedValues = foreach ($match in $matches) {
        $match.Groups[1].Value
    }
    
    # Try to decrypt each encrypted value using the Decrypt-String function
    $decryptedValues = foreach ($encryptedValue in $encryptedValues) {
        try {
            Decrypt-String -EncryptedValue $encryptedValue -EncryptionKey $EncryptionKey
        }
        catch {
            Write-Error "Error decrypting value: $_"
        }
    }
    
    # Return the decrypted values
    return $decryptedValues
}
