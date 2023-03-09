#!/bin/bash

# details: this code automates creation of folder, subfolders, and each file pages to each subject and activities, change name of each file with the correct data like, teacher, subject, activiti
# date: 31/10/22
# by: deliverst
# status: finish
# todo:
# 1.- refactor path routes, more legible

# import subjects, name of professor and names of homeworks
source "tempDataParsed.sh"

SchoolCycle="5to Cuatrimestre"
mainPath="/Users/deliverst/Library/Mobile Documents/com~apple~CloudDocs/UVM"

for ((x = 0; x < ${#activities[@]}; x++)); do
	numOfActivity=$(echo "A"${activities[$x]} | sed -E 's/\..+//')          # return examples A01 or A02 or A03 or A04 ...
	nameOftemplate=$(ls "$mainPath/Documents/Template/" | grep ".pages")    # jobs.pages
	template="$mainPath/Documents/Template/$nameOftemplate"                 # $mainPath/Documents/Template/jobs.pages
	destinationTemplate="$mainPath/$SchoolCycle/$subject/A${activities[x]}" # $mainPath/nto Cuatrimestre/Empatia para Resolver/A01.- Identidad Personal
	structureFolder="$destinationTemplate/Recources"                        # $mainPath/nto Cuatrimestre/Empatia para Resolver/A01.- Identidad Personal/Recursos
	currentNameTemplate="$destinationTemplate/$nameOftemplate"              # $mainPath/nto Cuatrimestre/Empatia para Resolver/jobs.pages
	newNameTemplate="$destinationTemplate/$numOfActivity""_JVV.pages"       # $mainPath/nto Cuatrimestre/Empatia para Resolver/A01_JVV.pages

	mkdir -p "$structureFolder"

	cp "$template" "$destinationTemplate"

	# rename file
	mv "$currentNameTemplate" "$newNameTemplate"

	while [[ ! -f "$newNameTemplate" ]]; do
		echo "waiting for finish copy template"
	done

	open "$newNameTemplate"

	osascript >/dev/null <<EOF
		on replaceText(matchWord, wordToReplace)
			tell application "Pages"
				activate
				tell the front document
					tell body text
						-- start at the end and go to the beginning
						repeat with i from the (count of paragraphs) to 1 by -1
							tell paragraph i
								repeat
									try
										if exists matchWord then
											set (last word where it is matchWord) to wordToReplace
										else
											exit repeat
										end if
									on error errorMessage
										exit repeat
									end try
								end repeat
							end tell
						end repeat
					end tell
				end tell
				return true
			end tell
		end replaceText

		tell application "Pages"
				repeat
					if exists (window 1)
						activate
						my replaceText("MAT", "$subject")
						my replaceText("ACT", "${activities[x]}")
						my replaceText("PRO", "$teacher")
						exit
					end if
				end repeat
				close window 1
			end tell
EOF
done
