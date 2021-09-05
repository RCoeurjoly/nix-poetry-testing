check_uninstallable_packages () {
    for branch in $(git branch --no-color | grep -v "main")
    do
        git show --pretty="" --name-only $branch | grep -q uninstallable
        rc=$?
        if [[ $rc = 0 ]]; then
            echo $branch
        fi
    done
}

test_packages () {
    OPTIND=1         # Reset in case getopts has been used previously in the shell.

    # If no argument, parse big json
    if [ "$#" -eq 0 ]; then
        packages=$(cat packages.json | jq .rows[].project)
    fi

    while getopts ":f:p:h" o; do
        case "${o}" in
            f)
                packages=$(cat "$OPTARG" | jq .rows[].project)
                ;;
            p)
                packages="$OPTARG"
                ;;
            h)
                echo usage
                ;;
            *)
                echo fail
                ;;
        esac
    done

    shift $((OPTIND-1))

    for quoted_package in $packages
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
                add_package_to_uninstallable_list $unquoted_package
                git checkout main
                git merge $unquoted_package
                git branch -d $unquoted_package
            else
                git add --all
                git commit -m $unquoted_package
                git push
            fi
            git checkout main
        fi
    done
}

add_package_to_uninstallable_list() {
    uninstallable_package=$1
    echo $uninstallable_package >> uninstallable_packages
    echo git checkout -- poetry.lock
    echo git add uninstallable_packages
    echo git commit -m \"Uninstallable $uninstallable_package\"
}
