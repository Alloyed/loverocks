#!/bin/bash
set -e

echo "::Rewriting version.lua"
echo "return \"$1\"" | tee loverocks/version.lua

echo "::Performing tests"
busted

echo "::Generating rockspec, remember to add tag = \"v$1\""
cd rockspecs
luarocks new_version ../loverocks-scm-0.rockspec $1
$EDITOR "loverocks-${1}.rockspec"
cd ..

echo "::Done. Inspect, then run ./rockspecs/commit-update.sh $1"
