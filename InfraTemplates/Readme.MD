## Infrastructure as Code Section

This Folder will host Bicep Templates code so that we can deploy upfront some required infra. In particular we will deploy the Azure Datalake Storage and the Azure Synapse Workspace in a Resource Group.

The different pieces are built as Bicep modules and finally the synapse_stack file integrates all the underlying modules into a full deployment.

There is also a .cmd file with the cli instruction to deply the stack. 

![](imageIaC.png)

### Deployed infrastructure
- Resource group
- Keyvault
- Storage account
- Synapse workspace

To deploy the bicep code follow instructions at https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview.
