for quoted_package in $(cat packages.json | jq .rows[].project)
do
    unquoted_package=${quoted_package//\"}
    git rev-parse --quiet --verify $unquoted_package
    rc=$?
    if [[ $rc = 0 ]]; then
        Package is already handled
    else
        git checkout -b $unquoted_package
        poetry add $unquoted_package
        git add --all
        git commit -m $unquoted_package
        git push
        git checkout main
    fi
done
