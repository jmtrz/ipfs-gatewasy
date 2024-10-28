# resource "azurerm_application_security_group" "ipfs_asg" {
#   name                = "ipfs-asg"
#   location            = local.azurerm_rg_location
#   resource_group_name = local.azurerm_rg_name
# }

# # Create NSG rule using ASG
# resource "azurerm_network_security_rule" "ipfs_rules" {
#   name                        = "ipfs-rules"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range          = "*"
#   destination_port_ranges     = ["4001", "5001", "8080"]
#   source_address_prefix      = "*"
#   destination_application_security_group_ids = [azurerm_application_security_group.ipfs_asg.id]
#   resource_group_name         = local.azurerm_rg_name
#   network_security_group_name = azurerm_network_security_group.ipfs_nsg.name
# }


# # Create NSG
# resource "azurerm_network_security_group" "ipfs_nsg" {
#   name                = "ipfs-nsg"
#   location            = local.azurerm_rg_location
#   resource_group_name = local.azurerm_rg_name

#   # IPFS Swarm TCP (Critical for node communication)
#   security_rule {
#     name                       = "IPFS-Swarm-TCP"
#     priority                   = 1000
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range     = "4001"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   # IPFS Swarm UDP (For QUIC protocol support)
#   security_rule {
#     name                       = "IPFS-Swarm-UDP"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Udp"
#     source_port_range         = "*"
#     destination_port_range     = "4001"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   # IPFS Gateway (For HTTP access)
#   security_rule {
#     name                       = "IPFS-Gateway"
#     priority                   = 1002
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range     = "8080"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   # IPFS API
#   security_rule {
#     name                       = "IPFS-API"
#     priority                   = 1003
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range         = "*"
#     destination_port_range     = "5001"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   tags = {
#     environment = "production"
#     created_by  = "jamester go"
#   }
# }


# Create Virtual Network
# resource "azurerm_virtual_network" "ipfs_vnet" {
#   name                = "ipfs-vnet"
#   address_space       = ["10.0.0.0/16"]
#   location            = local.azurerm_rg_location
#   resource_group_name = local.azurerm_rg_name
# }

# Create Subnet
# resource "azurerm_subnet" "ipfs_subnet" {
#   name                 = "ipfs-subnet"
#   resource_group_name  = local.azurerm_rg_name
#   virtual_network_name = azurerm_virtual_network.ipfs_vnet.name
#   address_prefixes     = ["10.0.1.0/24"]

#   delegation {
#     name = "delegation"

#     service_delegation {
#       name    = "Microsoft.ContainerInstance/containerGroups"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
#     }
#   }
# }

# Associate NSG with Subnet
# resource "azurerm_subnet_network_security_group_association" "ipfs_nsg_association" {
#   subnet_id                 = azurerm_subnet.ipfs_subnet.id
#   network_security_group_id = azurerm_network_security_group.ipfs_nsg.id
# }

# # Update Container Group to use the network
# resource "azurerm_container_group" "hq-ipfs-aci" {
#   # ... existing configuration ...

#   subnet_ids = [azurerm_subnet.ipfs_subnet.id]

#   # Note: When using subnet_ids, the IP address type must be Private
#   ip_address_type = "Private"

#   # ... rest of your existing container group configuration ...
# }

# Optional: Create Public IP for the container group if needed
# resource "azurerm_public_ip" "ipfs_public_ip" {
#   name                = "ipfs-public-ip"
#   resource_group_name = local.azurerm_rg_name
#   location            = local.azurerm_rg_location
#   allocation_method   = "Static"
#   sku                = "Standard"
# }