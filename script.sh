for quoted_package in $(cat packages.json | jq .rows[].project)
do
    unquoted_package=${quoted_package//\"}
    git branch -D $unquoted_package
    git push origin --delete $unquoted_package
    git checkout -b $unquoted_package
    poetry add $unquoted_package
    git add --all
    git commit -m $unquoted_package
    git push
    git checkout main
done
