## Markdown for pre-checks and config enhancements, better known as pre-flight conditions whilst onboarding IaC deployemnts and more specifically azure migrations

** Export Azure Resources As Terraform
This feature allows you to export existing Azure resources as Terraform configuration blocks using Azure Export for Terraform. This helps you migrate existing Azure resources to Terraform-managed infrastructure.

Open the Command Palette in VSCode (Command+Shift+P on macOS and Ctrl+Shift+P on Windows/Linux).

Search for and select the command Microsoft Terraform: Export Azure Resource as Terraform.

** Howto Use our preflight validation:

Ensure you have a valid Terraform configuration in your ${{ GITHUB.WORKSPACE }}.

Open the Command Palette and search for and select the command Microsoft Terraform: Preflight Validation.

The extension will prompt you to either:

Select an existing Terraform plan file, or
Generate a new plan file
If you choose to generate a new plan file:

Ensure you're authenticated to Azure using az login command (az-login)

The extension will:

- Generate a Terraform plan for your configuration
- Run preflight validation against the generated plan 
- Display the validation results in the terminal
- Validation results will help you identify potential issues such as:

    Azure resource configuration validation (azurem)
    Pre-deployment infrastructure checks (ideal in combi with e.g, azure migrate scenario)
    Policy compliance verification (PaC, policies.md)
    Resource provisioning constraints 
