#!/usr/bin/env bash
# cat deploy.sh
main_remote=origin
backup_remote=backup
main_branch=master

function show_cmd(){
    echo -e "\\e[1m$*\\e[0m\\n"
    #$*
}

# alias git='show_cmd git'

function pause(){
   read -p "$*"
}

# remotes=$(git remote -v | grep "(push)" | awk '{print $1}'| xargs)
# branches=$(git branch | sed -E 's/^\*? *(^ )*/\1/'| xargs)
# current_branch=$(git branch | grep "^* "| sed -E "s/^\* //")

function push_branch(){
    branch=${current_branch}
    if [ "$1" != "" ]; then branch=$1; fi

    # Pull and push origin if in remotes list
    if [ $(expr index "${remotes}" ${main_remote}) != 0 ]; then 
        git pull --rebase ${main_remote} ${branch} || exit 1
        git push ${{main_remote}} ${branch} || exit 1
    fi

    # Push to backup remotes
    for remote in ${remotes}; do
        error=0
        if [ ${remote} != ${main_remote} ]; then 
            git push ${{remote}} ${branch} || exit 1
        fi
    done
}

function make_bubble(){
    message=$1
    git checkout ${main_branch} || exit 1
    git pull --rebase || exit 1
    echo 'Solve conflicts if any!'
    pause 'Press [Enter] key to continue...'
    git checkout ${current_branch} || exit 1
    git rebase ${main_branch} || exit 1
    echo 'Run tests!'
    pause 'Press [Enter] key to continue...'
    git checkout ${main_branch} || exit 1
    git merge --no-ff ${current_branch} -m "${message}" || exit 1
    git push ${main_remote} ${main_branch} || exit 1
}

function delete_commit(){
    show_cmd git reset --hard HEAD^ || exit 1
}

delete_commit