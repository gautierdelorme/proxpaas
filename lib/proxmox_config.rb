module ProxmoxConfig
  def proxmox_host
    ENV['PROXMOX_HOST'] || 'https://srv-px1.insa-toulouse.fr:8006'
  end

  def proxmox_node
    ENV['PROXMOX_NODE'] || 'srv-px1'
  end

  def proxmox_login
    ENV['PROXMOX_LOGIN'] || 'login_insa'
  end

  def proxmox_password
    ENV['PROXMOX_PASSWORD'] || 'password_insa'
  end

  def proxmox_realm
    ENV['PROXMOX_REALM'] || 'Ldap-INSA'
  end

  def proxmox_os_template
    ENV['PROXMOX_OS_TEMPLATE'] || 'template:vztmpl/debian-8.0-standard_8.7-1_amd64.tar.gz'
  end

  def proxmox_ct_base_id
    ENV['PROXMOX_CT_BASE_ID'] || '9114'
  end

  def proxmox_ct_base_name
    ENV['PROXMOX_CT_BASE_NAME'] || 'tpgei-proxpaas-ct'
  end

  def proxmox_ct_password
    ENV['PROXMOX_CT_PASSWORD'] || 'tpuser'
  end

  def proxmox_ct_login
    ENV['PROXMOX_CT_LOGIN'] || 'root'
  end

  def proxmox_ct_hdd
    ENV['PROXMOX_CT_HDD'] || 'vm:3'
  end

  def proxmox_ct_network
    ENV['PROXMOX_CT_HDD'] || 'name=eth0,bridge=vmbr1,ip=dhcp,tag=2028,type=veth'
  end

  def proxmox_ct_ram
    ENV['PROXMOX_CT_RAM'] || '512'
  end

  def proxmox_ct_storage
    ENV['PROXMOX_CT_STORAGE'] || 'vm'
  end

  def proxmox_ct_cpu_limit
    ENV['PROXMOX_CT_CPU_LIMIT'] || '1'
  end

  def proxmox_ct_web_directory
    ENV['PROXMOX_CT_WEB_DIR'] || '/var/www'
  end

  def proxmox_dhcp_server_addr
    ENV['PROXMOX_DHCP_SERVER_ADDR'] || 'http://vm-tpgei-dhcp.insa-toulouse.fr/kea'
  end
end
