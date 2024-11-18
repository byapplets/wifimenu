#!/bin/bash

# Wifidaemon setup
daemon_path=~/.config/rofi/scripts/wifidaemon

# Format network information
format_networks() {
    sed 's/  */ /g' | sed -r "s/WPA*.?\S/ /g" | sed -r "s/^([0-9]+\t)--(\s+\S)/\1  \2/g" | sed "s/  //g" | sed "/--/d" | sed -r "s/\s+$//g" | awk '{
        signal = $1
        security = $2
        if (signal >= 80)
            if (security == "") icon = "󰤪\t"
            else icon = "󰤨\t"
        else if (signal >= 60) 
            if (security == "") icon = "󰤧\t"
            else icon = "󰤥\t"
        else if (signal >= 40)
            if (security == "") icon = "󰤤\t"
            else icon = "󰤢\t"
        else if (signal >= 20)
            if (security == "") icon = "󰤡\t"
            else icon = "󰤟\t"
        else if (security == "") icon = "󰤬\t"
        else icon = "󰤯\t"

        sub(signal, icon)
        print
    }' | sed 's/ //g' | sed -r 's/(\S\t)\s+(.+)/\1\2/g'
}

# Check radio status
connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "disabled" ]]; then
    exit 0
fi

mkdir -p $daemon_path/tmp

# Get list of available wifi stations and current connection
wifi_list=$(nmcli --fields signal,security,ssid device wifi list | sed 1d | format_networks) 
current_wifi=$(nmcli -t -f active,signal,security,ssid dev wifi | grep '^yes' | cut -d ':' -f2,3,4 | sed 's/:/ /g' | format_networks)

# Store data
echo -e "$wifi_list" > $daemon_path/tmp/wifilist
echo -e "$current_wifi" > $daemon_path/tmp/currentwifi

