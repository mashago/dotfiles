#!/bin/bash

luacheck_log=luachecklog.txt
my_log=myluachecklog.txt
rm -rf $my_log
touch $my_log

luacheck ./lualib --no-color -q --codes --config ../.luacheckrc > $luacheck_log
luacheck ./service --exclude-files ./service/agent/ --no-color -q --codes --config ../.luacheckrc >> $luacheck_log
luacheck ./service/agent --no-color -q --codes --config ../.luacheckrc >> $luacheck_log

change_files=`git diff --name-only`
#change_files=`git diff --name-only c3e469b4b573c4b878d87cff4d5a80154c365975 1f5cbe5f741a11a40aa35225355a1c31a34eae08`
#echo $change_files

custom_files=(
#'service/agent/player/fireworks.lua'
)

for file in "${custom_files[@]}"
do
    grep "$file" $luacheck_log >> $my_log
done

for file in $change_files
do
    grep "$file" $luacheck_log >> $my_log
done
cat $my_log
