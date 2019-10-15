<#
.Synopsis 

creates file system inventories. 

.Description 

Inventories a file tree so you can detect changes at a later date, saves the state in 
file <name of the server>-<hash of root of the file system>-hash-table in the users home
folder. 

.PARAMETER path

root of the file tree that needs to be inventoried. 

.PARAMETER datafile

name of the data file saved in the users home folder, the default is hash-table

.PARAMETER compare

currently unused


#>
Param (
    [string]$path,
    [string]$datafile= "hash-table",
    [string]$compare
)


 
# this function is a modified version of http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-Hashx([switch] $file, [String] $String,$HashName = "SHA1") 
{ 
    $StringBuilder = New-Object System.Text.StringBuilder
    
    if ($file) # if we are sending a file location to the the function then we have to open the file to gather contents so we can create a hash of the content 
        {
            $file_content = [System.IO.File]::Open($String, "open", "read") # reads the file 
            
            [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash($file_content)|%{ 
                [Void]$StringBuilder.Append($_.ToString("x2")) 
            }    
            
            $file_content.dispose() # closes the file 
    
        }  else {
                [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
                    [Void]$StringBuilder.Append($_.ToString("x2")) 
                }    
        }
    $StringBuilder.ToString() 
}

# this function looks through the old file inventory and detects any changes 
Function record_search ($record,$old_records)
{
    
$new_id = $record.id 
$new_signature = $record.signature
$new_file_name = $record.file_name 
foreach ($old_record in $old_records) {
    $old_id = $old_record.id 
    $old_signature = $old_record.signature
    $old_file_name = $old_record.file_name  
    if (($old_signature -cnotcontains $new_signature) -and ($old_id -ccontains $new_id))
        {Write-Host "$old_file_name has changed"} 
    elseif (($old_signature -contains $new_signature) -and ($old_id -cnotcontains $new_id)) 
        {
            # need to traverse the known file table again to check if the dupe files is already known. 
            foreach ($old_record in $old_records) { 
                if (($old_record.signature -contains $new_signature) -and ($old_record.id -contains $new_id))
                    {$known_dupe = 1}           
                }
            if ($known_dupe -eq 0)
            {{Write-Host "$new_file_name may be a copy of $old_file_name"}}
        }
        
}

}

# this function finds inventory changes in the new and old file inventory (ie file additions and deletions)

Function file_inventory_check($new, $old)
{
 $results = Compare-Object $new.id $old.id 
 foreach ($result in $results) {
     [string]$SideIndicator = $result.SideIndicator
     [string]$changed_id = $result.InputObject  
     if($SideIndicator -contains "<=") # entry is only in the old file inventory, ie deleted file 
        {
            $changes = $new| ?{ $_.id -contains $changed_id}
             
        foreach ($change in $changes) {
        Write-Host "$($change.file_name) has been added."}}
        
    elseif ($SideIndicator -contains "=>") # entry is only the new file inventory, ie added file
       {
        $changes = $old | ?{ $_.id -contains $changed_id }
           
        foreach ($change in $changes) {
        Write-Host "$($change.file_name) has been deleted."}}
    } 
}


$uri = New-Object System.URI($path)
if($uri.Host)
    {$host_id = $uri.Host} # capture the remote machines name 
    else
    {$host_id = $(gci env:/Computername).value} # capture the local machine 

$path_id = Get-Hashx $path # need unique id for the file tree 

$directory = Get-ChildItem $path -Recurse #capture the desired file tree

$datafile = $host_id + "-" + $path_id + "-" + $datafile

if (Test-Path $home\$datafile){ $old_file_inventory = Import-Csv $home\$datafile} #only load the datafile if it exists. 

$files =  $directory | where {($_.extension -eq '.ps1' -or $_.extension -eq '.exe' -or $_.extension -eq ".dll" -or $_.extension -eq ".config" -or $_.Attributes -contains "Directory")} # finds all files with exes in user supplied path. 
#$folders = $directory | where {($_.Attributes -contains "Directory")}
$current_file_inventory = @() 
foreach ($file in $files) {
    $file_objects = New-Object psobject

    $hash_id = Get-Hashx -String $file.FullName # create a SHA1 hash of the the path to the file 
    
    if ($file.Attributes -contains "Directory")
        {$hash_signature = $hash_id} # temporary fix for directory support
       else
        {$hash_signature = Get-Hashx -file -String $file.Fullname}  # create a SHA1 hash of content of the file 
    
    
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name id -Value $hash_id 
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name file_name -Value $file.FullName
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name signature -Value $hash_signature
    if($old_file_inventory) {record_search -record $file_objects -old_records $old_file_inventory} 
    $current_file_inventory += $file_objects 
}


if($old_file_inventory) {file_inventory_check -new $current_file_inventory -old $old_file_inventory} 

$current_file_inventory | Export-Csv -NoTypeInformation $home\$datafile


