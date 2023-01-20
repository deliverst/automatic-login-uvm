-- details: this code delete cache of safari of microsoft and blackboard, then enter page of blackboard uvm and login with account
-- date: 24/SEP/22
-- by: deliverst
-- status: finish
-- todo: 
-- -> add validation to check if there are cookies to clean

set T1 to minutes of (current date)
set T1s to seconds of (current date)

use framework "Foundation"
use scripting additions

global mail, pass, mainPage, blackboardPage, ourName, keyTab, keySpace, allMonths

set keyTab to 48
set keySpace to 49
set pathConfig to POSIX path of (((path to me) as text) & "::") & "../config/env"
set pages to {"black", "microsoft"} --this use blackboard to save cache
set mainPage to "https://uvmonline.blackboard.com/ultra/course"
set mail to do shell script "cat " & pathConfig & "| head -n1"
set pass to do shell script "cat " & pathConfig & "| head -n2 | tail -n1"
set ourName to makeUpperCase(do shell script ("cat " & pathConfig & "| head -n3 | tail -n1"))
set blackboardPage to "https://uvmonline.blackboard.com"
set allMonths to {ENE:"January", FEB:"February", MAR:"March", ABR:"April", May:"May", JUN:"June", JUL:"July", AGO:"August", SEP:"September", OCT:"Octuber", NOV:"November", DEC:"December"}


to exportData(d)
	do shell script "echo " & d & ">> tempData.sh"
end exportData


to addZeroIncrementNumber(n)
	if n ≤ 9 then
		return "0" & n
	else
		return n
	end if
end addZeroIncrementNumber

on getDate(dat)
	set s to "on run {allMonths}
		get " & dat & " of allMonths
	end"
	
	run script s with parameters {allMonths}
end getDate

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

to parseDate(textDate)
	set theDelimiter to "-"
	set oldDelimiters to text item delimiters
	set text item delimiters to theDelimiter
	set theTextItems to text items of textDate
	set abreviationMonth to get item 2 of theTextItems as text
	set nameCompleteMonth to getDate(abreviationMonth)
	set dateComplete to (get item 1 of theTextItems) & " " & nameCompleteMonth & " " & (get item 3 of theTextItems)
	set pDate to date (dateComplete & ", 3:00 a.m.")
	return pDate
end parseDate

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
					
					-- TODO: add validation to check if there are cookies to clean
					
					-- press button "remove all"
					-- I try do with (click button "Remove All" of sheet 1) but for some reason, wait 6 or 7 second to click in the nex button, and with tabs and space it's immediately
					key code keyTab
					delay 0.2
					key code keyTab
					delay 0.2
					key code keySpace
					delay 0.2
					
					repeat until exists (button "Remove Now")
						log "exists"
					end repeat
					if exists (button "Remove Now") then
						delay 0.2
						key code keyTab
						delay 0.2
						key code keySpace
					end if
				end repeat
				
				click button "Done" of sheet 1
				click button 1
				
			end tell
		end tell
	end tell
end deleteCache

to loginPage()
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
		end tell
	end tell
end loginPage

to parseFloateNumber(totalPage)
	set t to do shell script "echo " & totalPage & "| sed -E 's/\\.0//'"
	return t
end parseFloateNumber

to enterPage(pages)
	tell application "Safari"
		
		
		loginPage() of me
		
		
		-- click in button login and go to page to type email
		tell current tab of window 1
			
			set totalSubjects to parseFloateNumber(do JavaScript "document.querySelectorAll('.course-org-list h4').length") of me
			
			repeat with i from 0 to totalSubjects - 1
				set nameOfSubject to do JavaScript "document.querySelectorAll('.course-org-list h4')[" & i & "].innerHTML"
				if nameOfSubject is not "'Curso de inducción'" then
					set nameOfSubject to do JavaScript "document.querySelectorAll('.course-org-list h4')[" & i & "].innerHTML"
					set idCour to do JavaScript "document.querySelectorAll('.course-org-list h4')[" & i & "].parentElement.getAttribute('id')"
					
					set nameProfessor to toCapitalize(do JavaScript "document.querySelectorAll('.ellipsis div bdi')[" & i & "].innerText") of me
					do shell script "echo " & nameProfessor & " >> tempData.sh"
					
					do JavaScript "document.querySelector('#" & idCour & "').click()"
					delay 5
					set idCalifas to do shell script "echo " & idCour & "| sed 's/course-link-//'"

					set scorePage to "https://uvmonline.blackboard.com/webapps/blackboard/content/launchLink.jsp?course_id=" & idCalifas & "&tool_id=_133_1&tool_type=TOOL&mode=view&mode=reset"
					set URL to scorePage
					
					delay 5
					
					set totalHomework to do JavaScript "document.getElementById('grades_wrapper').childElementCount"
					set nameOfSubject to toCapitalize(do JavaScript "document.getElementById('crumb_1').innerText") of me
					do shell script "echo " & nameOfSubject & " >> tempData.sh"
					set t to do shell script "echo " & totalHomework & "| sed -E 's/\\.0//'"
					
					delay 2
					
					repeat with i from t - 1 to 1 by -1
						set indexOfHomework to do JavaScript "document.getElementById('grades_wrapper').childElements()[" & i & "]?.childNodes?.[3]?.childElements()?.[0]?.innerText.match(/\\d/)"
						set indexParsed to addZeroIncrementNumber(indexOfHomework) of me
						set titleOfHomework to toCapitalize(do JavaScript "document.getElementById('grades_wrapper').childElements()[" & i & "]?.childNodes?.[3]?.childElements()?.[0]?.innerText.replace(\"Actividad \", \"\").replace(/^\\d\\. /, \"\" )") of me
						set dateOfHomework to do JavaScript "document.getElementById('grades_wrapper').childElements()[" & i & "]?.childNodes?.[3]?.childElements()?.[1]?.innerText.replace(\"VENCIMIENTO: \", \"\")"
						set titleCompleteCalendar to "Act " & indexParsed & ".- " & titleOfHomework & " | " & nameOfSubject
						set dateComplete to parseDate(dateOfHomework) of me
						do shell script "echo " & indexParsed & ".- " & titleOfHomework & " >> tempData.sh"
						
						
						set loc to "UVM - Campus Chihuahua Universidad del Valle de México, 31220 Chihuahua, CHIH, Mexico"
						set link to do JavaScript "location.href"
						set desc to "Profesor: " & nameProfessor & "
Cuatrimestre: 5to"
						
						tell application "Calendar"
							tell calendar "UVM Universidad"
								set newEvent to make new event at end with properties {¬
									summary: titleCompleteCalendar, ¬
									start date:(dateComplete), ¬
									end date:((dateComplete) + (1 * hours)), ¬
									location: loc, ¬
									url: link, ¬
									description: desc ¬
								}
								tell newEvent
								        make new sound alarm at end of sound alarms with properties {trigger interval:-240, sound name:"Crystal"}
								        make new sound alarm at end of sound alarms with properties {trigger interval:-30, sound name:"Crystal"}
								end tell
							end tell
						end tell

					end repeat
					
					set URL to mainPage
					delay 5
					do shell script "./parse-data.sh"
					do shell script "./create-templates.sh"
					do shell script "rm tempDataParsed.sh"
				end if
			end repeat
		end tell
	end tell
end enterPage

deleteCache(pages) of me
enterPage(pages) of me


set T2 to minutes of (current date)
set T2s to seconds of (current date)
set TT_ to ((T2 * 60) + T2s) - ((T1 * 60) + T1s)