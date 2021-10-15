#!/bin/bash

sleep 3

# supercollider
export DISPLAY=:0.0
QT_QPA_PLATFORM=offscreen sclang /home/oscar/sc.scd
#QT_QPA_PLATFORM=vnc sclang /home/oscar/scGUI.scd
