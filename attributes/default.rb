#
# Cookbook:: hms
# Attributes:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
default['hms']['admin_group_name'] = 'mediaadmins'
default['hms']['admin_group_gid'] = '1001'
default['hms']['default_user_shell'] = '/sbin/nologin'
default['hms']['directory_mode'] = '0777'
default['hms']['directory_owner'] = 'root'
default['hms']['file_mode'] = '0755'
default['hms']['file_owner'] = 'root'
default['hms']['timezone'] = 'America/Chicago'

default['hms']['plex']['container_name'] = 'plex'
default['hms']['plex']['network_mode'] = 'host'
default['hms']['plex']['allowed_networks'] = '192.168.1.0/24'
default['hms']['plex']['port'] = '32400:32400/tcp'
default['hms']['plex']['restart_policy'] = 'always'
default['hms']['plex']['volumes'] = [
  '/home/plex:/config',
  '/home/plex:/transcode',
  '/home/media:/data',
]

default['hms']['radarr']['container_name'] = 'radarr'
default['hms']['radarr']['network_mode'] = 'host'
default['hms']['radarr']['restart_policy'] = 'always'
default['hms']['radarr']['port'] = '7878:7878/tcp'
default['hms']['radarr']['volumes'] = [
  '/home/radarr:/config',
  '/home/media:/media',
  '/home/radarr:/data',
  '/home/downloads:/downloads',
]

default['hms']['jackett']['container_name'] = 'jackett'
default['hms']['jackett']['network_mode'] = 'host'
default['hms']['jackett']['restart_policy'] = 'always'
default['hms']['jackett']['port'] = '9117:9117/tcp'
default['hms']['jackett']['volumes'] = [
  '/home/jackett:/config',
  '/home/downloads:/downloads',
]

default['hms']['sonarr']['container_name'] = 'sonarr'
default['hms']['sonarr']['network_mode'] = 'host'
default['hms']['sonarr']['restart_policy'] = 'always'
default['hms']['sonarr']['port'] = ['8989:8989/tcp', '9897:9897/tcp']
default['hms']['sonarr']['volumes'] = [
  '/home/sonarr:/config',
  '/home/downloads:/downloads',
  '/home/media:/media',
  '/home/data:/data',
]

default['hms']['plexpy']['container_name'] = 'plexpy'
default['hms']['plexpy']['network_mode'] = 'host'
default['hms']['plexpy']['restart_policy'] = 'always'
default['hms']['plexpy']['port'] = '8180:8180/tcp'
default['hms']['plexpy']['volumes'] = [
  '/home/plexpy:/config',
  '/home/plex/Library/Application\ Support/Plex\ Media\ Server/Logs:/logs:ro',
]

default['hms']['headphones']['container_name'] = 'headphones'
default['hms']['headphones']['network_mode'] = 'host'
default['hms']['headphones']['restart_policy'] = 'always'
default['hms']['headphones']['port'] = '8181:8181/tcp'
default['hms']['headphones']['volumes'] = [
  '/home/headphones:/config',
  '/home/downloads:/downloads',
  '/home/media/music:/music',
]

default['hms']['pia']['container_name'] = 'pia'
default['hms']['pia']['network_mode'] = 'pia_network'
default['hms']['pia']['restart_policy'] = 'always'
default['hms']['pia']['port'] = [
  '8112:8112/tcp',
  '8080:8080/tcp',
  '9090:9090/tcp',
]
default['hms']['pia']['dns'] = ['209.222.18.222', '209.222.18.218']
default['hms']['pia']['region'] = 'US East'

default['hms']['deluge']['container_name'] = 'deluge'
default['hms']['deluge']['network_mode'] = "container:#{node['hms']['pia']['container_name']}"
default['hms']['deluge']['restart_policy'] = 'always'
default['hms']['deluge']['volumes'] = [
  '/home/downloads:/downloads',
  '/home/deluge:/config',
]

default['hms']['sabnzbd']['container_name'] = 'sabnzbd'
default['hms']['sabnzbd']['network_mode'] = "container:#{node['hms']['pia']['container_name']}"
default['hms']['sabnzbd']['restart_policy'] = 'always'
default['hms']['sabnzbd']['volumes'] = [
  '/home/downloads/completed:/downloads',
  '/home/sabnzbd:/config',
  '/home/downloads/incomplete:/incomplete-downloads',
]

default['hms']['docker']['image_list'] = %w(
  plexinc/pms-docker
  colinhebert/pia-openvpn
  linuxserver/deluge
  linuxserver/jackett
  linuxserver/radarr
  linuxserver/plexpy
  linuxserver/sonarr
  splunk/splunk
  linuxserver/headphones
  linuxserver/sabnzbd
)

default['hms']['directory_list'] = %w(
  /home/plex
  /home/media
  /home/media/tv
  /home/media/movies
  /home/media/music
  /home/deluge
  /home/deluge/openvpn
  /home/downloads
  /home/downloads/incomplete
  /home/downloads/completed
  /home/downloads/seeds
  /home/radarr
  /home/jackett
  /home/sonarr
  /home/plexpy
  /home/headphones
  /home/sabnzbd
)

default['hms']['user_list'] = %w(
  deluge
  plex
  radarr
  sonarr
  jackett
  plexpy
  headphones
  sabnzbd
)

default['hms']['management_package_list'] = %w(
  atop
  htop
  bind-utils
  wget
  vim
)
