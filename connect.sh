#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly _VPNCONFIG="/vagrant/vpnconfig"
readonly _CISCO_VPN="/opt/cisco/anyconnect/bin/vpn"
readonly _GREEN='\033[0;32m'
readonly _RED='\033[0;31m'
readonly _NC='\033[0m'

vpn_up() {
    local VPN_PROFILE="$1"
    local VPN_USERNAME="$2"
    local VPN_PASSWORD="$3"

    "$_CISCO_VPN" -s connect "$VPN_PROFILE" <<EOF
2
$VPN_USERNAME
$VPN_PASSWORD
y
exit
EOF
}

vpn_down() {
    "$_CISCO_VPN" disconnect
}

verify_prerequisites() {
    if [[ ! -f "$_CISCO_VPN" ]]; then
        echo "Cannot find AnyConnect at $_CISCO_VPN – please ensure you've installed it."
        return 1
    fi

    if [[ ! -f "$_VPNCONFIG" ]]; then
        echo "Cannot find VPN configuration at $_VPNCONFIG (host OS: $(basename $_VPNCONFIG)) – please ensure you've created it according to the documentation."
        return 1
    fi
}

verify_user_pass() {
    local VPN_PROFILE="${1:-}"
    local VPN_USERNAME="${2:-}"
    local VPN_PASSWORD="${3:-}"

    if [[ -z "$VPN_PROFILE" || -z "$VPN_USERNAME" || -z "$VPN_PASSWORD" ]]; then
        echo "Error: you must provide VPN hostname, username and password as arguments!"
        exit 1
    fi
}

main() {
    local ACTION="${1:-}"

    verify_prerequisites

    local VPN_PROFILE
    VPN_PROFILE=$(sed -n '1p' /vagrant/vpnconfig)
    local VPN_USERNAME
    VPN_USERNAME=$(sed -n '2p' /vagrant/vpnconfig)
    local VPN_PASSWORD
    VPN_PASSWORD=$(sed -n '3p' /vagrant/vpnconfig)

    case "$ACTION" in
    up)
        verify_user_pass "$VPN_PROFILE" "$VPN_USERNAME" "$VPN_PASSWORD"
        vpn_up "$VPN_PROFILE" "$VPN_USERNAME" "$VPN_PASSWORD"
        ;;
    down)
        vpn_down
        ;;
    *)
        echo "Usage: $0 <up|down|verify>"
        exit 1
        ;;
    esac
}

main "$@"
