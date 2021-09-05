for quoted_package in $(cat packages.json | jq .rows[].project)
do
    unquoted_package=${quoted_package//\"}
    git rev-parse --quiet --verify $unquoted_package
    rc=$?
    if [[ $rc = 0 ]]; then
        echo Package $unquoted_package is already handled
    else
        git checkout -b $unquoted_package
        git push origin --delete $unquoted_package
        poetry add $unquoted_package
        rc=$?
        if [[ $rc != 0 ]]; then
            echo Package $unquoted_package failed to install with poetry
            echo $unquoted_package >> uninstallable_packages
            git add --all
            git commit -m \"Uninstallable $unquoted_package\"
            git checkout main
            git merge $unquoted_package
        else
            git add --all
            git commit -m $unquoted_package
            git push
        fi
        git checkout main
    fi
done
