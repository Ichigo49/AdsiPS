function Enable-ADSIComputer
{
<#
	.SYNOPSIS
		Function to enable a Computer Account
	
	.DESCRIPTION
		Function to enable a Computer Account
	
	.PARAMETER Identity
		Specifies the Identity of the Computer.
	
		You can provide one of the following properties
			DistinguishedName
			Guid
			Name
			SamAccountName
			Sid
	
	.PARAMETER Credential
		Specifies the alternative credential to use.
		By default it will use the current user windows credentials.
	
	.PARAMETER DomainName
		Specifies the alternative Domain.
		By default it will use the current domain.
	
	.EXAMPLE
		Enable-ADSIComputer TESTSERVER01
	
		This command will enable the account TESTSERVER01
	
	.EXAMPLE
		Enable-ADSIComputer TESTSERVER01 -whatif
	
		This command will emulate disabling the account TESTSERVER01

	.EXAMPLE
		Enable-ADSIComputer TESTSERVER01 -credential (Get-Credential)
	
		This command will enable the account TESTSERVER01 using the alternative credential specified
	
	.EXAMPLE
		Enable-ADSIComputer TESTSERVER01 -credential (Get-Credential) -domain LazyWinAdmin.local
	
		This command will enable the account TESTSERVER01 using the alternative credential specified in the domain lazywinadmin.local
	
	.NOTES
		Francois-Xavier.Cat
		LazyWinAdmin.com
		@lazywinadm
		github.com/lazywinadmin
	
	.LINK
		https://msdn.microsoft.com/en-us/library/system.directoryservices.accountmanagement.computerprincipal(v=vs.110).aspx
#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	PARAM (
		[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = "SamAccountName", ValueFromPipeline = $true)]
		$Identity,
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty,
		[String]$DomainName)
	
	BEGIN
	{
		Add-Type -AssemblyName System.DirectoryServices.AccountManagement
		
		# Create Context splatting
		$ContextSplatting = @{ }
		IF ($PSBoundParameters['Credential']) { $ContextSplatting.Credential = $Credential }
		IF ($PSBoundParameters['DomainName']) { $ContextSplatting.DomainName = $DomainName }
		
		$Context = New-ADSIPrincipalContext @ContextSplatting -contexttype Domain
	}
	PROCESS
	{
		TRY
		{
			if ($pscmdlet.ShouldProcess("$Identity", "enable Account"))
			{
				$Account = Get-ADSIComputer -Identity $Identity @ContextSplatting
				$Account.enabled = $true
				$Account.Save()
			}
		}
		CATCH
		{
			Write-Error $Error[0]
		}
	}
}
