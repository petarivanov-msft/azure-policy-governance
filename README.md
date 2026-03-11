# Azure Policy Governance

A set of custom Azure Policy definitions I use for keeping subscriptions in line. Covers the basics — tagging, naming conventions, VM SKU restrictions, and diagnostic settings.

Started collecting these after the third time I had to manually fix tagging inconsistencies across a multi-subscription environment. Now I just assign the initiative and let Policy do the enforcement.

## What's included

**Policies:**
- `require-environment-tag` — denies resource groups without an Environment tag
- `require-costcenter-tag` — denies resources without a CostCenter tag
- `inherit-tags-from-rg` — copies tags from the resource group to child resources
- `enforce-naming-convention` — blocks resources that don't match the naming pattern
- `allowed-vm-skus` — restricts VMs to an approved SKU list
- `require-managed-disks` — denies VMs with unmanaged disks
- `require-diagnostic-settings` — audits resources missing diagnostic settings
- `deny-public-ip` — blocks public IP creation (intended for prod)

**Initiative:**
- `baseline-governance` — bundles the core policies into one assignment

**Deployment:**
- `assign-initiative.bicep` — assigns the initiative at subscription scope

## Usage

Create the policy definitions first:

```bash
az policy definition create \
  --name "require-environment-tag" \
  --rules policies/tagging/require-environment-tag.json \
  --mode All
```

Or deploy the initiative with Bicep:

```bash
az deployment sub create \
  --location uksouth \
  --template-file deploy/assign-initiative.bicep \
  --parameters enforcementMode=Default
```

Set `enforcementMode` to `DoNotEnforce` if you want to audit first before blocking anything.

## Notes

- These are Custom policies — the built-in ones are fine for simple stuff but don't always cover edge cases
- The naming convention policy uses a regex pattern in parameters so you can adjust it per subscription
- The initiative bundles everything except `deny-public-ip` (that one's opt-in since it breaks things if you're not ready)
- Tested against Azure commercial regions — haven't tried Gov or China

## License

MIT
