#!/bin/bash

# export name of professor
nameOfProfessor=$(cat tempData.sh | head -n 1)
echo "export teacher=\"$nameOfProfessor\"" >>tempDataParsed.sh

# export name of subject
subject=$(cat tempData.sh | head -n 2 | tail -n 1)
echo "export subject=\"$subject\"" >>tempDataParsed.sh

while read line; do
	homework+="\"$line\""
done < <(cat tempData.sh | tail -n +3)

# export name of homeworks
homeworks=$(echo $homework | sed 's/\"\"/\" \"/g')
echo "export activities=($homeworks)" >>tempDataParsed.sh

# delete temp file
rm "tempData.sh"
