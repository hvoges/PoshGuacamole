# CLAUDE.md - PoshGuacamole Development Guide for AI Assistants

## Project Overview

**PoshGuacamole** is a PowerShell module for automating Apache Guacamole user and connection management via the Guacamole REST API.

- **Author**: Holger Voges
- **Company**: Netz-Weise IT-Schulungen
- **License**: GNU General Public License v3 (GPL v3)
- **Version**: 0.3.0.0
- **Status**: Beta - Core functionality implemented, some features still in development
- **Last Updated**: February 22, 2022

### Purpose
This module provides PowerShell cmdlets to manage Guacamole users, connections, groups, and permissions programmatically, using the Guacamole REST API as documented at:
https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs

## Repository Structure

```
PoshGuacamole/
├── Guacamole.psd1              # Module manifest (version, exported functions, metadata)
├── Loader.psm1                 # Root module that dot-sources all function files
├── init.ps1                    # Enums and script-level variables (KeyboardLayout, GuacamoleTimezones)
├── README.md                   # User-facing documentation with usage examples
├── LICENSE                     # GPL v3 license text
├── .gitignore                  # Git ignore patterns
│
├── Connect-Guacamole.ps1       # Authentication - Creates auth token
├── Disconnect-Guacamole.ps1    # Authentication - Removes auth token
│
├── Get-Guacamole*.ps1          # Retrieve resources (Users, Connections, Groups, etc.)
├── New-Guacamole*.ps1          # Create resources
├── Set-Guacamole*.ps1          # Update resources
├── Remove-Guacamole*.ps1       # Delete resources
├── Add-Guacamole*.ps1          # Add relationships (e.g., user to connection)
│
├── ConvertTo-*.ps1             # Conversion helper functions
├── ConvertFrom-*.ps1           # Conversion helper functions
├── Format-*.ps1                # Formatting helper functions
└── Get-GuacamoleAttributes.ps1 # Helper for processing API JSON responses
```

### File Count
- **32 PowerShell script files** (.ps1) containing cmdlets and helper functions
- **1 module manifest** (Guacamole.psd1)
- **1 module loader** (Loader.psm1)
- **1 initialization script** (init.ps1)

## Module Architecture

### Loading Mechanism
1. **Guacamole.psd1** declares `RootModule = 'loader.psm1'`
2. **Loader.psm1** dot-sources `init.ps1` first (for enums/variables)
3. **Loader.psm1** then dot-sources all function files in specific order
4. **Export-ModuleMember** explicitly declares exported functions (matches manifest's FunctionsToExport)

### Script-Level Variables (init.ps1)
- `$Script:keyboardCodes`: Hashtable mapping keyboard layout enum to Guacamole codes
- `$Script:Timezones`: Ordered hashtable mapping timezone enum to IANA timezone strings
- `$Script:GuacAuthToken`: Session authentication token (set by Connect-Guacamole)

### Enums
- **KeyboardLayout**: Supported keyboard layouts (Danish, English_US, German, etc.)
- **GuacamoleTimezones**: All supported timezones in PowerShell-friendly format

## Coding Conventions and Standards

### Function Structure

Every public cmdlet follows this template:

```powershell
Function Verb-GuacamoleNoun {
<#
.SYNOPSIS
    Brief one-line description
.DESCRIPTION
    Detailed description of functionality
.EXAMPLE
    PS C:\> Verb-GuacamoleNoun -Parameter Value
    Description of what this example does
.NOTES
    Author: Holger Voges
    Version: 1.0
    Date: YYYY-MM-DD
#>
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Type]$ParameterName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('api-property-name')]
        [Type]$FriendlyName,

        [Switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Begin {
        # Initialize, build endpoint URLs
    }

    Process {
        # Main logic, API calls
    }

    End {
        # Cleanup, final output
    }
}
```

### Parameter Conventions

1. **Mandatory Parameters**: User identifiers, required fields
   - Use `[Parameter(Mandatory)]` attribute
   - Support pipeline input with `ValueFromPipeline` and `ValueFromPipelineByPropertyName`

2. **AuthToken Parameter**:
   - ALWAYS include in every cmdlet that calls the API
   - Use `[Parameter(DontShow)]` attribute
   - Default to `$GuacAuthToken` script variable
   - Allows override for advanced scenarios

3. **Aliases**:
   - Map PowerShell-friendly parameter names to Guacamole API property names
   - Example: `[Alias('guac-email-address')]` for `$EmailAddress`

4. **Passthru Switch**:
   - Include in cmdlets that create/modify resources
   - Returns API response when specified
   - Omit for silent success (PowerShell convention)

5. **Secure Strings for Passwords**:
   - ALWAYS use `[SecureString]` type for password parameters
   - Convert with: `[PSCredential]::new('Demo',$Password).GetNetworkCredential().Password`

6. **DateTime Parameters**:
   - Use `[DateTime]` type for dates and times
   - Apply `[ValidateScript()]` for date logic validation
   - Format dates as `yyyy-MM-dd` for API: `"{0:yyyy-MM-dd}" -f $ValidFrom`
   - Format times as `T` for API: `$AccessWindowStart.ToString("T")`

7. **Enum Parameters**:
   - Use custom enums (GuacamoleTimezones, KeyboardLayout) for structured choices
   - Provides IntelliSense and validation
   - Map to API values via hashtable lookups

### API Interaction Patterns

#### Authentication
```powershell
# First call in every session
Connect-Guacamole -HostUrl "https://guacamole.example.com" -Credential $Cred
# Stores token in $Script:GuacAuthToken
```

#### Endpoint URL Construction
```powershell
$EndPoint = '{0}/api/session/data/{1}/endpoint?token={2}' -f `
    $AuthToken.HostUrl,
    $AuthToken.datasource,
    $AuthToken.authToken
```

#### GET Requests
```powershell
$WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
$Data = $WebResponse | ConvertFrom-Json
```

#### POST/PUT Requests
```powershell
$Body = @{
    property1 = $Value1
    property2 = $Value2
} | ConvertTo-Json

$Response = Invoke-RestMethod -Uri $EndPoint `
                              -Method Post `
                              -ContentType 'application/json' `
                              -Body $Body
```

#### Error Handling
```powershell
Try {
    # API call
}
Catch {
    Throw $_.Exception.Message
    # or
    Throw $_
}
```

### Attribute Processing Pattern

The `Get-GuacamoleAttributes` helper function is used extensively to convert Guacamole API JSON attributes into PowerShell object properties:

```powershell
# In Get-* cmdlets
$Object = $ApiResponse.$PropertyName
Get-GuacamoleAttributes -Object $Object -ShowEmptyAttributes:$ShowEmptyAttributes
```

This pattern:
- Converts hyphenated API property names to PascalCase
- Handles null vs empty string differences
- Processes special properties (e.g., LastActive timestamp conversion)
- Optionally shows empty attributes

### Parameter Mapping Pattern (New-* and Set-* cmdlets)

Use a `Switch` statement on `$PSBoundParameters.Keys` to map parameters to API attributes:

```powershell
Switch ($PSBoundParameters.Keys) {
    "EmailAddress"      { $Object.attributes."guac-email-address" = $EmailAddress }
    "Disabled"          { $Object.attributes."disabled"           = $Disabled }
    "TimeZone"          { $Object.attributes."timezone"           = $Timezones."$TimeZone" }
    "AccessWindowStart" { $Object.attributes."access-window-start" = $AccessWindowStart.ToString("T") }
}
```

Benefits:
- Only sets properties that were explicitly provided
- Maintains ordered hashtables for predictable JSON serialization
- Handles type conversions (DateTime, SecureString, Enum)

### Verbose Output
Use `Write-Verbose` to output endpoint URLs and debug information:
```powershell
Write-Verbose $Endpoint
```

## Function Categories and Responsibilities

### Authentication
- **Connect-Guacamole**: Authenticate and create session token
- **Disconnect-Guacamole**: End session and remove token
- **Remove-GuacamoleAuthToken**: Remove specific auth tokens

### User Management
- **Get-GuacamoleUser**: Retrieve user(s), supports filtering with regex
- **New-GuacamoleUser**: Create new user with attributes
- **Set-GuacamoleUser**: Update user attributes
- **Set-GuacamoleUserPassword**: Change user password
- **Remove-GuacamoleUser**: Delete user
- **Get-GuacamoleUserHistory**: Retrieve user activity history
- **Get-GuacamoleUserPermission**: Get user permissions

### Connection Management
- **Get-GuacamoleConnection**: Retrieve connection(s), filter by protocol
- **Get-GuacamoleConnectionParameter**: Get connection parameters
- **New-GuacamoleRdpConnection**: Create RDP connection (only protocol supported currently)
- **Set-GuacamoleRdpConnection**: Update RDP connection settings
- **Remove-GuacamoleConnection**: Delete connection

### User-Connection Association
- **Get-GuacamoleUserConnection**: List connections accessible by user
- **Add-GuacamoleUserConnection**: Grant user access to connection
- **Remove-GuacamoleUserConnection**: Revoke user access to connection

### Group Management
- **Get-GuacamoleUserGroup**: Retrieve user groups
- **New-GuacamoleUserGroup**: Create new group
- **Set-GuacamoleUserGroup**: Update group settings
- **Remove-GuacamoleUserGroup**: Delete group
- **Get-GuacamoleGroupMember**: List group members
- **Add-GuacamoleGroupMember**: Add user to group
- **Remove-GuacamoleGroupMember**: Remove user from group

### Helper Functions (Not Exported)
- **Get-GuacamoleAttributes**: Process API JSON responses into PowerShell objects
- **ConvertTo-Hashtable**: Convert JSON/PSObject to hashtable
- **ConvertFrom-JavaSimpleTime**: Convert Java timestamp to DateTime
- **ConvertTo-JavaSimpleTime**: Convert DateTime to Java timestamp
- **ConvertTo-GuacamoleTimeString**: Format time for Guacamole API
- **Format-GuacamoleProperties**: Format property names (helper for attribute processing)

## Development Workflow

### Adding a New Cmdlet

1. **Create the .ps1 file** in the repository root
2. **Follow the function template** (see Coding Conventions)
3. **Add to Loader.psm1** in the appropriate section:
   ```powershell
   . $PSScriptRoot\Your-NewCmdlet.ps1
   ```
4. **Update Export-ModuleMember** in Loader.psm1:
   ```powershell
   Export-ModuleMember -Function 'Existing-Functions','Your-NewCmdlet'
   ```
5. **Update FunctionsToExport** in Guacamole.psd1:
   ```powershell
   FunctionsToExport = 'Existing-Functions','Your-NewCmdlet'
   ```
6. **Test the cmdlet**:
   ```powershell
   Import-Module .\Guacamole.psd1 -Force
   Your-NewCmdlet -Parameters
   ```

### Testing Protocol

1. **Manual Testing**: Import module and test cmdlets interactively
2. **Pipeline Testing**: Verify ValueFromPipeline and ValueFromPipelineByPropertyName work
3. **Error Cases**: Test with invalid parameters, missing auth, etc.
4. **Verbose Output**: Verify Write-Verbose shows helpful debug info

### Git Workflow

Current branch structure:
- **main**: Stable releases
- **claude/claude-md-[session-id]**: AI assistant development branches

When making changes:
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add support for VNC connections"

# Push to branch
git push -u origin claude/claude-md-miyxp445dn330alg-01Pne9x7pZ9x4BPVj86bk92V
```

Commit message conventions:
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **refactor**: Code refactoring
- **test**: Test additions/changes

## Known Limitations and TODOs

From README.md:

### Planned Features
- [ ] Implement WhatIf parameter for Set-* and Remove-* cmdlets (safety)
- [ ] Add support for VNC connections
- [ ] Add support for SSH connections
- [ ] Add support for Telnet connections
- [ ] Add support for Kubernetes connections
- [ ] Implement connection groups management
- [ ] Expand permission management capabilities
- [ ] Add session disconnect functionality

### Current Limitations
- Only RDP connections are fully supported
- Not all Guacamole web GUI features are available
- Some cmdlets lack WhatIf/Confirm support
- Beta status - API may change

## Important Technical Details

### URL Handling in Connect-Guacamole
- Validates URL format with regex
- Automatically prepends `https://` if protocol is missing
- Stores base URL in `$AuthToken.HostUrl` for reuse

### Session Token Management
- Token stored in **script scope** variable `$Script:GuacAuthToken`
- Not accessible outside module unless using `-Passthru`
- Passed as URL query parameter: `?token={authToken}`
- Contains: `authToken`, `username`, `dataSource`, `availableDataSources`
- Enhanced with: `HostUrl` (NoteProperty) and `JsonToken` (raw JSON)

### Date/Time Handling
- **Java SimpleTime**: Milliseconds since epoch, requires conversion helpers
- **ValidFrom/ValidUntil**: Dates as `yyyy-MM-dd` strings
- **AccessWindowStart/End**: Times as short time pattern `T` (e.g., "09:00")
- **LastActive**: Converted from Java timestamp using `ConvertFrom-JavaSimpleTime`

### Timezone Handling
- Enum values use underscores: `Europe_Berlin`
- API expects slashes: `Europe/Berlin`
- Conversion happens via `$Script:Timezones` hashtable
- Default timezone: `Europe_Berlin` (can be overridden)

### Property Name Transformations
- API uses hyphenated names: `guac-email-address`, `access-window-start`
- PowerShell parameters use PascalCase: `EmailAddress`, `AccessWindowStart`
- Aliases bridge the gap for pipeline compatibility
- Helper functions handle the conversions

## Best Practices for AI Assistants

### When Adding Features

1. **Check existing patterns first**: Look at similar cmdlets (e.g., reference New-GuacamoleUser when creating New-GuacamoleVncConnection)
2. **Maintain consistency**: Use the same parameter names, validation patterns, and comment structure
3. **Support the pipeline**: Always include ValueFromPipeline and ValueFromPipelineByPropertyName where appropriate
4. **Include comment-based help**: SYNOPSIS, DESCRIPTION, EXAMPLES, and NOTES sections are mandatory
5. **Use proper error handling**: Try/Catch blocks with meaningful error messages
6. **Test with Verbose**: Ensure Write-Verbose provides useful debugging output
7. **Update all three locations**: .ps1 file, Loader.psm1 dot-source, and both export lists

### When Fixing Bugs

1. **Preserve existing behavior**: Don't change function signatures unless necessary
2. **Maintain backward compatibility**: This is a public module
3. **Document breaking changes**: If unavoidable, note clearly in commit message
4. **Test pipeline scenarios**: Many users rely on piping objects between cmdlets
5. **Validate against API**: Guacamole API is the source of truth

### When Refactoring

1. **Don't over-engineer**: Keep the simple, direct style of existing code
2. **Preserve comment-based help**: Users depend on Get-Help
3. **Maintain alphabetical order**: In export lists and where logical
4. **Keep helper functions internal**: Only export user-facing cmdlets
5. **Test thoroughly**: Module loading, function execution, pipeline behavior

### Common Pitfalls to Avoid

1. ❌ Don't use Write-Host (PowerShell anti-pattern)
2. ❌ Don't remove the AuthToken parameter default
3. ❌ Don't hard-code URLs or endpoints
4. ❌ Don't skip parameter validation
5. ❌ Don't use plain text for passwords
6. ❌ Don't forget to update both Loader.psm1 AND Guacamole.psd1
7. ❌ Don't change existing parameter names (breaking change)
8. ❌ Don't skip the Begin/Process/End structure for pipeline-enabled functions

## Quick Reference: Common Tasks

### Add support for a new connection type (e.g., VNC)

1. Create `New-GuacamoleVncConnection.ps1`
2. Model after `New-GuacamoleRdpConnection.ps1`
3. Reference Guacamole API docs for VNC-specific parameters
4. Update Loader.psm1 and Guacamole.psd1
5. Create corresponding `Set-GuacamoleVncConnection.ps1`

### Add a new user attribute

1. Identify the API property name (e.g., `guac-phone-number`)
2. Add parameter to `New-GuacamoleUser.ps1` and `Set-GuacamoleUser.ps1`
3. Use `[Alias('guac-phone-number')]` on parameter
4. Add to the Switch statement in both functions
5. Update comment-based help with example
6. Test with pipeline input

### Debug API issues

1. Use `Write-Verbose $Endpoint` to see the URL
2. Check `$AuthToken` contents: `$GuacAuthToken | Format-List`
3. Test endpoint with Invoke-RestMethod manually
4. Verify JSON structure: `$Body | ConvertFrom-Json | Format-List`
5. Check Guacamole server logs for API errors

## Additional Resources

- **Guacamole API Documentation**: https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs
- **Related Project**: https://github.com/Adicitus/ps-guacamole-api (by Adicitus)
- **PowerShell Best Practices**: https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines

## Version History

- **0.3.0.0** (2022-02-22): Latest version
  - Default timezone added
  - Filter parameter added to Get-GuacamoleUser
  - Username property added to GuacamoleUserConnection

- **Previous versions**: See git history for detailed changelog

---

**Note for AI Assistants**: This document is maintained to help you understand and contribute to the PoshGuacamole project effectively. When making changes, update this document if you add new patterns, conventions, or architectural decisions. Keep it concise and focused on practical guidance.
