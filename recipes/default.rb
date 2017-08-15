#
# Cookbook:: hms
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'yum-epel'

# execute 'yum_update_all' do
#   command 'yum update -y'
# end

# TODO: Figure out users
group 'mediaadmins' do
  gid '1001'
  action :create
end

user_list = node['hms']['user_list']
user_list.each do |usr|
  user usr do
    home "/home/#{usr}"
    shell '/sbin/nologin'
    comment "User for #{usr} service"
  end
end

group 'mediaadmins' do
  gid '1001'
  action :modify
  members node['hms']['user_list']
  append true
end

# TODO: Create service directories and where data will be located.

# Create directories
directory_list = node['hms']['directory_list']
directory_list.each do |dir_list|
  directory dir_list do
    owner 'root'
    group 'mediaadmins'
    mode '0777'
    action :create
  end
end

# Land all of the files needed for deluge.
file_list = %w(client.ovpn ca.rsa.2048.crt crl.rsa.2048.pem)
file_list.each do |flist|
  cookbook_file "/home/deluge/openvpn/#{flist}" do
    source flist
    owner 'root'
    group 'mediaadmins'
    mode '0755'
    action :create
  end
end

# TODO: Install and configure docker
package 'docker'

service 'docker' do
  action %i(enable start)
end

docker_image_list = node['hms']['docker']['image_list']
docker_image_list.each do |dimg|
  docker_image dimg
end

docker_container 'delugevpn' do
  repo 'binhex/arch-delugevpn'
  cap_add 'NET_ADMIN'
  port ['8112:8112/tcp', '8118:8118/tcp', '58846:58846/tcp', '8946:58946']
  env ['VPN_ENABLED=yes', 'VPN_USER=USERNAME', 'VPN_PASS=PASSWORD', 'VPN_REMOTE="us-midwest.privateinternetaccess.com 1198"', 'VPN_PROV=pia', 'STRICT_PORT_FORWARD=no', 'ENABLE_PRIVOXY=yes', 'LAN_NETWORK=192.168.33.0/24', 'NAME_SERVERS=209.222.18.218,209.222.18.222', 'DEBUG=true', 'UMASK=003', 'PUID=1002', 'PGID=1001']
  volumes ['/home/deluge:/data', '/home/deluge:/config', '/etc/localtime:/etc/localtime:ro' '/home/downloads:/downloads', '/home/media:/media']
end

docker_container 'plex' do
  repo 'plexinc/pms-docker'
  network_mode 'host'
  env ['TZ="America/Chicago"', 'PLEX_CLAIM="fq4UD27j1sDJnMJLZNsg"', 'PLEX_UID="1003"', 'PLEX_GID="1001"', 'ALLOWED_NETWORKS="10.0.2.0/24"']
  volumes ['/home/plex:/config', '/home/plex:/transcode', '/home/media:/data']
  restart_policy 'always'
  port '32400:32400/tcp'
  action :run
end

docker_container 'radarr' do
  repo 'linuxserver/radarr'
  restart_policy 'always'
  env ['PUID=1004', 'PGID=1001', 'TZ="America/Chicago"']
  volumes ['/home/radarr:/config', '/home/media:/media', '/home/radarr:/data', '/home/downloads:/downloads']
  port ['7878:7878/tcp']
  action :run
end

docker_container 'jackett' do
  repo 'linuxserver/jackett'
  restart_policy 'always'
  env ['PUID=1005', 'PGID=1001', 'TZ="America/Chicago"']
  volumes ['/home/jackett:/config', '/home/downloads:/downloads']
  port ['9117:9117/tcp']
  action :run
end

docker_container 'sonarr' do
  repo 'linuxserver/sonarr'
  restart_policy 'always'
  env ['PUID=1006', 'PGID=1001', 'TZ="America/Chicago"']
  volumes ['/home/sonarr:/config', '/home/downloads:/downloads', '/home/media:/media', '/home/data:/data']
  port ['8989:8989/tcp', '9897:9897/tcp']
  action :run
end

docker_container 'plexpy' do
  repo 'linuxserver/plexpy'
  restart_policy 'always'
  env ['PUID=119', 'PGID=1006', 'TZ="America/Chicago"']
  volumes ['/home/plexpy:/config', '/home/plex/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs:ro']
  port ['8113:8181/tcp']
  action :run
end

# TODO: Install and configure Prometheus
# TODO: Install and configure Grafana for Promeathus
# TODO: Install and configure APC management tool
# TODO: Configure firewall
# TODO: Configure and enable SELinux
