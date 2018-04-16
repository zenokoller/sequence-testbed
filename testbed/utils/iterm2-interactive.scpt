on run argv
  set boxes to {"client", "router", "server"}
  set cmd to "env PATH=/usr/bin:/usr/local/bin make -C " & item 1 of argv
  tell application "iTerm2"
    create window with default profile
    repeat with box in boxes
      tell current session of current window
        split horizontally with default profile command cmd & " sh-" & box
      end tell
    end repeat
  end tell
end run

# vim: ai ts=2 sw=2 et sts=2 ft=applescript
