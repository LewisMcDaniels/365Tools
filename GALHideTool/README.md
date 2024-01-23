# HideToolMultipleUsers.ps1

## Description
This PowerShell script is designed to hide 365 users from the GAL when using Azure AD to sync identities. This will not work when using Hybrid Exhange.

## Usage
1. Open a PowerShell console with administrative privileges.
2. Navigate to the directory where the script is located.
3. Run the script by executing the following command:
    ```
    .\HideToolMultipleUsers.ps1
    ```
4. Enter the path to the .csv which includes the list of UPNs for the users that need hiding. Make sure the first line is "UPN".

## Requirements
- Windows operating system
- PowerShell 5.1 or later
- Azure AD Connect 2.x
- AD DS role installed

## Notes
- This script modifies the Windows registry to hide the specified tool. Use it with caution.
- Make sure to run the script with administrative privileges.
- For more information, refer to the comments within the script.

## License
This script is licensed under the [MIT License](LICENSE).

## Contributing
Contributions are welcome! Please read the [Contribution Guidelines](CONTRIBUTING.md) for more information.

## Support
If you encounter any issues or have any questions, please [open an issue](https://github.com/LewisMcDaniels/365Tools/issues).

## Authors
- [Lewis McDaniels](https://github.com/LewisMcDaniels)
