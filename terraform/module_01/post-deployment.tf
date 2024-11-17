resource "null_resource" "configure_ipfs" {
  depends_on = [azurerm_container_group.hq_ipfs_gateway_acg]

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
          --exec-command 'ipfs config Reprovider.Interval --json "\"22h\""'

        Write-Host "Configuring Discovery Settings..."
        # Configure MDNS
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config Discovery.MDNS.Enabled --json true'

        Write-Host "Configuring AutoRelay Settings..."
        # Configure Swarm.EnableAutoRelay
        az container exec `
        --resource-group ${local.azurerm_rg_name} `
        --name ${var.container_name} `
        --container-name ipfs `
        --exec-command 'ipfs config Swarm.EnableAutoRelay --json true'

        Write-Host "Enable Experimental features for better content routing..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Experimental.OptimisticProvide false'

        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Experimental.StrategicProviding false'

        Write-Host "Configure Provider strategy..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Provider.Strategy "\"all\""'
        
        #Write-Host "Enable Relay Client..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Swarm.RelayClient.Enabled true'
        
        
        Write-Host "Increase the number of Grace Period..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Swarm.ConnMgr.GracePeriod \"2m\"'
        
        Write-Host "Increase the number of dial timeout..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Swarm.DialTimeoutSeconds 60'
        
        Write-Host "Enable NAT traversal..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Swarm.EnableHolePunching true'
        
        Write-Host "Enable AutoNAT service to help with NAT detection..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json AutoNAT.ServiceMode \"enabled\"'

        Write-Host "Configure direct dial attempts..."
        az container exec `
          --resource-group ${local.azurerm_rg_name} `
          --name ${var.container_name} `
          --container-name ipfs `
          --exec-command 'ipfs config --json Swarm.Transports.Network.Relay true'
      
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