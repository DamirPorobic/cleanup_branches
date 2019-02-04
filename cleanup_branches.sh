#!/bin/sh

IS_DRYRUN="true"

if [ "$1" = "-f" ]; then
	IS_DRYRUN="false"
fi

if [ "$IS_DRYRUN" = "true" ]; then
	echo "*** DRY RUN ***"
	echo "Only printing out what would be deleted"
	echo "If you want to delete branches, run with -f flag."
else
	echo "Deleting branches..."
fi

echo "Get latest from remote before we start..."
git fetch

COUNT=0
DELETE_THRESHOLD=$(date -d "last month" +%s)

for BRANCH in $(git branch -r --merged)
do
	LAST_COMMIT_DATE=$(date -d "$(git show --format="%ci" $BRANCH | head -n 1)" +%s)

	if [ $LAST_COMMIT_DATE -lt $DELETE_THRESHOLD ]; then

		BRANCH_WITHOUT_ORIGIN=${BRANCH#"origin/"}

		if [ "$IS_DRYRUN" = "true" ]; then
			echo "$BRANCH_WITHOUT_ORIGIN -> DELETE" 
		else
			git push origin --delete $BRANCH_WITHOUT_ORIGIN
		fi
	        
		if [ $? -eq 0 ]; then
                	COUNT=$(expr $COUNT + 1)
                fi

	fi
done

if [ "$IS_DRYRUN" = "true" ]; then
	echo "Branches affected: $COUNT"
else
	echo "Branches deleted: $COUNT"
	echo "Fetching remote and removing local branches."
	git fetch -p
fi

echo "Done"

