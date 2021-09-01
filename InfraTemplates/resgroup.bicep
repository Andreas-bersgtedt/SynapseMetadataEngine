param resgroupname string
param location string

// module deployed to subscription
targetScope = 'subscription'
resource newRG 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resgroupname
  location: location
}

