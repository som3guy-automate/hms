#
# Cookbook:: hms
# Attributes:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
default['hms']['docker']['image_list'] = %w(plexinc/pms-docker binhex/arch-delugevpn linuxserver/jackett linuxserver/radarr linuxserver/plexpy linuxserver/sonarr splunk/splunk)

default['hms']['directory_list'] = %w(/home/plex /home/media /home/media/tv /home/media/movies /home/media/music /home/deluge /home/deluge/openvpn /home/downloads /home/downloads/incomplete /home/downloads/completed /home/downloads/seeds /home/radarr /home/jackett /home/sonarr /home/plexpy)

default['hms']['user_list'] = %w(deluge plex radarr sonarr jackett plexpy)
