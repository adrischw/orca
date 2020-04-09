<#

ORCA-229 - Check allowed domains in ATP Anti-phishing policies 

#>

using module "..\ORCA.psm1"

class ORCA229 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA229()
    {
        $this.Control=229
        $this.Services=[ORCAService]::OATP
        $this.Area="Advanced Threat Protection Policies"
        $this.Name="Anti-phishing trusted domains"
        $this.PassText="No trusted domains in Anti-phishing policy"
        $this.FailRecommendation="Remove whitelisting on domains in Anti-phishing policy"
        $this.Importance="Depends on your organization, but we recommend adding users that incorrectly get marked as phish due to impersonation only and not other filters."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.Links= @{
            "Recommended settings for EOP and Office 365 ATP security"="https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365-atp#office-365-advanced-threat-protection-security"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $PolicyExists = $False

        ForEach($Policy in ($Config["AntiPhishPolicy"] | Where-Object {$_.Enabled -eq $True}))
        {

            $PolicyExists = $True
            If(($Policy.ExcludedDomains).Count -gt 0)
            {
                ForEach($Domain in $Policy.ExcludedDomains) 
                {
                    # Check objects
                    $ConfigObject = [ORCACheckConfig]::new()
                    $ConfigObject.Object=$($Policy.Name)
                    $ConfigObject.ConfigItem="ExcludedDomains"
                    $ConfigObject.ConfigData=$($Domain)
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                    $this.AddConfig($ConfigObject)  
                }
            }
            else 
            {
                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object=$($Policy.Name)
                $ConfigObject.ConfigItem="ExcludedDomains"
                $ConfigObject.ConfigData=$($Policy.ExcludedDomains)
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                $this.AddConfig($ConfigObject)  
            }
        }

        If($PolicyExists -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object="No Policies"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")            

            $this.AddConfig($ConfigObject)      
        }             

    }

}