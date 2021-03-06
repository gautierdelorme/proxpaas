require './lib/proxmox'
require './lib/proxmox_config'
require 'dotenv/load'
require 'net/ssh'
require 'net/scp'

class ProxClient
  include ProxmoxConfig

  def client
    @client ||= Proxmox::Proxmox.new(
      "#{proxmox_host}/api2/json/",
      proxmox_node,
      proxmox_login,
      proxmox_password,
      proxmox_realm,
      verify_ssl: false
    )
  end

  def wait_for_task(task)
    while client.task_status(task) == 'running'
      p client.task_status task
      p '...'
      sleep 3
    end
  end

  def create_and_start_ct(uuid)
    "#{proxmox_ct_base_id}#{uuid}".tap do |vmid|
      wait_for_task(create_ct vmid)
      wait_for_task(client.lxc_start vmid)
    end
  end

  def create_ct(vmid)
    client.lxc_post(
      'ostemplate' => proxmox_os_template,
      'vmid' => vmid,
      'hostname' => "#{proxmox_ct_base_name}#{vmid}",
      'memory' => proxmox_ct_ram,
      'storage' => proxmox_ct_storage,
      'password' => proxmox_ct_password,
      'swap' => proxmox_ct_ram,
      'rootfs' => proxmox_ct_hdd,
      'cpulimit' => proxmox_ct_cpu_limit,
      'net0' => proxmox_ct_network
    )
  end

  def upload_to_ct(ct_ip, filepath)
    Net::SCP.upload!(
      ct_ip,
      proxmox_ct_login,
      filepath,
      proxmox_ct_web_directory,
      ssh: { password: proxmox_ct_password }
    )
  end

  def start_app_on_ct(ct_ip)
    # NOTE: bad because it'll create a downtime during deployment.
    # We should consider using a side A / side B process
    Net::SSH.start(ct_ip, proxmox_ct_login, password: proxmox_ct_password) do |ssh|
      ssh.exec! "forever stop #{proxmox_ct_web_directory}/app"
      ssh.exec! "rm -rf #{proxmox_ct_web_directory}/app"
      ssh.exec! "unzip #{proxmox_ct_web_directory}/*.zip -d #{proxmox_ct_web_directory}/app"
      ssh.exec! "rm -f #{proxmox_ct_web_directory}/*.zip"
      ssh.exec! "forever start -c http-server #{proxmox_ct_web_directory}/app -p 80"
    end
  end

  def setup_ct(ct_ip)
    Net::SSH.start(ct_ip, proxmox_ct_login, password: proxmox_ct_password) do |ssh|
      ssh.exec! 'mkdir -p /var/www'
      ssh.exec! 'apt-get update'
      ssh.exec! 'apt-get install unzip curl -y'
      ssh.exec! 'curl -sL https://deb.nodesource.com/setup_8.x | bash -'
      ssh.exec! 'apt-get install nodejs -y'
      ssh.exec! 'npm install forever http-server -g'
    end
  end

  def get_mac_addr(ct_id)
    client.lxc_config(ct_id)['net0'][/hwaddr=(.*?),ip=/m, 1]
  end

  def get_ip(ct_id)
    JSON.parse(RestClient.post(proxmox_dhcp_server_addr, {
      command: 'lease4-get',
      arguments: {
        'identifier-type' => 'hw-address',
        'identifier': get_mac_addr(ct_id),
        'subnet-id':1
      },
      service:['dhcp4']
    }.to_json, {content_type: :json})).first.dig('arguments', 'ip-address')
  end
end
