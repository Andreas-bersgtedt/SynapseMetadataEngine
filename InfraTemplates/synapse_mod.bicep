@minLength(3)
@maxLength(11)
param workspacename string
param saurl string
param location string
param filesystem string

resource synworkspace 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: workspacename
tags: {}
  location: location
  properties: {
    defaultDataLakeStorage: {
      accountUrl: saurl
      filesystem: filesystem
    }
//    sqlAdministratorLoginPassword: 'string'
//    managedResourceGroupName: 'string'
//    sqlAdministratorLogin: 'string'
/*    virtualNetworkProfile: {
      computeSubnetId: 'string'
    }
    connectivityEndpoints: {}
    managedVirtualNetwork: 'string'
    privateEndpointConnections: [
      {
        properties: {
          privateEndpoint: {}
          privateLinkServiceConnectionState: {
            status: 'string'
            description: 'string'
          }
        }
      }
    ]
    encryption: {
      cmk: {
        key: {
          name: 'string'
          keyVaultUrl: 'string'
        }
      }
    }
    managedVirtualNetworkSettings: {
      preventDataExfiltration: bool
      linkedAccessCheckOnTargetResource: bool
      allowedAadTenantIdsForLinking: [
        'string'
      ]
    }
    workspaceRepositoryConfiguration: {
      type: 'string'
      hostName: 'string'
      accountName: 'string'
      projectName: 'string'
      repositoryName: 'string'
      collaborationBranch: 'string'
      rootFolder: 'string'
      lastCommitId: 'string'
      tenantId: 'string'
    }
    purviewConfiguration: {
      purviewResourceId: 'string'
    }
    networkSettings: {
      publicNetworkAccess: 'string'
    }*/
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output workspace object = synworkspace