for quoted_package in $(cat packages_small.json | jq .rows[].project)
do
    unquoted_package=${quoted_package//\"}
    echo git checkout -b $unquoted_package
    echo poetry add $unquoted_package
    echo git add --all
    echo git commit -m "Install $unquoted_package with poetry"
    echo git push
    echo git checkout main
done
