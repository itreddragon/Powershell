$paramHash = @{
    Name = 'NA-WEB1'
    SourcePath = 'C:\Training\FourthStreetWebsite'
    DestinationPath = 'C:\Bakery'
    CreateFullPath = $True
    FileSource = 'Host'
    Force = $True
    Verbose = $True
}
$SourceBasePath = 'C:\Training\FourthStreetWebsite'
$DestinationBasePath = 'C:\Bakery'

$Files = Get-ChildItem -Path "C:\Training\FourthStreetWebsite" -Attributes !Directory -Recurse

Foreach ($File in $Files) {
    $Destination = Join-path -Path $paramHash.DestinationPath -ChildPath $File.FullName.Substring($paramHash.SourcePath.Length)
    Write-Host "copying $($File.fullname) to $Destination" -Foreground Yellow
    $paramHash.SourcePath = $File.fullname
    $paramHash.DestinationPath = $Destination

    Copy-VMFile @paramHash
    $paramHash.SourcePath = $SourceBasePath
    $paramHash.DestinationPath = $DestinationBasePath
}