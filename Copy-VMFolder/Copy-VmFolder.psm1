Function Copy-ItrdVMFolder {
<#
    .SYNOPSIS
        Copies a folder structure, including files, from the host to a VM on that host.
    .DESCRIPTION
        Copies the files from the Source Path on the host to the given Destination on the named VM on that host. 
        Entire folder structure is recreated automatically.  
    .PARAMETER VMName
        One or more VMs on the host to copy the files to. 
        NOTE: The "Guest" integration service MUST be running on the VM(s).
    .PARAMETER SourcePath
        The path of the folder on the host that the files are to be copied from.
    .PARAMETER DestinationPath
        The path of the folder on the VM(s) that the files are to be copied to.
    .EXAMPLE
        Copy-ItrdVMFolder -VMName VM-SRV1,VM-WIN10 -SourcePath "C:\FilesToBeCopied" -DestinationPath "C:\DestinationFolder"

        Files are coipied from the "C:\FilesToBeCopied: folder on the host to the "C:\DestinationFolder" on the two VMs VM-SRV1 and VM-WIN10
#>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$True,
                   ValueFromPipelinebyPropertyName=$True)]
        [string[]]$VMName,
        
        [Parameter (Mandatory=$True,
                    ValueFromPipeLinebyPropertyName=$True)]
        [string]$SourcePath,

        [Parameter (Mandatory=$True,
                    ValueFromPipeLinebyPropertyName=$True)]
        [string]$DestinationPath
    )

    BEGIN {}

    PROCESS {
        Foreach ($VM in $VMName) {
            #Ensure that the VM is Started
            $VMState = Get-VM -Name $VM -ErrorAction SilentlyContinue
            If ($VMState.State -eq "Running") {

                #Ensure that the Guest Integration Services are running on the VM
                $GuestState = Get-VMIntegrationService -VMName $VM -Name "Guest*"
            
                If ($GuestState.Enabled) {
                    $paramHash = @{
                        Name = $VM
                        SourcePath = $SourcePath
                        DestinationPath = $DestinationPath
                        CreateFullPath = $True
                        FileSource = 'Host'
                        Force = $True
                        Verbose = $False
                    } #paramHash

                    $SourceBasePath = $SourcePath
                    $DestinationBasePath = $DestinationPath

                    # Enable Verbose on the Copy-VMFile cmdlet if specified 
                    If ($PSBoundParameters.ContainsKey("Verbose")) {
                        $paramHash.Verbose = $True
                    } #IF - Verbose is Set

                    # Note: Only the files are being returned. Directories are excluded. That info is coming from the path of the file
                    $Files = Get-ChildItem -Path $SourcePath -Attributes !Directory -Recurse

                    Foreach ($File in $Files) {
                        $Destination = Join-path -Path $paramHash.DestinationPath -ChildPath $File.FullName.Substring($paramHash.SourcePath.Length)
                        Write-Verbose "copying $($File.fullname) to $Destination on $VM"
                        $paramHash.SourcePath = $File.fullname
                        $paramHash.DestinationPath = $Destination

                        Copy-VMFile @paramHash
                        $paramHash.SourcePath = $SourceBasePath
                        $paramHash.DestinationPath = $DestinationBasePath
                    } # Foreach File

                } else {
                    Write-Warning "Copy Failed: Guest Service is not Enabled on VM - $VM"
                } #IF - VM GUest Service is Enabled on VM

            } else {
                Write-Warning "Copy Failed: VM - $VM - is not started"
            } #IF - VM iS ON

        } #Foreach VM
    } #PROCESS

    END {}
} #Function

Export-ModuleMember -Function Copy-ItrdVMFolder