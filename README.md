# proxmox-cloudflare-ipset-updater
Awful bash script to update an ipset with Cloudflare IPs (IPv4)

I made this so I could only allow Cloudflare through port 443 on my containers through the proxmox firewall. Could have been done easier but this is good enough tbh

It uses an ipset called "cloudflarev4" in the datacenter level, so you may need to create that or change it in the code.

There's no error handling so it *could* break, but probably won't, especially since I have it on a cronjob for every week.
