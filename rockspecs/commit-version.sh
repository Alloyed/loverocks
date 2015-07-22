echo "::Committing $1"
git add "rockspecs/loverocks-${1}.rockspec" "loverocks/version.lua"
git commit -m "Release $1"

echo "::Adding tag"
git tag -a "v$1" -m "Version $1"

echo "::Pushing to github"
git push origin master

echo "::Uploading to luarocks"
luarocks upload "rockspecs/loverocks-${1}.rockspec" $2
