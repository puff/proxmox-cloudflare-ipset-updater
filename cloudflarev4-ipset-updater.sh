IPSET_NAME="cloudflarev4"
IPSET_URL="https://www.cloudflare.com/ips-v4"
VERBOSE=true

# Get old ipset data
old_ipset_arr=($(pvesh ls cluster/firewall/ipset/$IPSET_NAME | grep -Po '(?:\d{1,3}\.){3}\d{1,3}(?:\/\d{1,2})?'))
if $VERBOSE; then
	echo "[VERBOSE] Old ipset ($IPSET_NAME):"
	for ip in "${old_ipset_arr[@]}"
    do
        echo $ip
    done; echo
fi

# Get new ipset data
new_ipset_arr=($(curl -s $IPSET_URL))

if $VERBOSE; then
	echo "[VERBOSE] Fetched new ips ($IPSET_URL):"
	for ip in "${new_ipset_arr[@]}"
	do
		echo $ip
	done; echo
fi

# Compare old and new ips
removed_ips=()
new_ips=()

# Compare old ips against new ips to find removable ips
for old_ip in "${old_ipset_arr[@]}"
do
	not_found=true
	for new_ip in "${new_ipset_arr[@]}"
	do
		if [[ $old_ip == $new_ip ]]; then
			not_found=false
			break
		fi
	done
	if $not_found; then
		removed_ips+=($old_ip)
	fi
done

# Compare new ips against old ips to find new ips to add
for new_ip in "${new_ipset_arr[@]}"
do
    not_found=true
    for old_ip in "${old_ipset_arr[@]}"
    do
        if [[ $new_ip == $old_ip ]]; then
            not_found=false
            break
        fi
    done
    if $not_found; then
        new_ips+=($new_ip)
    fi
done

if $VERBOSE; then
    echo "[VERBOSE] New ips to add ($IPSET_NAME):"
    for ip in "${new_ips[@]}"
    do
        echo $ip
    done; echo

    echo "[VERBOSE] Old ips to remove ($IPSET_NAME):"
    for ip in "${removed_ips[@]}"
    do
        echo $ip
    done; echo
fi

# Remove old ip addresses
for ip in "${removed_ips[@]}"
do
	if $VERBOSE; then
		echo "[VERBOSE] Removing {$ip} from {$IPSET_NAME}"
	fi

	pvesh delete cluster/firewall/ipset/$IPSET_NAME/$ip
done

# Add new ip addresses
for ip in "${new_ips[@]}"
do
    if $VERBOSE; then
        echo "[VERBOSE] Adding {$ip} to {$IPSET_NAME}"
    fi

    pvesh create cluster/firewall/ipset/$IPSET_NAME --cidr $ip
done
