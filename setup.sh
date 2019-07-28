#!/bin/bash

set -u

# check os
declare os=$(uname -s)
case "${os}" in
"Darwin")
    ;;
"Linux")
    if [[ -f /etc/redhat-release ]] ; then
        os="CentOS"
    else
        echo "not supported linux (yet)"
        exit 1
    fi
    ;;
*)
    echo "not supported os (yet)"
    exit 1 
    ;;
esac

# show usage
function usage() {
    cat <<EOF
usage:  ./setup.sh
description: setup dotfiles
option:
  -h : show this help
  -u : uninstall and erase files
EOF
    exit 0
}

# check and install package manager
function check_pkg_manager() {
    case "${os}" in
    "Darwin")
        command -v brew >/dev/null 2>&1
        if [[ $? = 1 ]] ; then
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
        ;;
    esac
}

# returns 0 if file should be written
function confirm_overwrite() {
    declare file=$1
    if [[ -f "${file}" ]] ; then
        read -r -p "${file} exists. overwrite? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort overwrite"; return 1 ;;
        esac
    fi
    return 0
}

# returns 0 if cmd should be uninstalled
function confirm_uninstall() {
    declare cmd=$1
    command -v ${cmd} >/dev/null 2>&1
    if [[ $? = 0 ]] ; then
        read -r -p "Do you uninstall ${cmd}? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort uninstall"; return 1 ;;
        esac
    fi
    return 1
}

#=============================== tmux ===============================
function setup_tmux() {
    echo "> setup tmux"
    command -v tmux >/dev/null 2>&1
    if [[ $? = 1 ]] ; then
        case "${os}" in
        "Darwin")
            brew install tmux
            ;;
        "CentOS")
            pushd $PWD
            yum install -y libevent-devel ncurses-devel
            cd /usr/local/src
            curl -o tmux-2.7.tar.gz https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz
            tar -xvf tmux-2.7.tar.gz
            cd tmux-2.7
            ./configure && make
            make install
            popd
            ;;
        esac
        tmux -V
    else
        echo "tmux installed"
    fi
    confirm_overwrite "${HOME}/.tmux.conf"
    if [[ $? = 0 ]] ; then
        cp ./tmux/.tmux.conf ${HOME}
    fi
}
function uninstall_tmux() {
    echo "> uninstall tmux"
    if [[ -f "${HOME}/.tmux.conf" ]] ; then
        rm ${HOME}/.tmux.conf
    fi
    confirm_uninstall "tmux"
    if [[ $? = 0 ]] ; then
        case "${os}" in
        "Darwin")
            brew uninstall tmux
            ;;
        "CentOS")
            yum remove -y libevent-devel ncurses-devel
            pushd $PWD
            cd /usr/local/src/tmux-2.7
            make uninstall
            popd
            ;;
        esac
    fi
}

#=============================== spectacle ===============================
function setup_spectacle() {
    echo "> setup spectacle"
    command -v spectacle >/dev/null 2>&1
    if [[ $? = 1 ]] ; then
        case "${os}" in
        "Darwin")
            brew install spectacle
            ;;
        *)
            echo "not supported"
            ;;
        esac
    else
        echo "spectacle installed"
    fi
}
function uninstall_spectacle() {
    echo "> uninstall spectacle"
    confirm_uninstall "spectacle"
    if [[ $? = 0 ]] ; then
        case "${os}" in
        "Darwin")
            brew uninstall spectacle
            ;;
        *)
            echo "nothing to do"
            ;;
        esac
    fi
}

function setup() {
    echo "setup"
    check_pkg_manager
    setup_tmux
    setup_spectacle
}

function uninstall() {
    echo "uninstall"
    uninstall_tmux
    uninstall_spectacle
}

# handle args
uninstall_flg="false"
while getopts hu OPT; do
    case $OPT in
    "h" ) usage ;;
    "u" ) uninstall_flg="true" ;;
    * ) usage ;;
    esac
done
shift $((OPTIND - 1))

if [[ "${uninstall_flg}" = "true" ]]; then
    uninstall
else
    setup
fi
