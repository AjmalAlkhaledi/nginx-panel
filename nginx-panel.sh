#!/bin/bash

nginx_config=$(nginx -V 2>&1)
nginx_conf_path=$(echo "$nginx_config" | grep -oP -- '--conf-path=\K\S+')

if [ -z "$nginx_conf_path" ]; then
    echo "Error: nginx configuration path not found"
    exit 1
fi

base_dir=$(dirname "$nginx_conf_path")
SITES_AVAILABLE="$base_dir/sites-available"
SITES_ENABLED="$base_dir/sites-enabled"

if [ ! -d "$SITES_AVAILABLE" ] || [ ! -d "$SITES_ENABLED" ]; then
    echo "Error: sites-available or sites-enabled directory not found in $base_dir"
    exit 1
fi

function test_nginx() {
    echo "Testing Nginx configuration..."
    if nginx -t; then
        echo "Nginx test passed √"
        return 0
    else
        echo "Nginx test failed !"
        return 1
    fi
}

function reload_nginx() {
    echo "Reloading Nginx..."
    systemctl reload nginx && echo "Reloaded successfully √"
}

function show_status() {
    echo "Status of Nginx sites:"
    echo
    sites=($(ls -1 "$SITES_AVAILABLE"))
    for site in "${sites[@]}"; do
        if [ -L "$SITES_ENABLED/$site" ]; then
            echo "  √: $site"
        else
            echo "  ×: $site"
        fi
    done
}

function list_sites() {
    ls -1 "$SITES_AVAILABLE"
}

function enable_site() {
    available_sites=($(ls -1 "$SITES_AVAILABLE"))
    unlinked_sites=()

    for site in "${available_sites[@]}"; do
        [ ! -e "$SITES_ENABLED/$site" ] && unlinked_sites+=("$site")
    done

    if [ ${#unlinked_sites[@]} -eq 0 ]; then
        echo "All sites are already enabled"
        exit 0
    fi

    if [[ "$1" == "--silent" ]]; then
        selected="${unlinked_sites[0]}"
        echo "Enabling: $selected"
    else
        echo "Select a site to enable:"
        for i in "${!unlinked_sites[@]}"; do
            echo "  [$i] ${unlinked_sites[$i]}"
        done
        echo "  [x] Exit"
        echo -n "Enter site number: "
        read choice
        
        if [[ "$choice" == "x" ]]; then echo "Exited"; exit 0; fi
        
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 0 ] || [ "$choice" -ge "${#unlinked_sites[@]}" ]; then
            echo "Invalid selection"
            exit 1
        fi
        selected="${unlinked_sites[$choice]}"
    fi

    ln -s "$SITES_AVAILABLE/$selected" "$SITES_ENABLED/$selected"
    test_nginx && reload_nginx || {
        echo "Rolling back: unlinking $selected"
        rm "$SITES_ENABLED/$selected"
        exit 1
    }
}

function disable_site() {
    enabled_sites=()
    for site in "$SITES_ENABLED"/*; do
        [ -L "$site" ] && enabled_sites+=("$(basename "$site")")
    done

    if [ ${#enabled_sites[@]} -eq 0 ]; then
        echo "No enabled sites found"
        exit 0
    fi

    echo "Select a site to disable:"
    for i in "${!enabled_sites[@]}"; do
        echo "  [$i] ${enabled_sites[$i]}"
    done
    echo "  [x] Exit"
    echo -n "Enter site number: "
    read choice
    
    if [[ "$choice" == "x" ]]; then echo "Exited"; exit 0; fi
    
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 0 ] || [ "$choice" -ge "${#enabled_sites[@]}" ]; then
        echo "Invalid selection"
        exit 1
    fi

    selected="${enabled_sites[$choice]}"
    rm "$SITES_ENABLED/$selected"
    test_nginx && reload_nginx || {
        echo "Rolling back: restoring $selected"
        ln -s "$SITES_AVAILABLE/$selected" "$SITES_ENABLED/$selected"
        exit 1
    }
}


case "$1" in
    --enable)
        enable_site "$2"
        ;;
    --disable)
        disable_site
        ;;
    --status)
        show_status
        ;;
    --list)
        list_sites
        ;;
    --reload)
        test_nginx && reload_nginx || exit 1
        ;;
    --test)
        test_nginx
        ;;
    *)
        echo "Usage:"
        echo "  $0 --enable [--silent]     Enable a site"
        echo "  $0 --disable               Disable a site"
        echo "  $0 --status                Show site status"
        echo "  $0 --list                  List available sites"
        echo "  $0 --reload                Reload Nginx after test"
        echo "  $0 --test                  Test Nginx configuration"
        ;;
esac
