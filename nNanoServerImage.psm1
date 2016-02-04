[DscResource()]
class nNanoServerImage
{
    [DscProperty(Key)]
    [string]
    $Name

    [DscProperty(Mandatory)]
    [string]
    $MediaPath

    [DscProperty(Mandatory)]
    [string]
    $BasePath

    [DscProperty(Mandatory)]
    [string]
    $TargetPath

    [DscProperty(Mandatory)]
    [string]
    $ComputerName

    [DscProperty(Mandatory)]
    [string]
    $DomainName

    [DscProperty()]
    [bool]
    $EnableCompute

    [DscProperty()]
    [bool]
    $EnableStorage

    [DscProperty()]
    [bool]
    $EnableClustering

    [DscProperty()]
    [bool]
    $EnableRemoteManagementPort

    [DscProperty()]
    [bool]
    $ReuseDomainNode

    [DscProperty()]
    [bool]
    $InstallDrivers

    [DscProperty()]
    [ValidateSet('Guest', 'Host')]
    [string]
    $DeploymentType

    [DscProperty()]
    [ValidateSet('Standard', 'Datacenter')]
    [string]
    $Edition

    [DscProperty(Mandatory)]
    [PSCredential]
    $AdministratorPassword

    [bool] Test()
    {
        $this.AssertPrerequisite()

        return $false
    }

    [void] Set()
    {
        #Wait-Debugger

        $this.AssertPrerequisite()

        if (! (Test-Path $this.MediaPath))
        {
            throw "Cannot find $($this.MediaPath)"
        }

        if (! (Test-Path $this.BasePath) )
        {
            Write-Verbose "Creating $($this.BasePath)"
            mkdir $this.BasePath | Out-Null
        }

        if (Test-Path $this.TargetPath)
        {
            Write-Verbose "Deleting existing $($this.TargetPath)"
            rmdir -Force $this.TargetPath
        }

        $MountPoint = $null
        $DriveLetter = $null
        try
        {
            Write-Verbose "Mounting image $($this.MediaPath)"
            #Wait-Debugger
            Import-Module Storage -Verbose:$false -Force

            #Wait-Debugger
            $MountPoint = Mount-DiskImage -ImagePath $this.MediaPath -PassThru
            #$MountPoint 

            $DriveLetter = ($MountPoint | Get-Volume).DriveLetter
            Write-Verbose "Drive letter of mounted image is $DriveLetter"

            #Start-Sleep -Seconds 10
            try
            {
                dir "$($DriveLetter):\" | Write-Verbose
            }
            catch
            {
                Write-Verbose "EXCEPTION"
                throw
            }

            Write-Verbose "Importing NanoServerImageGenerator module from $DriveLetter"
            Import-Module "$($DriveLetter):\NanoServer\NanoServerImageGenerator\NanoServerImageGenerator.psd1" -Verbose:$false

            New-NanoServerImage -MediaPath "$($DriveLetter):\" `
                                -BasePath $this.BasePath `
                                -TargetPath $this.TargetPath `
                                -ComputerName $this.ComputerName `
                                -DomainName $this.DomainName `
                                -Compute:$this.EnableCompute `
                                -Storage:$this.EnableStorage `
                                -Clustering:$this.EnableClustering `
                                -OEMDrivers:$this.InstallDrivers `
                                -EnableRemoteManagementPort:$this.EnableRemoteManagementPort `
                                -ReuseDomainNode:$this.ReuseDomainNode `
                                -DeploymentType $this.DeploymentType `
                                -Edition $this.Edition `
                                -AdministratorPassword $this.AdministratorPassword.Password
        }
        finally
        {
            Write-Verbose "Dismounting $($this.MediaPath)"
            Dismount-DiskImage $MountPoint.ImagePath
        }
    }

    [nNanoServerImage] Get()
    {
        $this.AssertPrerequisite()

        return $this
    }

    [void] AssertPrerequisite()
    {

        if ([environment]::OSVersion.Version.Major -lt 10)
        {
            throw 'Creating Nano Server image requires Windows 10 or Windows Server 2016'
        }
    }
}
