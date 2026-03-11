targetScope = 'subscription'

@description('The enforcement mode for the policy assignment. Use DoNotEnforce to audit first.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'DoNotEnforce'

@description('The subscription ID where policy definitions are stored.')
param policySubscriptionId string = subscription().subscriptionId

@description('Location for the managed identity used by modify/deployIfNotExists policies.')
param location string = 'uksouth'

var initiativeDefinitionId = '/subscriptions/${policySubscriptionId}/providers/Microsoft.Authorization/policySetDefinitions/baseline-governance'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: 'baseline-governance'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Baseline Governance Initiative'
    description: 'Core governance policies for tagging, naming, compute, and monitoring.'
    policyDefinitionId: initiativeDefinitionId
    enforcementMode: enforcementMode
    parameters: {}
  }
}

// Role assignment for the managed identity (needed for modify effects like tag inheritance)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(policyAssignment.id, 'contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: policyAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
