output "dns" {
    value = tomap({
        for v, vm in azurerm_windows_virtual_machine.dc : v => {
            id = vm.id
            private_ip_address = vm.private_ip_address
        }
    })
}