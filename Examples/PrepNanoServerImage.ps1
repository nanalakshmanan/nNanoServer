$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$WorkingFolder = 'D:\Nana\Test'

configuration PrepNanoServerImage
{
    Import-DscResource -ModuleName nNanoServer

    node $AllNodes.NodeName
    {
        foreach($ComputerName in $Node.ComputerName)
        {
            nNanoServerImage "Image_$ComputerName"
            { 
                Name                       = "Image_$ComputerName"
                MediaPath                  = $Node.MediaPath
                BasePath                   = $Node.BasePath
                TargetPath                 = "$($Node.TargetPathRoot)\$($Node.ComputerName).vhdx"
                ComputerName               = $ComputerName
                DomainName                 = $Node.DomainName
                EnableCompute              = $true
                EnableStorage              = $true
                EnableClustering           = $true
                InstallDrivers             = $true
                EnableRemoteManagementPort = $true
                ReuseDomainNode            = $true
                DeploymentType             = 'Host'
                Edition                    = 'Datacenter'
                AdministratorPassword      = $Node.AdministratorPassword
            }
        }
    }
}

$ConfigData = (& "$ScriptPath\PrepNanoServerImage.ConfigData.ps1")

Remove-Item -Recurse -Force "$WorkingFolder\CompiledConfigurations\PrepNanoServerImage" 2> $null
PrepNanoServerImage -OutputPath "$WorkingFolder\CompiledConfigurations\PrepNanoServerImage" -verbose -ConfigurationData $ConfigData

Start-DscConfiguration -Wait -Force -Path "$WorkingFolder\CompiledConfigurations\PrepNanoServerImage" -Verbose