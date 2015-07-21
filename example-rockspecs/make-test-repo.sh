#!/bin/sh
for f in example-rockspecs/*.rockspec; do
	luarocks pack $f
done && mkdir -p test-repo && mv *.src.rock test-repo

cd test-repo && luarocks-admin make_manifest .

cd ..
