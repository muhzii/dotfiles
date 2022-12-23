#!/bin/bash -ue

while true; do
    read -p "Connect to WiFi? " yn
    case $yn in
        [Yy]*)
            read -p "Enter name of wireless device: " dev
            iwctl station $dev scan
            iwctl station $dev get-networks
            if [ $? -eq 0 ]; then
                read -p "Enter SSID: " ssid
                iwctl station $dev connect $ssid
                if [ $? -eq 0 ]; then
                    break 2
                fi
            fi
            ;;
        [Nn]*)
            break 2
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done

timeout 10s bash -c 'until ping -c 1 8.8.8.8 &> /dev/null; do sleep 0.5; done'
if [ $? -ne 0 ]; then
    echo "Not connected to internet!" && exit 1
fi
