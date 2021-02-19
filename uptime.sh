#!/bin/sh

dayCount=$( uptime | awk -F "(up | days)" '{ print $2 }' )

if ! [ "$dayCount" -eq "$dayCount" ] 2> /dev/null ; then
    dayCount="0"
fi

echo "<result>$dayCount</result>"

exit 0
