to createArrayLinksAdnTitles(arrs)
	tell application "Safari"
		tell current tab of window 1
			repeat with i from 1 to count arrs
				if (item i of arrs) starts with "http" or (item i of arrs) starts with "https" then
					set end of links to item i of arrs
				else
					set end of titles to item i of arrs
				end if
			end repeat
		end tell
	end tell
end createArrayLinksAdnTitles