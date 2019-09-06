#!/usr/bin/env bash

read -p "Do you want to connect to that screen? [y/N]:" OPT
case ${OPT} in
    y|Y)
        echo "Be careful! Remember to disconnect with Ctrl+A+D from screen ;-)"
        read -p "Press any key to continue..."
        ssh -t ${remote_server} screen -x "${image_name}"
    ;;
    n|N)
    ;;
    *)
    ;;
esac

exit 0
answered=false
while ! ${answered}; do
    answered=true
    read -p "Do you want to connect to that screen?[y/N]" OPT
    case $OPT in
        y|Y)
            echo Yes
        ;;
        n|N)
            echo No
        ;;
        *)  answered=false
            goto again
        ;;
    esac
done