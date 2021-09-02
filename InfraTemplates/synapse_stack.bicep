param prefix string = 'gbbcatalog'
param location string = 'westeurope'

// The stack is within a Res Group and composed of a Storage Account with a Hierarchical Namespace.
// + Synapse Workspace
//
var resgroupname = '${prefix}-rg'
var saname = '${prefix}'
var wsname =  '${prefix}ws'
var keyvaultname = '${prefix}kv'
// var saurl = 'https://${saname}.dfs.core.windows.net'
var container = 'datalake'

targetScope = 'subscription'

module resgroupMod 'resgroup.bicep' = {
  name: 'resgroupModule'
  params: {
    resgroupname: resgroupname
    location: location
  }
  // deploy this module at the subscription scope
  scope: subscription()
}

// modules deployed to resource group
module keyvaultMod 'keyvault_mod.bicep' = {
  name: 'keyvaultModule'
  params: {
    keyVaultName: keyvaultname
    location: location
  }
  dependsOn: [
    resgroupMod
  ]
  // deploy this module at the subscription scope
  scope: resourceGroup(resgroupname)
}

module storageMod 'storage_mod.bicep' = {
  name: 'storageModule'
  params: {
    saname: saname
    location: location
    containername: container
  }
  dependsOn: [
    resgroupMod
  ]
  // deploy this module at the subscription scope
  scope: resourceGroup(resgroupname)
}

module synapseMod 'synapse_mod.bicep' = {
  name: 'synapseModule'
  params: {
    saurl: storageMod.outputs.storageEndpoint.dfs
    workspacename: wsname
    location:  location
    filesystem: container
    keyvaultname: keyvaultname
  }
  dependsOn: [
    storageMod
    resgroupMod
    keyvaultMod
  ]
  // deploy this module at the subscription scope
  scope: resourceGroup(resgroupname)
}
