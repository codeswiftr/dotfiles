#!/usr/bin/osascript
-- Returns the currently playing song in Spotify (macOS)

tell application "Spotify"
  if it is running then
    if player state is playing then
      set track_name to name of current track
      set artist_name to artist of current track

      if (artist_name is not missing value) and (length of artist_name > 0) then
        set t to "♫ " & artist_name & " - " & track_name
        if (length of t > 55) then
          return (text 1 thru 55 of t) & "..."
        else
          return t
        end if
      else
        return "~ " & track_name
      end if
    end if
  end if
end tell
