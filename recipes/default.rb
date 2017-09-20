#
# Cookbook:: hms
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'yum-epel'

# execute 'yum_update_all' do
#   command 'yum update -y'
# end
secret = Chef::EncryptedDataBagItem.load_secret('/etc/chef/encrypted_data_bag_secret')
secrets = Chef::EncryptedDataBagItem.load('credentials', 'hms', secret)

plex_claim_token = secrets['plex_claim']
pia_un = secrets['pia_username']
pia_passwd = secrets['pia_password']

management_package_list = node['hms']['management_package_list']
management_package_list.each do |package|
  yum_package package do
    action :install
    options '--quiet'
  end
end

group node['hms']['admin_group_name'] do
  gid node['hms']['admin_group_gid']
  action :create
end

user_list = node['hms']['user_list']
user_list.each do |usr|
  user usr do
    home "/home/#{usr}"
    shell node['hms']['default_user_shell']
    comment "User for #{usr} service"
  end
end

group node['hms']['admin_group_name'] do
  gid node['hms']['admin_group_gid']
  action :modify
  members node['hms']['user_list']
  append true
end

# Create directories
directory_list = node['hms']['directory_list']
directory_list.each do |dir_list|
  directory dir_list do
    owner node['hms']['directory_owner']
    group node['hms']['admin_group_name']
    mode node['hms']['directory_mode']
    action :create
  end
end

package 'docker'

service 'docker' do
  action %i(enable start)
end

docker_image_list = node['hms']['docker']['image_list']
docker_image_list.each do |dimg|
  docker_image dimg
end

docker_container node['hms']['plex']['container_name'] do
  sensitive true
  network_mode node['hms']['plex']['network_mode']
  repo 'plexinc/pms-docker'
  env [
    "TZ=#{node['hms']['timezone']}",
    "PLEX_CLAIM=#{plex_claim_token}",
    'PLEX_UID="1001"',
    "PLEX_GID=#{node['hms']['admin_group_gid']}",
    "ALLOWED_NETWORKS=#{node['hms']['plex']['allowed_networks']}",
  ]
  volumes node['hms']['plex']['volumes']
  restart_policy node['hms']['plex']['restart_policy']
  port node['hms']['plex']['port']
  action :run
end

docker_container node['hms']['radarr']['container_name'] do
  network_mode node['hms']['radarr']['network_mode']
  repo 'linuxserver/radarr'
  restart_policy node['hms']['radarr']['restart_policy']
  env [
    'PUID=1002',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
  ]
  volumes node['hms']['radarr']['volumes']
  port node['hms']['radarr']['port']
  action :run
end

docker_container node['hms']['jackett']['container_name'] do
  network_mode node['hms']['jackett']['network_mode']
  repo 'linuxserver/jackett'
  restart_policy node['hms']['jackett']['restart_policy']
  env [
    'PUID=1004',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
  ]
  volumes node['hms']['jackett']['volumes']
  port node['hms']['jackett']['port']
  action :run
end

docker_container node['hms']['sonarr']['container_name'] do
  network_mode node['hms']['sonarr']['network_mode']
  repo 'linuxserver/sonarr'
  restart_policy node['hms']['sonarr']['restart_policy']
  env [
    'PUID=1003',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
  ]
  volumes node['hms']['sonarr']['volumes']
  port node['hms']['sonarr']['port']
  action :run
end

docker_container node['hms']['plexpy']['container_name'] do
  network_mode node['hms']['plexpy']['network_mode']
  repo 'linuxserver/plexpy'
  restart_policy node['hms']['plexpy']['restart_policy']
  env [
    'PUID=1005',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
    'HTTP_PORT=8180',
  ]
  volumes node['hms']['plexpy']['volumes']
  port node['hms']['plexpy']['port']
  action :run
end

docker_container node['hms']['headphones']['container_name'] do
  network_mode node['hms']['headphones']['network_mode']
  repo 'linuxserver/headphones'
  restart_policy node['hms']['headphones']['restart_policy']
  env [
    'PUID=1006',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
  ]
  volumes node['hms']['headphones']['volumes']
  port node['hms']['headphones']['port']
  action :run
end

docker_network 'pia_network' do
  action :create
end

docker_container node['hms']['pia']['container_name'] do
  sensitive true
  network_mode node['hms']['pia']['network_mode']
  repo 'colinhebert/pia-openvpn'
  restart_policy node['hms']['pia']['restart_policy']
  cap_add 'NET_ADMIN'
  privileged true # set this to remove devices option.
  dns node['hms']['pia']['dns']
  env [
    "REGION=#{node['hms']['pia']['region']}",
    "USERNAME=#{pia_un}",
    "PASSWORD=#{pia_passwd}",
  ]
  port node['hms']['pia']['port']
  action :run
end

docker_container node['hms']['deluge']['container_name'] do
  network_mode node['hms']['deluge']['network_mode']
  repo 'linuxserver/deluge'
  restart_policy node['hms']['deluge']['restart_policy']
  env [
    'PUID=1000',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
    'UMASK_SET=022',
  ]
  volumes node['hms']['deluge']['volumes']
  action :run
end

# sabnzbd
docker_container node['hms']['sabnzbd']['container_name'] do
  network_mode node['hms']['sabnzbd']['network_mode']
  repo 'linuxserver/sabnzbd'
  restart_policy node['hms']['sabnzbd']['restart_policy']
  env [
    'PUID=1007',
    "PGID=#{node['hms']['admin_group_gid']}",
    "TZ=#{node['hms']['timezone']}",
  ]
  volumes node['hms']['sabnzbd']['volumes']
  action :run
end

# TODO: Install and configure Prometheus
# TODO: Install and configure Grafana for Promeathus
# TODO: Install and configure APC management tool
# TODO: Install OSSEC

# TODO: Configure firewall
# Had to run: iptables -I INPUT 4 -i docker0 -j ACCEPT for sonarr to speak to jackett. (Not likely needed anymore)
# May not need now that they are all on host mode.

# TODO: Configure and enable SELinux if possible, docker may not work.
