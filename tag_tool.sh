#!/bin/bash
DEV_PROPERTIES="../orcDevPlattform.properties"
PSC_DIRECTORY="./sc_*"
ORC_JAVA_HOME="D:/Program Files/Java/jre6"
ORC_JAVA_HOME="C:/Program Files/Java/jdk1.8.0_231"
ORC_HOME="D:/data/Orchestra/Designer/app_4812/orchestra"
ORC_JAVA_EXEC="$ORC_JAVA_HOME/bin/java"
ORC_HOME_WEBINF="$ORC_HOME/WEB-INF"

# lastTag=`git tag -l | sort -n | tail -1`
lastTag=`git tag --sort=committerdate | tail -1`
minor=${lastTag##*.}
major=${lastTag%.*}
let newMinor=$minor+1
echo "Last tag was: $lastTag"
echo "Enter new tag and confirm with Enter"
echo "Press Enter only to accept this proposal [$major.$newMinor]"
echo "Just press Space and confirm with Enter to not tag"
echo "Press Strg-C or Ctrl-C together to cancel the operation"

while true; do
IFS='' read -p "[$major.$newMinor]" newTag
if [ -z "$newTag" ] ; then
newTag="$major.$newMinor"
break;
elif [ "$newTag" == " " ] ; then
newTag=""
break;
fi
if [[ ${newTag} =~ [0-9]+.[0-9]+.[0-9]+$ ]]; then
echo richtige eingabe
break;
fi

done

PSC_NAME=`ls | grep sc | head -n 1`

if [ -z "$newTag" ] ; then
echo "Wird nicht getagged"
PSC_NAME=${PSC_NAME}.psc
else
newTag="v"$newTag
echo "Neuer Tag: $newTag"
git tag $newTag
PSC_NAME=${PSC_NAME}_$newTag.psc
echo "Erfolgreich getaggt"
#git push
#git push --tag
fi
echo $PSC_NAME
CP="$ORC_HOME_WEBINF/classes/;$ORC_HOME_WEBINF/lib/*;$ORC_HOME/lib_designer/*"
"$ORC_JAVA_EXEC" -Xms512M -cp "$CP" emds.epi.impl.run.PscTool multi . . > ./PSC_Tool.log

mv *.psc $PSC_NAME

#orcmd deploy "@$DEV_PROPERTIES" $PSC_DIRECTORY/$pscFile


if [ -z "$newTag" ] ; then
echo "Kein Tag, wird nicht ins Nexus übermittelt"
else
#echo "maven hier bedienen :-)"
mv $PSC_NAME /d/data/Git_Repositories/orc-deployment/Tag_Tool/
fi