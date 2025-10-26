package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestVirtualMachineModuleBasic tests basic VM creation with minimal configuration
func TestVirtualMachineModuleBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-basic",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_B2s",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
		},
		
		// Prevent actual Azure resources from being created
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and plan
	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Assert that resources will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_network_interface.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_linux_virtual_machine.main")
}

// TestVirtualMachineModuleWindows tests Windows VM creation
func TestVirtualMachineModuleWindows(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-windows",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_D2s_v3",
			"admin_username":     "azureuser",
			"admin_password":     "P@ssw0rd1234!",
			"os_type":            "Windows",
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify Windows VM will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_windows_virtual_machine.main")
}

// TestVirtualMachineModuleWithDataDisks tests VM with attached data disks
func TestVirtualMachineModuleWithDataDisks(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-disks",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_D2s_v3",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
			"data_disks": []map[string]interface{}{
				{
					"lun":                  0,
					"disk_size_gb":         128,
					"storage_account_type": "Premium_LRS",
					"caching":              "ReadWrite",
					"create_option":        "Empty",
				},
				{
					"lun":                  1,
					"disk_size_gb":         256,
					"storage_account_type": "Premium_LRS",
					"caching":              "ReadOnly",
					"create_option":        "Empty",
				},
			},
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify data disks will be created
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_managed_disk.data")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_virtual_machine_data_disk_attachment.data")
}

// TestVirtualMachineModuleWithManagedIdentity tests VM with managed identity
func TestVirtualMachineModuleWithManagedIdentity(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-identity",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_B2s",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
			"identity_type":      "SystemAssigned",
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify VM with identity will be created
	resourceChanges := terraform.GetResourceChanges(t, planStruct)
	
	found := false
	for _, change := range resourceChanges {
		if change.Type == "azurerm_linux_virtual_machine" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if identity, ok := afterMap["identity"]; ok && identity != nil {
				found = true
				break
			}
		}
	}
	
	assert.True(t, found, "VM should have identity configured")
}

// TestVirtualMachineModuleWithEncryption tests VM with encryption enabled
func TestVirtualMachineModuleWithEncryption(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",
		
		Vars: map[string]interface{}{
			"resource_group_name":          "rg-test-vm-encryption",
			"location":                     "westeurope",
			"environment":                  "test",
			"vm_size":                      "Standard_D2s_v3",
			"admin_username":               "azureuser",
			"os_type":                      "Linux",
			"encryption_at_host_enabled":   true,
			"secure_boot_enabled":          true,
			"vtpm_enabled":                 true,
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	// Verify encryption settings
	resourceChanges := terraform.GetResourceChanges(t, planStruct)
	
	for _, change := range resourceChanges {
		if change.Type == "azurerm_linux_virtual_machine" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			
			if encryptionAtHost, ok := afterMap["encryption_at_host_enabled"]; ok {
				assert.True(t, encryptionAtHost.(bool), "Encryption at host should be enabled")
			}
			
			if secureBoot, ok := afterMap["secure_boot_enabled"]; ok {
				assert.True(t, secureBoot.(bool), "Secure boot should be enabled")
			}
			
			if vtpm, ok := afterMap["vtpm_enabled"]; ok {
				assert.True(t, vtpm.(bool), "vTPM should be enabled")
			}
		}
	}
}

// TestVirtualMachineModuleNamingConvention tests naming convention compliance
func TestVirtualMachineModuleNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-naming",
			"location":           "westeurope",
			"environment":        "prod",
			"naming_prefix":      "web",
			"instance_number":    "001",
			"vm_size":            "Standard_B2s",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)
	
	// Verify naming convention is followed
	resourceChanges := terraform.GetResourceChanges(t, planStruct)
	
	for _, change := range resourceChanges {
		if change.Type == "azurerm_linux_virtual_machine" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if name, ok := afterMap["name"]; ok {
				vmName := name.(string)
				assert.Contains(t, vmName, "prod", "VM name should contain environment")
				assert.Contains(t, vmName, "westeurope", "VM name should contain location")
				assert.Contains(t, vmName, "vm", "VM name should contain resource type")
			}
		}
	}
}

// TestVirtualMachineModuleAvailabilityZone tests VM with availability zone
func TestVirtualMachineModuleAvailabilityZone(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-zone",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_B2s",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
			"availability_zone":  "1",
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)
	
	// Verify availability zone is set
	resourceChanges := terraform.GetResourceChanges(t, planStruct)
	
	for _, change := range resourceChanges {
		if change.Type == "azurerm_linux_virtual_machine" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if zone, ok := afterMap["zone"]; ok {
				assert.Equal(t, "1", zone, "Availability zone should be set to 1")
			}
		}
	}
}

// TestVirtualMachineModuleTags tests proper tagging
func TestVirtualMachineModuleTags(t *testing.T) {
	t.Parallel()

	expectedTags := map[string]string{
		"Environment": "test",
		"ManagedBy":   "Terraform",
		"CostCenter":  "IT",
		"Owner":       "Platform Team",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		
		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-vm-tags",
			"location":           "westeurope",
			"environment":        "test",
			"vm_size":            "Standard_B2s",
			"admin_username":     "azureuser",
			"os_type":            "Linux",
			"tags":               expectedTags,
		},
		
		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)
	
	// Verify tags are applied
	resourceChanges := terraform.GetResourceChanges(t, planStruct)
	
	for _, change := range resourceChanges {
		if change.Type == "azurerm_linux_virtual_machine" && change.Change.After != nil {
			afterMap := change.Change.After.(map[string]interface{})
			if tags, ok := afterMap["tags"]; ok {
				tagsMap := tags.(map[string]interface{})
				for key, value := range expectedTags {
					assert.Equal(t, value, tagsMap[key], "Tag %s should match", key)
				}
			}
		}
	}
}
