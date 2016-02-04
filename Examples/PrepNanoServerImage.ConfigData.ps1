$Credential = Get-Credential administrator

@{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            #ComputerName = @('RR4-S5R2SSU-09', 'RR4-S5R2SSU-10', 'RR4-S5R2SSU-11', 'RR4-S5R2SSU-12')
            ComputerName = @('RR4-S5R2SSU-09')
            DomainName = 'threshold.nttest.microsoft.com'
            AdministratorPassword = $Credential
            MediaPath = 'D:\Nana\Official\ISO\14257.1000.160131-1940.RS1_SRV_SERVER_VOL_X64FRE_EN-US.ISO'
            BasePath = 'D:\Nana\Test\NanoBasePath'
            TargetPathRoot = 'D:\Nana\Test\Images2\'
            PSDscAllowPlainTextPassword = $true
         }
    )
}