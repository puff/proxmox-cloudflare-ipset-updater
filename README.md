# proxmox-cloudflare-ipset-updater
Simple bash script to update an ipset with Cloudflare IPs (IPv4)

I made this so I could only allow Cloudflare through port 443 on my containers through the proxmox firewall. Could have been done easier just using iptables/ipset but this is fancier :)

There's no error handling so it *could* break, but probably won't, especially since I have it on a cronjob for every week.
