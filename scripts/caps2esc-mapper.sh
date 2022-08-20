#!/bin/bash

evdev=$1

is_kbd=$(ls -al /dev/input/by-path/ | grep $evdev | grep kbd)
if [ ! -z "$is_kbd" ]; then
    evscript -f /usr/local/share/caps2esc_mapper.dyon -d /dev/input/$evdev
fi
