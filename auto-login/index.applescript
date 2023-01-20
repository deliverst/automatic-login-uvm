-- details: this code delete cache of safari of microsoft and blackboard, then enter page of blackboard uvm and login with account
-- date: 24/SEP/22
-- by: deliverst
-- status: finish
-- todo: 
-- -> add validation to check if there are cookies to clean

set T1 to minutes of (current date)
set T1s to seconds of (current date)

global mail, pass, mainPage, blackboardPage, ourName, keyTab, keySpace

set keyTab to 48
set keySpace to 49
set pathConfig to POSIX path of (((path to me) as text) & "::") & "../config/env"
set pages to {"black", "microsoft"} --this use blackboard to save cache
set mainPage to "https://uvmonline.blackboard.com/ultra/course"
set mail to do shell script "cat " & pathConfig & "| head -n1"
set pass to do shell script "cat " & pathConfig & "| head -n2 | tail -n1"
set ourName to makeUpperCase(do shell script ("cat " & pathConfig & "| head -n3 | tail -n1"))
set blackboardPage to "https://uvmonline.blackboard.com"

on makeUpperCase(namee)
	return (do shell script "echo \"" & namee & "\"| tr \"[:lower:]\" \"[:upper:]\"")
end makeUpperCase

-- open safari
to deleteCache(pages)
	tell application "Safari"
		activate
		delay 2
		tell application "System Events" to tell process "Safari"
			keystroke "," using command down
			tell window 1
				
				-- privacy window
				click button "Privacy" of toolbar 1
				
				-- manage website data…
				tell button "Manage Website Data…" of group 1 of group 1
					perform action "AXPress"
				end tell
				
				
				-- waiting for button "remove all "
				repeat until (get enabled of button "Remove All" of sheet 1 = true)
					delay 0.2
					-- log "wait button remove all"
				end repeat
				
				repeat with i in pages
					set focused of text field 1 of sheet 1 to true
					set value of text field 1 of sheet 1 to i
					delay 1
					
					-- set nameOfCookie to name of UI element 1 of row 1 of table 1 of scroll area 1 of sheet 1


					if exists (name of UI element 1 of row 1 of table 1 of scroll area 1 of sheet 1) then
						-- press button "remove all"
						-- I try do with (click button "Remove All" of sheet 1) but for some reason, wait 6 or 7 second to click in the nex button, and with tabs and space it's immediately
						key code keyTab
						delay 0.2
						key code keyTab
						delay 0.2
						key code keySpace
						delay 1
						
						repeat until exists (button "Remove Now")
							log "exists"
						end repeat

						if exists (button "Remove Now") then
							delay 0.2
							key code keyTab
							delay 0.2
							key code keySpace
						end if
					else
						click button "Done" of sheet 1
						click button 1
						enterPage(pages) of me
					end if
				end repeat
				click button "Done" of sheet 1
				click button 1
			end tell
		end tell
	end tell
end deleteCache

to enterPage(pages)
	tell application "Safari"
		activate
		delay 1
		-- open safari to go a uvm page
		make new document at end of documents with properties {URL:blackboardPage}
		
		set titlePage to ""
		repeat until titlePage = "Ingreso a Blackboard - UVM Online"
			-- log "wait title of page" &  titlepage
			set titlePage to name of window 1
		end repeat
		
		
		tell document 1
			set res to ""
			repeat until res = "interactive"
				set res to do JavaScript "document.readyState"
				-- log "waiting to change interactive - " & res
			end repeat
		end tell
		
		
		-- click in button login and go to page to type email
		tell current tab of window 1
			do JavaScript "document.getElementById('redirectProvidersDropdownButton').click()"
			set titlePage to ""
			repeat until titlePage = "Sign in to your account"
				-- log "wait to chance title of page " & titlepage
				set titlePage to name
			end repeat
			
			set isLoad to ""
			repeat until isLoad = "complete"
				set isLoad to do JavaScript "document.readyState"
				-- log "wait to change status page complete " & isload
			end repeat
			
			delay 1
			do JavaScript "document.getElementById('i0116').value='" & mail & "'"
			do JavaScript "document.getElementById('idSIButton9').focus()"
			do JavaScript "document.getElementById('idSIButton9').click()"
			delay 1
			do JavaScript "document.getElementById('i0118').value='" & pass & "'"
			do JavaScript "document.getElementById('idSIButton9').focus()"
			do JavaScript "document.getElementById('idSIButton9').click()"
			delay 1
			do JavaScript "document.getElementById('idSIButton9').click()"
			
			set titlePage to ""
			repeat until (titlePage = "Aviso Importante – Blackboard Learn") ¬
			             or (titlePage = "Bienvenido, " & ourName & " – Blackboard Learn") ¬
			             or (titlePage = "Enlaces de interés")
				set titlePage to name
				-- log titlepage
			end repeat
			
			repeat until res = "complete"
				set res to do JavaScript "document.readyState"
				-- log res
			end repeat
			
			set URL to mainPage
			delay 5
			do JavaScript "document.getElementById('agree_button').click()"
		end tell
	end tell
end enterPage

deleteCache(pages) of me
-- enterPage(pages) of me

set T2 to minutes of (current date)
set T2s to seconds of (current date)
set TT_ to ((T2 * 60) + T2s) - ((T1 * 60) + T1s)