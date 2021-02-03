#!/usr/bin/env zsh
case "$OSTYPE" in
  darwin*)
    istats cpu temp --value-only
  ;;
  linux*)
    vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'
  ;;
esac
