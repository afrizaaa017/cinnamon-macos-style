#!/bin/bash
# Geser 3 jari ke atas: di Cinnamon = Overview bawaan, di XFCE = xfdashboard.
case "$XDG_CURRENT_DESKTOP" in
  *Cinnamon*) gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon --method org.Cinnamon.ShowOverview >/dev/null 2>&1 ;;
  *) exec xfdashboard ;;
esac
