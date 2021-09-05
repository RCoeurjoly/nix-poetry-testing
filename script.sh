for quoted_package in $(cat packages_small.json | jq .rows[].project)
do
    unquoted_package=${quoted_package//\"}
    git checkout -b $unquoted_package
    poetry add $unquoted_package
    git add --all
    git commit -m \"Install $unquoted_package with poetry\"
    git push
    git checkout main
done
