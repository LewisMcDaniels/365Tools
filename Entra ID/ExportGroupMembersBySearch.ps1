# To search for group memberships by group name amend the displayname search field at line 15. 
# This cannot be an input variable due to limitation in the MS Graph powershell module.

# Install & import required modules
if(-not (Get-Module 'Microsoft.Graph.Groups' -ListAvailable)){
    Install-Module 'Microsoft.Graph.Groups' -Scope CurrentUser -Force
}
Import-Module -Name Microsoft.Graph.Groups

# Connect to MS Graph with Read permissions on all users & groups
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All" -NoWelcome 

# Gets all groups by disaply name search, then use that list to get a list of all memembers of each.

$groups = get-mggroup -All -ConsistencyLevel eventual -Search '"DisplayName:AY23"'
$output = foreach ($group in $groups) {
    $groupId = $group.Id
    $users = Get-MgGroupMemberAsUser -GroupId $groupId
    foreach ($user in $users) {
        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            GroupDisplayName = $group.displayname
        }
    }
}

# Export to a CSV file
$folderpath = "C:\GroupMembershipTool\"
New-Item -ItemType Directory -Path $folderpath
$Filename = "GroupMembershipTool.csv"
$fullpath = join-path -path $folderpath -childpath $filename
$output | Export-Csv -Path $fullpath -NoTypeInformation