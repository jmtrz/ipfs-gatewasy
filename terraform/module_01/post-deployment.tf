resource "null_resource" "configure_ipfs" {
  depends_on = [azurerm_container_group.hq-ipfs-aci]

  # Wait for container to be ready
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOT
        Write-Host "Waiting for IPFS to start..."
        Start-Sleep -Seconds 30
      
        Write-Host "Configuring API CORS headers..."
        # Configure Access-Control-Allow-Origin
        az container exec `
           --resource-group ${local.azurerm_rg_name} `
           --name ${var.container_name} `
           --container-name ipfs `
           --exec-command 'ipfs config API.HTTPHeaders.Access-Control-Allow-Origin --json ["\"*\""]'

        Write-Host "Configuring API Method headers..."
        # Configure Access-Control-Allow-Methods
        az container exec `
           --resource-group ${local.azurerm_rg_name} `
           --name ${var.container_name} `
           --container-name ipfs `
           --exec-command 'ipfs config API.HTTPHeaders.Access-Control-Allow-Methods --json ["\"PUT\"","\"GET\"","\"POST\"","\"OPTIONS\""]'

        
        Write-Host "Configuring API Allow headers..."
        # Configure Access-Control-Allow-Headers
        az container exec `
            --resource-group ${local.azurerm_rg_name} `
            --name ${var.container_name} `
            --container-name ipfs `
            --exec-command 'ipfs config API.HTTPHeaders.Access-Control-Allow-Headers --json ["\"X-Requested-With\"","\"Range\"","\"User-Agent\""]'
        
        Write-Host "Configuring Routing and Network Settings..."
        # Configure Routing Type
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config Routing.Type --json "\"dhtserver\""'

        Write-Host "Configuring Reprovider Settings..."
        # Configure Reprovider Strategy
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config Reprovider.Strategy --json "\"all\""'

        # Configure Reprovider Interval
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config Reprovider.Interval --json "\"12h\""'

        Write-Host "Configuring Discovery Settings..."
        # Configure MDNS
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config Discovery.MDNS.Enabled --json true'

        Write-Host "Configuring Announce Settings..."
        # Configure Addresses.Announce
        az container exec `
        --resource-group ${local.azurerm_rg_name} `
        --name ${var.container_name} `
        --container-name ipfs `
        --exec-command 'ipfs config Addresses.Announce --json ["\"\/ip4\/${local.public_ip}\/tcp\/4001\""]'

        Write-Host "Configuring AutoRelay Settings..."
        # Configure Swarm.EnableAutoRelay
        az container exec `
        --resource-group ${local.azurerm_rg_name} `
        --name ${var.container_name} `
        --container-name ipfs `
        --exec-command 'ipfs config Swarm.EnableAutoRelay --json true'

        Write-Host "Configuration completed"

        Write-Host "Restarting IPFS container..."
        az container restart `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name}

        Write-Host "Waiting for container to restart..."
        Start-Sleep -Seconds 30

        Write-Host "Container restart completed. IPFS should now be running with new configurations."
    EOT
  }
}