#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly _CISCO_VPN="/opt/cisco/anyconnect/bin/vpn"
readonly _GREEN='\033[0;32m'
readonly _RED='\033[0;31m'
readonly _NC='\033[0m'

vpn_up() {
    local VPN_PROFILE="$1"
    local VPN_USERNAME="$2"
    local VPN_PASSWORD="$3"

    "$_CISCO_VPN" -s connect "$VPN_PROFILE" <<EOF
1
$VPN_USERNAME
$VPN_PASSWORD
y
exit
EOF
}

vpn_down() {
    "$_CISCO_VPN" disconnect
}

vpn_verify() {
    local VPN_PROFILE="$1"
    local VPN_USERNAME="$2"

    local RESULT=0

    echo -n "Checking profile $VPN_PROFILE exists..."
    if [[ ! -f "/opt/cisco/anyconnect/profile/$VPN_PROFILE.xml" ]]; then
        echo -e "${_RED}FAILED${_NC}"
        echo "Profile $VPN_PROFILE was not found - please connect once via '$_CISCO_VPN -s connect vpn.springernature.com' to download this"
        RESULT=1
    else 
        echo -e "${_GREEN}OK${_NC}"
    fi

    return $RESULT
}

verify_prerequisites() {
    if [[ ! -f "$_CISCO_VPN" ]]; then
        echo "Cannot find AnyConnect at $_CISCO_VPN - please ensure you've installed it."
        echo "You can download binaries from https://anyconnect.springernature.com"
        return 1
    fi
}

verify_user_pass() {
    local VPN_USERNAME="${1:-}"
    local VPN_PASSWORD="${2:-}"

    if [[ -z "$VPN_USERNAME" || -z "$VPN_PASSWORD" ]]; then
        echo "Error: you must provide VPN username/password as arguments!"
        exit 1
    fi
}

main() {
    local ACTION="${1:-}"

    verify_prerequisites

    local VPN_USERNAME="${2:-}"
    local VPN_PASSWORD="${3:-}"

    local VPN_PROFILE="SpringerNature-Int"

    case "$ACTION" in
    up)
        verify_user_pass "$VPN_USERNAME" "$VPN_PASSWORD"
        vpn_up "$VPN_PROFILE" "$VPN_USERNAME" "$VPN_PASSWORD"
        ;;
    down)
        vpn_down
        ;;
    verify)
        verify_user_pass "$VPN_USERNAME" "$VPN_PASSWORD"
        vpn_verify "$VPN_PROFILE" "$VPN_USERNAME"
        ;;
    *)
        echo "Usage: $0 <up|down|verify>"
        exit 1
        ;;
    esac
}

main "$@"
