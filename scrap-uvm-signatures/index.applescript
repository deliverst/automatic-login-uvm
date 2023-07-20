-- https://eastmanreference.com/complete-list-of-applescript-key-codes


use framework "Foundation"
use scripting additions

global keyTab, keySpace, keyDown, myArray, titles, links, signature
set keyTab to 48
set keySpace to 49
set keyDown to 125

to toCapitalize(aString)
	set aNSString to current application's NSString's stringWithString:aString
	set aNSString to aNSString's localizedCapitalizedString()'s mutableCopy()
	
	-- After getting the capitalized string, use a regex to locate any runs of digits followed by letters:
	set aRegex to current application's NSRegularExpression's regularExpressionWithPattern:("\\d++[[:alpha:]]++") options:(0) |error|:(missing value)
	set matchRanges to (aRegex's matchesInString:(aNSString) options:(0) range:({0, aNSString's |length|()}))'s valueForKey:("range")
	
	-- If any are found, replace them with lower-case versions.
	repeat with i from (count matchRanges) to 1 by -1
		set thisRange to item i of matchRanges
		set matchedWord to (aNSString's substringWithRange:(thisRange))
		tell aNSString to replaceCharactersInRange:(thisRange) withString:(matchedWord's localizedLowercaseString())
	end repeat
	
	return aNSString as text
	
end toCapitalize

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


-- set functions
to createFolderBookmark(nameFolder)
	tell application "System Events"
		tell application process "Safari"
			set frontmost to true
			click (4th menu item of menu 1 of menu bar item 7 of menu bar 1)
			delay 1
			click button "New Folder" of group 1 of tab group 1 of splitter group 1 of window "Bookmarks"
			delay 1
			keystroke nameFolder
			keystroke return
		end tell
	end tell
end createFolderBookmark

to saveToBookmark(nameActivity, nameFolder)
	tell application "System Events"
		tell application process "Safari"
			delay 1
			click (6th menu item of menu 1 of menu bar item 7 of menu bar 1)
			delay 1
			key code keyDown
			delay 1
			keystroke nameFolder
			delay 1
			keystroke return
			delay 1
			key code keyTab
			delay 1
			keystroke nameActivity
			delay 1
			keystroke return
			delay 1
		end tell
	end tell
end saveToBookmark




to waitToLoadPage()
	tell application "Safari"
		tell current tab of window 1
			set isLoad to ""
			repeat until isLoad = "interactive" or isLoad = "complete"
				set isLoad to do JavaScript "document.readyState"
				log "wait to change status page complete " & isLoad
			end repeat
		end tell
	end tell
end waitToLoadPage

tell application "Safari"
	tell current tab of window 1
		set signature to do JavaScript "document.querySelector('#breadcrumbs span').innerText"
		log toCapitalize(signature) of me
		set totalSubjects to do JavaScript "
	var listOfNodess = document.querySelector('#courseMenuPalette_contents').childNodes
	var count = 0
	var links = []

	for (var i = 0; i < listOfNodess.length; i++) {
		if(listOfNodess[i].innerText.includes('Unidad')){
			links.push(listOfNodess[i].querySelector('a').href)
		}
	}

	links;

	"
		
		-- log ""
		-- log count totalSubjects
		-- log ""
		
		set myArray to {}
		set titles to {}
		set links to {}
		
		repeat with i from 1 to count totalSubjects
			-- log item i of totalSubjects
			do JavaScript "window.location = '" & item i of totalSubjects & "'"
			
			
			delay 2
			
			waitToLoadPage() of me
			
			set activities to do JavaScript "
		var activities = []
		var nodes = document.querySelectorAll('h3')
		for (var i = 0; i < nodes.length; i++) {
			if (nodes[i].querySelector('a')){
				if(!nodes[i].innerText.includes('Diagnóstico')){
					if (nodes[i].querySelector('a').href.includes('uploadAssignment') || nodes[i].querySelector('a').href.includes('launchAssessment') || nodes[i].querySelector('a').href.includes('launchLink')) {
						activities.push(nodes[i].innerText)
						activities.push(nodes[i].querySelector('a').href)
					}
				}
			}
		}
		activities
		"
			
			
			-- set end of myArray to activities
			-- log count activities
			createArrayLinksAdnTitles(activities) of me
			
			
			
			
		end repeat
		-- inside safari
		set creationFolder to 0
		repeat with i from 1 to count titles
			
			if creationFolder = 0 then
				set titleSignature to toCapitalize(signature) of me
				createFolderBookmark(titleSignature) of me
				set creationFolder to creationFolder + 1
			end if
			
			do JavaScript "window.location.href = '" & (item i of links) & "'"
			
			delay 1
			
			saveToBookmark((item i of titles), titleSignature) of me
			
			-- log item i of titles
			-- log item i of links
		end repeat
		
	end tell
	
end tell



