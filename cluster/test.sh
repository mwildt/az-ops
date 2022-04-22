#/bin/bash

args=('asd1' "asöld" 1 2 3 4 5)

read -ra slice <<< ${args[@]:1:2}

echo $slice


for var in "${slice[@]}"
do
    echo "arg: $var"
done

# #pass as array
#echo "run @"
#./cluster/info.sh "${args[@]}"

# expolode
#echo "run *"
#./cluster/info.sh "${args[*]}"
