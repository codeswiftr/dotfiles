#!/usr/bin/env zsh
case "$OSTYPE" in
  darwin*)
    istats cpu temp --only-value
  ;;
  linux*)
    vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'
  ;;
esac
