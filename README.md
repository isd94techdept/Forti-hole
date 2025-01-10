# Forti-hole
Scripts to create domain and IP blocklists as well as malware has feeds for Fortigate firewalls. Inspired by Pi-hole

I spent a fair amount of time scouring the internet looking for free domain blocklists, IP blocklists, and malware hashes that I can use to help fortify my fortigate. I found several active projects (a lot of them for Pihole) that had what I needed, but I was presented with 2 problems: 1. Not all of these were formatted in a way the fortigate could read and 2. There were going to be a lot of duplicate entries.

Enter “Forti-hole”, which is a powershell script that downloads threat feeds, strips out unneeded formatting, converts each entry into a hash set which automatically eliminates duplicate entries, then merges all of the lists to one giant list, removes anything listed in any allow lists presented, then splits it into pages of 130,000 each since the fortigate can’t support longer lists.

### Lists that work with fortigate without any modifications:
#### IP Address Threat Feeds:
Binary Defense Systems Banlist Feed
https://www.binarydefense.com/banlist.txt

Blocklist Project Malware IPs
https://raw.githubusercontent.com/blocklistproject/Lists/master/malware.ip

CINS Army List Badguy List
https://cinsscore.com/list/ci-badguys.txt

Cybercrime Tracker IPs
https://iplists.firehol.org/files/cybercrime.ipset

Emerging Threats Compromised Hosts
https://rules.emergingthreats.net/blockrules/compromised-ips.txt

FireHOL Level 1 IP Blocklist
https://iplists.firehol.org/files/firehol_level1.netset

FireHOL Level 2 IP Blocklist
https://iplists.firehol.org/files/firehol_level2.netset

FireHOL Level 3 IP Blocklist
https://iplists.firehol.org/files/firehol_level3.netset

Free SSL Proxies 30 Days
https://iplists.firehol.org/files/sslproxies_30d.ipset

Free Proxies 30 Days
https://iplists.firehol.org/files/socks_proxy_30d.ipset

Malware-Filter Phishing
https://malware-filter.gitlab.io/malware-filter/phishing-filter-dnscrypt-blocked-ips.txt

Malware-Filter Botnets
https://malware-filter.gitlab.io/malware-filter/botnet-filter.txt

Malware-Filter URLHaus
https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-dnscrypt-blocked-ips.txt

OSINT - Malware IPs
https://osint.digitalside.it/Threat-Intel/lists/latestips.txt

SPAMHaus Drop List
https://raw.githubusercontent.com/SecOps-Institute/SpamhausIPLists/master/drop.txt

SPAMHaus EDrop List
https://raw.githubusercontent.com/SecOps-Institute/SpamhausIPLists/master/edrop.txt

TOR IP List
https://dan.me.uk/torlist/

Talos Intelligence IP Blocklist
https://talosintelligence.com/documents/ip-blacklist

abuse.ch Feodo Tracker IP Blocklist
https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.txt

#### Domain Threat Feeds:
Blocklist Project Ransomware
https://blocklistproject.github.io/Lists/alt-version/ransomware-nl.txt

Blocklist Project Tracking
https://blocklistproject.github.io/Lists/alt-version/tracking-nl.txt

#### Malware Hash Feeds
NONE! They all need to be modified to work with Fortigate.

### Forti-Hole Included Lists and Scripts

#### Forti-Hole Domain Blocklist Included Feeds: (Really bad stuff only)
https://hosts.ubuntu101.co.za/domains.list

https://dbl.oisd.nl/		

https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

https://lists.malwarepatrol.net/ (Requires registration)

https://cti-lists.cisecurity.org/lists/domains.txt

https://someonewhocares.org/hosts/hosts



#### Forti-Hole Domain Adblock List included feeds: (use only if you really want to block ads)

https://hosts.ubuntu101.co.za/domains.list

https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts		

https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-YouTube-AdBlock.txt

https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Spotify-AdBlock.txt

https://blocklistproject.github.io/Lists/alt-version/ads-nl.txt

https://blocklistproject.github.io/Lists/alt-version/tracking-nl.txt

https://blocklistproject.github.io/Lists/alt-version/torrent-nl.txt

https://blocklistproject.github.io/Lists/alt-version/scam-nl.txt

https://blocklistproject.github.io/Lists/alt-version/redirect-nl.txt

https://blocklistproject.github.io/Lists/alt-version/piracy-nl.txt

https://blocklistproject.github.io/Lists/alt-version/fraud-nl.txt

https://blocklistproject.github.io/Lists/alt-version/tracking-nl.txt

https://blocklistproject.github.io/Lists/alt-version/redirect-nl.txt

https://quidsup.net/notrack/blocklist.php?download=trackersdomains

https://someonewhocares.org/hosts/hosts



#### Forti-Hole Domain Malware included feeds: (More strict that the blocklist, but not overly so. I use this in production)

https://hosts.ubuntu101.co.za/domains.list

https://blocklistproject.github.io/Lists/alt-version/malware-nl.txt

https://blocklistproject.github.io/Lists/alt-version/phishing-nl.txt

https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADomains.txt

https://blocklistproject.github.io/Lists/alt-version/ransomware-nl.txt

https://malware-filter.gitlab.io/malware-filter/phishing-filter-hosts.txt

https://malware-filter.gitlab.io/malware-filter/urlhaus-filter-hosts.txt

https://malware-filter.gitlab.io/malware-filter/pup-filter-hosts.txt

https://malware-filter.gitlab.io/malware-filter/botnet-filter.txt

https://raw.githubusercontent.com/Th3M3/blocklists/master/malware.list

https://quidsup.net/notrack/blocklist.php?download=malwaredomains

https://lists.malwarepatrol.net/ (requires registration)

https://cti-lists.cisecurity.org/lists/domains.txt

https://someonewhocares.org/hosts/hosts


#### Forti-Hole IP Blocklists included feeds:

https://reputation.alienvault.com/reputation.generic

https://hosts.ubuntu101.co.za/hosts.deny



#### Forti-Hole Malware Hash included feeds:
https://bazaar.abuse.ch/export/txt/sha256/full/

https://osint.digitalside.it/Threat-Intel/lists/latesthashes.txt

https://virusshare.com/hashfiles/unpacked_hashes.md5

Each script creates a feed (or several feeds since fortigate can only support 130000 items per feed). So to have the feeds created/updated regularly, you just need to create a scheduled task to run the powershell scripts. Make sure you modify the script to save the feed in a place you want them to save. You're going to need an internal web server to host these feeds so you can get them into the fortigate. I have the scheduled task running on my web server and it saves them right in the folder that is accessible on the web server. Then I just go into Fortigate, go to Security Fabric, then External Connectors. Create a new external feed and select IP or domain and then put in the URL of the feed you created.
