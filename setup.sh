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
usage:  ./setup.sh [option]
description: setup dotfiles
option:
  -h : show this help
  --tmux : setup tmux
  --zsh : setup zsh
EOF
    exit 0
}

# check and install package manager
function check_pkg_manager() {
    case "${os}" in
    "Darwin")
        if ! command -v brew >/dev/null 2>&1 ; then
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

# returns 0 if user want to install
function confirm_install() {
    declare cmd=$1
    # check command exists
    command -v "${cmd}" >/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
        echo "Do you install ${cmd}? [y/n]"
        read -r -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort install"; return 1 ;;
        esac
    fi
    echo "${cmd} exists"
    return 2 # already installed
}

declare TMUX_VERSION="2.7"
function setup_tmux() {
    echo "> setup tmux"
    # checking it's return value
    if confirm_install "tmux" ; then
        case "${os}" in
        "Darwin")
            brew install tmux
            ;;
        "CentOS")
            pushd "$PWD"
            yum install -y gcc make libevent-devel ncurses-devel
            cd /usr/local/src
            curl -o tmux-${TMUX_VERSION}.tar.gz -L https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
            tar -xvf tmux-${TMUX_VERSION}.tar.gz
            cd tmux-${TMUX_VERSION}
            ./configure && make
            make install > /dev/null
            popd
            ;;
        esac
        tmux -V
    fi

    if confirm_overwrite "${HOME}/.tmux.conf" ; then
        cp ./tmux/.tmux.conf "${HOME}"
    fi
}

function setup_zsh() {
    echo "> setup zsh and zplug"
    # checking it's return value
    if confirm_install "zsh" ; then
        case "${os}" in
        "Darwin")
            brew install zsh
            brew install zplug
            ;;
        "CentOS")
            yum install -y zsh
            curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
            ;;
        esac
        zsh --version
    fi

    touch "${HOME}/local.zsh"
    if confirm_overwrite "${HOME}/.zshrc" ; then
        cp ./zsh/.zshrc "${HOME}"
    fi
}

# handle args
while getopts -- "-:h" OPT; do
    case $OPT in
    -)
        case $OPTARG in
            tmux) setup_tmux ;;
            zsh) setup_zsh ;;
            *) usage ;;
        esac
        ;;
    h) usage ;;
    *) usage ;;
    esac
done
shift $((OPTIND - 1))

exit 0