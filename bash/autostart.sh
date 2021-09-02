#!/bin/bash

# ossia-score
# QT_QPA_PLATFORM=offscreen ossia-score --no-gui --autoplay
QT_QPA_PLATFORM=vnc ossia-score

# supercollider
export DISPLAY=:0.0
#sleep 10
#QT_QPA_PLATFORM=offscreen sclang /home/oscar/sc.scd
#QT_QPA_PLATFORM=vnc sclang /home/oscar/sc.scd
