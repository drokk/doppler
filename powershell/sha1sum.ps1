Param ([switch]$md5, [switch]$sha256, $filename = '' )

if ($filename) # check if there is input 
    {   
        
    $filetypes = Get-ChildItem $filename -Recurse
        
    foreach ($filetype in $filetypes) {
        Write-Host $filetype.FullName - $filetype.Attributes
        if ($filetype.Attributes -ne "Directory") {

            $cryptohash = ''    # initiate 
            $sha1object = new-Object System.Security.Cryptography.SHA1Managed
            $md5object = new-Object System.Security.Cryptography.MD5CryptoServiceProvider
            $sha256object = new-Object System.Security.Cryptography.SHA256Managed 
            $file = [System.IO.File]::Open($filetype.FullName, "open", "read")

            if ($md5) {
                $md5object.ComputeHash($file) | ForEach-Object{
                        $cryptohash += $_.ToString("x2")}
            } elseif ($sha256) {
                $sha256object.ComputeHash($file) | ForEach-Object{
                        $cryptohash += $_.ToString("x2")}
            } else {
                $sha1object.ComputeHash($file) | ForEach-Object{
                        $cryptohash += $_.ToString("x2")}
            }

            Write-Host $filetype.FullName "has" $cryptohash 

            $file.Dispose()

            } else {
             # Write-Host "In folder " $filetype.Name
            }   
    }
} else {
        write-host "no file!"
}
