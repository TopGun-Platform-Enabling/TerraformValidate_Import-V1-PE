output "rg" {
  value = tomap({
    for r, rg in azurerm_resource_group.rg : r => {
        id = rg.id
        name = rg.name
        location = rg.location
    }
  })
}