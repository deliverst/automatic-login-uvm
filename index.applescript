-- details: this code delete cache of safari of microsoft and blackboard, then enter page of blackboard uvm and login with account
-- date: 24/09/22
-- by: deliverst
-- status: finish
-- todo: nothing

set T1 to minutes of (current date)
set T1s to seconds of (current date)

---vars
global mail, pass, mainPage, blackboardPage, ourName

set pages to {"black", "microsoft"} --this use blackboard to save cache
set mainPage to "https://uvmonline.blackboard.com/webapps/portal/execute/tabs/tabAction?tab_tab_group_id=_1_1"
set mail to do shell script("cat ./config/env | head -n1")
set pass to do shell script("cat ./config/env | head -n2 | tail -n1")
set ourName to makeUpperCase(do shell script("cat ./config/env | head -n3 | tail -n1"))
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
					set value of text field 1 of sheet 1 to i
					-- press button "remove all"
					click button "Remove All" of sheet 1
					click button "Remove Now"
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
		make new document at end of documents with properties {URL: blackboardPage}
		
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
			do JavaScript "document.getElementById('i0116').value='"& mail & "'"
			do JavaScript "document.getElementById('idSIButton9').focus()"
			do JavaScript "document.getElementById('idSIButton9').click()"
			delay 1
			do JavaScript "document.getElementById('i0118').value='"& pass & "'"
			do JavaScript "document.getElementById('idSIButton9').focus()"
			do JavaScript "document.getElementById('idSIButton9').click()"
			delay 1
			do JavaScript "document.getElementById('idSIButton9').click()"

			set titlePage to ""
			repeat until (titlePage = "Aviso Importante – Blackboard Learn") or ¬
			(titlePage = "Bienvenido, " & ourName &" – Blackboard Learn")
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

deletecache(pages) of me
enterPage(pages) of me

set T2 to minutes of (current date)
set T2s to seconds of (current date)
set TT_ to ((T2 * 60) + T2s) - ((T1 * 60) + T1s)