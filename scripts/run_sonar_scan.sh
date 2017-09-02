#!/usr/bin/env bash

set -e

readonly SCRIPTSDIR="$(cd "$(dirname "${0}")"; echo "$(pwd)")"
readonly SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"

SONAR_LOGIN=$1
SONAR_SCANNER_CMD=$2


show_info() {
    local msg="$1"
    echo -e "\e[36m${1}\e[0m"
}

show_success() {
    local msg="$1"
    echo -e "\e[32m${msg}\e[0m"
}

show_warning() {
    local msg="$1"
    echo -e "\e[33mwarning\e[0m : ${1}"
}

show_error() {
    local msg="$1"
    echo -e "\e[31merror\e[0m : ${1}"
}


show_usage() {
    echo "Usage: bash $SCRIPTNAME <SONAR_LOGIN/API_KEY> [path/to/sonar-scanner]"
}

cd_project_root() {
    show_info '> cd to project root'
    pushd "${SCRIPTSDIR}" && pushd ..
    echo
}

restore_previous_working_dir() {
    show_info '> Restore previous working directory'
    popd && popd
    echo
}

run_scan() {
    show_info '> Run sonar scanner analysis'
    "${SONAR_SCANNER_CMD}" -Dsonar.login="${SONAR_LOGIN}"
    echo
}


cd_project_root

#
# if no args passed... try to suck in .env file:
if [ $# -eq 0 ]; then
    if [ -r .env ] && [ -f .env ]; then
        source .env
    else
        show_usage
        exit 1
    fi
fi

#
# Set sonar scan params:
if [ -z "$SONAR_LOGIN" ]; then
    show_error "ERROR: Missing positional arg(1) for 'SONAR_LOGIN/API_KEY'"
    show_usage
    exit 1
fi
if [ -z "$SONAR_SCANNER_CMD" ]; then
    SONAR_SCANNER_CMD=sonar-scanner
fi

run_scan
restore_previous_working_dir
show_success 'Finished.'