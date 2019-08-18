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

# returns 0 if user want to install
function confirm_install() {
    declare cmd=$1
    # check command exists
    if ! command -v "${cmd}" >/dev/null 2>&1 ; then
        read -r -p "Do you install ${cmd}? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort install"; echo "${response}"; return 1 ;;
        esac
    fi
    echo "${cmd} exists"
    return 2 # already installed
}

# returns 0 if cmd should be uninstalled
function confirm_uninstall() {
    declare cmd=$1
    # check command exists
    if ! command -v "${cmd}" >/dev/null 2>&1 ; then
        read -r -p "Do you uninstall ${cmd}? [y/n]" -n 1 response
        echo ""
        case "${response}" in
            y|Y ) return 0 ;;
            *)  echo "abort uninstall"; return 1 ;;
        esac
    fi
    echo "${cmd} not exists"
    return 2 # not installed
}

#=============================== tmux ===============================
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
function uninstall_tmux() {
    echo "> uninstall tmux"
    if [[ -f "${HOME}/.tmux.conf" ]] ; then
        rm -i "${HOME}/.tmux.conf"
    fi

    if confirm_uninstall "tmux" ; then
        case "${os}" in
        "Darwin")
            brew uninstall tmux
            ;;
        "CentOS")
            pushd "$PWD"
            yum remove -y libevent-devel ncurses-devel
            cd /usr/local/src/tmux-${TMUX_VERSION}
            make uninstall
            popd
            ;;
        esac
    fi
    echo "uninstall tmux finished"
}

#=============================== zsh ===============================
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
function uninstall_zsh() {
    echo "> uninstall zsh"
    if [[ -f "${HOME}/.zshrc" ]] ; then
        rm -i "${HOME}/local.zsh"
        rm -i "${HOME}/.zshrc"
    fi

    if confirm_uninstall "zsh" ; then
        case "${os}" in
        "Darwin")
            brew uninstall zplug
            brew uninstall zsh
            ;;
        "CentOS")
            rm -r "${ZPLUG_HOME}"
            yum remove -y zsh
            ;;
        esac
    fi
    echo "uninstall zsh finished"
}

#=============================== spectacle ===============================
function setup_spectacle() {
    echo "> setup spectacle"
    case "${os}" in
    "Darwin")
        if confirm_install "spectacle" ; then
            brew cask install spectacle
        fi
        ;;
    *)
        echo "not supported"
        ;;
    esac
}
function uninstall_spectacle() {
    echo "> uninstall spectacle"
    case "${os}" in
        "Darwin")
            if confirm_uninstall "spectacle" ; then
                brew uninstall spectacle
            fi
            ;;
        *)
            echo "nothing to do"
            ;;
    esac
    echo "uninstall spactacle finished"
}

function setup() {
    echo "setup"
    check_pkg_manager
    setup_tmux
    setup_zsh
    setup_spectacle
}

function uninstall() {
    echo "uninstall"
    uninstall_tmux
    uninstall_zsh
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

exit 0