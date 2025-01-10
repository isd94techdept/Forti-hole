# Start measuring the script execution time
$stopwatch = Measure-Command -Expression {
	# Define URLs for blocklists and allowlists
	$blocklistUrls = @(
		'https://dbl.oisd.nl/',
		'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
		'https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-YouTube-AdBlock.txt',
		'https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Spotify-AdBlock.txt',
		'https://blocklistproject.github.io/Lists/alt-version/ads-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/tracking-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/torrent-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/scam-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/redirect-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/piracy-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/fraud-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/tracking-nl.txt',
		'https://blocklistproject.github.io/Lists/alt-version/redirect-nl.txt',
		'https://quidsup.net/notrack/blocklist.php?download=trackersdomains'
	)
	
	$blocklistTags = @(
		'doubleclick-sites'
		'intellitxt-sites'
		'red-sheriff-sites'
		'cydoor-sites'
		'2o7-sites'
		'ad-sites'
		'canvass-fingerprinting-sites'
		'evercookies-sites'
		'yahoo-ad-sites'
		'hitbox-sites'
		'extreme-dm-sites'
		'realmedia-sites'
		'belo-interactive-sites'
		'ecard-scam-sites'
		'wiki-spam-sites'
		)

	$allowlistUrls = @(
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/banks.txt',
		'https://raw.githubusercontent.com/ookangzheng/blahdns/master/hosts/whitelist.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/issues.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/windows.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/mac.txt',
		'https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/optional-list.txt',
		'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/whitelist-referral.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/android.txt',
		'https://raw.githubusercontent.com/freekers/whitelist/master/domains/whitelist.txt',
		'https://raw.githubusercontent.com/notracking/hosts-blocklists-scripts/master/hostnames.whitelist.txt',
		'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/whitelist.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/firefox.txt',
		'https://raw.githubusercontent.com/AdguardTeam/HttpsExclusions/master/exclusions/sensitive.txt'
	)

	# Create a function that downloads files from urls and returns a HashSet of unique entries
	function Get-HashSetFromUrl ($url) {
	  Write-Host "Downloading list from $url..."
	  try {
		$list = Invoke-WebRequest $url -UseBasicParsing -OutVariable list -ContentType "text/plain; charset=utf-8"
		$list = $list.Content
		Write-Host "     Removing 0.0.0.0 or 127.0.0.1 from each line if present"
		$list = $list -replace "0\.0\.0\.0", "" -replace "127\.0\.0\.1", "" -replace '\|', ''
		Write-Host "     Filtering out comments and other lines we don't want"
		$list = $list -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#|^//.*' -and $_ -notin @('127.0.0.1 localhost','127.0.0.1 localhost.localdomain','127.0.0.1 local','255.255.255.255 broadcasthost','::1 localhost','::1 ip6-localhost','::1 ip6-loopback','fe80::1%lo0 localhost','ff00::0 ip6-localnet','ff00::0 ip6-mcastprefix','ff02::1 ip6-allnodes','ff02::2 ip6-allrouters','ff02::3 ip6-allhosts','0.0.0.0 0.0.0.0','::1		ip6-localhostip6-loopback','::1		localhost', '::1','ip6-localhostip6-loopback') } | ForEach-Object { ($_ -split '#')[0].Trim() }
		Write-Host "     Removing unneeded spaces"
		$list = $list -replace " ", "" -replace "	", "" -replace "	", "" -replace "::1", "" -replace "ip6-localhostip6-loopback" # Including the last 2 things because the script is being stupid
		Write-Host "     Converting list to an array"
		[string[]]$list = $list
		Write-Host "     Creating the hashset"
		$hashset = [System.Collections.Generic.HashSet[string]]::new($list)
		Write-Host "     This list has $($hashset.Count) unique domains on it"
		return $hashset
	  }
	  catch {
		Write-Host "Error downloading ${url}: $_. Skipping."
		return $null
	  }
	 }
	 
	 # Create a function that downloads a URL and searches between tags to only get certain data
	 function Get-HashSetFromUrlTag ($url, $startTag, $endTag) {
	  Write-Host "Downloading list from $url..."
	  try {
		$list = Invoke-WebRequest $url -UseBasicParsing -OutVariable list -ContentType "text/plain; charset=utf-8"
		$list = $list.Content
        Write-Host "Extracting content between <$startTag> and </$endTag> tags"
        $regex = "(?s)(?<=<$startTag>).+?(?=</$endTag>)"
        $list = [regex]::Matches($list, $regex) | ForEach-Object { $_.Value }
        Write-Host "     Removing 0.0.0.0 or 127.0.0.1 from each line if present"
		$list = $list -replace "0\.0\.0\.0", "" -replace "127\.0\.0\.1", "" -replace '\|', ''
		Write-Host "     Filtering out comments and other lines we don't want"
		$list = $list -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#|^//.*' -and $_ -notin @('127.0.0.1 localhost','127.0.0.1 localhost.localdomain','127.0.0.1 local','255.255.255.255 broadcasthost','::1 localhost','::1 ip6-localhost','::1 ip6-loopback','fe80::1%lo0 localhost','ff00::0 ip6-localnet','ff00::0 ip6-mcastprefix','ff02::1 ip6-allnodes','ff02::2 ip6-allrouters','ff02::3 ip6-allhosts','0.0.0.0 0.0.0.0','::1		ip6-localhostip6-loopback','::1		localhost', '::1','ip6-localhostip6-loopback') } | ForEach-Object { ($_ -split '#')[0].Trim() }
		Write-Host "     Removing unneeded spaces"
		$list = $list -replace " ", "" -replace "	", "" -replace "	", "" -replace "::1", "" -replace "ip6-localhostip6-loopback" # Including the last 2 things because the script is being stupid
		Write-Host "     Converting list to an array"
		[string[]]$list = $list
		Write-Host "     Creating the hashset"
		$hashset = [System.Collections.Generic.HashSet[string]]::new($list)
		Write-Host "     This list has $($hashset.Count) unique domains on it"
		return $hashset
	  }
	  catch {
		Write-Host "Error downloading ${url}: $_. Skipping."
		return $null
	  }
	 }
	 
	# Get starting blocklist
	Write-Host "Downloading initial blocklist"
	$list = Invoke-WebRequest 'https://hosts.ubuntu101.co.za/domains.list' -UseBasicParsing -OutVariable list -ContentType "text/plain; charset=utf-8"
		
	# Download and combine blocklists
	$blocklist = [System.Collections.Generic.HashSet[string]]::new($list -split '\r?\n')
	Write-Host "The starting blocklist has $($blocklist.Count) unique domains on it"
	
	# Download and combine blocklists
#	$blocklist = [System.Collections.Generic.HashSet[string]]::new()
	Write-Host "Downloading and merging blocklists..."
	$blocklistUrls | ForEach-Object {
		$hashset = Get-HashSetFromUrl $_
		If ($hashset -ne $null) {
			Write-Host "  Merging the hashsets"
			$blocklist.UnionWith([System.Collections.Generic.HashSet[string]]$hashset)
			}
		Write-Host "  The blocklist now as $($blocklist.Count) unique domains on it"
		}
	$blocklistTags | ForEach-Object {
		$tag = $_
		$hashset = Get-HashSetFromUrlTag -url 'https://someonewhocares.org/hosts/hosts' $tag $tag
		If ($hashset -ne $null) {
			Write-Host "  Merging the hashsets"
			$blocklist.UnionWith([System.Collections.Generic.HashSet[string]]$hashset)
			}
		Write-Host "  The blocklist now as $($blocklist.Count) unique domains on it"
		}
	Write-Host "Finished merging the blocklists"	
	Write-Host "The blocklist currently has $($blocklist.Count) unique domains on it."

	# Download and combine allowlists into a HashSet
	$allowlist = [System.Collections.Generic.HashSet[string]]::new()
	Write-Host "Downloading and marging allowlists..."
	$allowlistUrls | ForEach-Object {
		$hashset = Get-HashSetFromUrl $_ 
		If ($hashset -ne $null) {
			Write-Host "  Merging the hashsets"
			$allowlist.UnionWith([System.Collections.Generic.HashSet[string]]$hashset)
			}
		Write-Host "  The allowlist now as $($allowlist.Count) unique domains on it"
		}
	Write-Host "Finished merging the allowlists"
	Write-Host "The allowlist has $($allowlist.Count) unique domains on it."
	Write-Host "The blocklist has $($blocklist.Count) unique domains on it."
	
	# Remove entries from blocklist that are on allowlist
	Write-Host "Removing entries from blocklist that are on allowlist and malware list..."
	$filePath = Join-Path -Path $PSScriptRoot -ChildPath Forti-Hole_malware_raw.txt
	$malware = (Get-Content -Path $filePath -Raw) -split '\r?\n'
	$malware = [System.Collections.Generic.HashSet[string]]::new($malware)
	$blocklist.ExceptWith($allowlist)
	$blocklist.ExceptWith($malware)
	Write-Host "Done removing entries from blocklist."
	Write-Host "After processing, the blocklist now has $($blocklist.Count) unique domains on it."
	Write-Host "Splitting the blocklist in files with no more than 130,000 entries"
	
	# Import the necessary modules.
	Import-Module BitsTransfer

	# Get the list of domains.
	$domains = $blocklist | Sort-Object

	# Split the domains into pages of 150,000 entries each and export the pages to txt files.
	# Calculate the number of pages.
	$numPages = [math]::Ceiling($($domains.Count) / 130000)

	# Create an array to store the pages.
	$pages = @()

	Write-Host "Splitting the blocklist into $numPages pages"
	# Loop through the pages.
	for ($i = 0; $i -lt $numPages; $i++) {

		# Get the start and end index of the current page.
		$start = $i * 130000
		$end = ($i + 1) * 130000

		# Get the domains for the current page.
		$pageDomains = $domains[$start..$end]

		$i += 1
		Write-Host "Writing page $i of $numPages"
		# Write the header to the current page.
		Out-File -FilePath "Forti-Hole_adblock_$i.txt" -InputObject @"
# Title: Forti-Hole Adblock Blocklist
#
# This domain file is a merged collection of domains from reputable
# sources, and has been split into $numPages pages for use with FortiOS.
# To see a list of all the source lists, please go to the project GitHub.
#
# Date Last Compiled: $(Get-Date -Format "yyyyMMdd-HH:MM")
# Number of unique domains: $($domains.Count)
#
# ===============================================================
# Page $i of $([math]::Ceiling($numPages))

"@ -Encoding UTF8

		# Write the current page to a file.
		Out-File -FilePath "Forti-Hole_adblock_$i.txt" -InputObject $pageDomains -Append -Encoding UTF8
		$i -= 1
		}
		Write-Host "Finished writing a total of $numPages pages."
}
# Write the elapsed time to the screen or a log file
Write-Output "This script took $($stopwatch.Hours):$($stopwatch.Minutes):$($stopwatch.Seconds) to complete"