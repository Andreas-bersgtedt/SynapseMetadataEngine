@minLength(3)
@maxLength(11)
param workspacename string
param saurl string
param location string
param filesystem string
param keyvaultname string
param now string = utcNow()

var login = 'sqladmin'
var scrambled = uniqueString(now)

resource synworkspace 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: workspacename
tags: {}
  location: location
  properties: {
    defaultDataLakeStorage: {
      accountUrl: saurl
      filesystem: filesystem
    }
    sqlAdministratorLoginPassword: scrambled
//    managedResourceGroupName: 'string'
    sqlAdministratorLogin: login
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


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyvaultname
  resource storageSecret 'secrets' = {
    name: login
    properties: {
    value: scrambled
    }
  }
}

resource synapseIdentityKeyVaultAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('Synapse Secret User', workspacename, subscription().subscriptionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: synworkspace.identity.principalId
    principalType: 'MSI'
  }
  dependsOn: [
    synworkspace
  ]
}
output workspace object = synworkspace