#!/bin/bash

#!/bin/bash 
echo "run info.sh"
echo "##### args"
for var in "$@"
do
    echo "arg: $var"
done
echo "##### meta"
echo $(date) 
