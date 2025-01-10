# Create a function that downloads files from urls
function Get-ListFromUrl ($url) {
	  Write-Host "Downloading list from $url..."
	  try {
		$list = Invoke-WebRequest $url -UseBasicParsing -OutVariable list -ContentType "text/plain; charset=utf-8"
		Write-Host "     Removing ALL:"
		$list = $list -replace "ALL:", "" -replace "1\.1\.1\.1"
		Write-Host "     Filtering out comments and other lines we don't want"
		$list = $list -split '\r?\n' | Where-Object { $_ -match '\S' -and $_ -notmatch '^\s*#|^//.*' } | ForEach-Object { ($_ -split '#')[0].Trim() }
		Write-Host "     Removing unneeded spaces"
		$list = $list -replace " ", "" -replace "	", "" -replace "	", ""
		Write-Host "     This list has $($list.Count) unique IP addresses on it"
		return $list
		}
	  catch {
		Write-Host "Error downloading ${url}: $_. Skipping."
		return $null
	  }
	 }
Write-Host "Splitting the blocklist into files with no more than 130,000 entries"

# Import the necessary modules.
Import-Module BitsTransfer

# Get the list of domains.
$domains = Get-ListFromUrl ('https://hosts.ubuntu101.co.za/hosts.deny') | Sort-Object -Unique

# Get the number of domains in the list.
$numDomains = $domains.Count

# Calculate the number of pages.
$numPages = [math]::Ceiling($numDomains / 130000)

# Create an array to store the pages.
$pages = @()

Write-Host "Splitting the file into $numPages pages"
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
Out-File -FilePath "C:\IT_Tools\dns\Fort-Hole_ultimatehosts_blacklist_ips_$i.txt" -InputObject @"
### The Ultimate IP blacklist for FortiOS
### Copyright (c) 2017, 2018, 2019, 2020, 2021, 2022 Ultimate Hosts Blacklist - @Ultimate-Hosts-Blacklist
### Copyright (c) 2017, 2018, 2019, 2020, 2021, 2022 Mitchell Krog - @mitchellkrogza
### Copyright (c) 2017, 2018, 2019, 2020, 2021, 2022 Nissar Chababy - @funilrys
### Repo Url: https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist

##############################################################################################################################
#                                                                                                                            #
#  ##     ## ##       ######## #### ##     ##    ###    ######## ########    ##     ##  #######   ######  ########  ######   #
#  ##     ## ##          ##     ##  ###   ###   ## ##      ##    ##          ##     ## ##     ## ##    ##    ##    ##    ##  #
#  ##     ## ##          ##     ##  #### ####  ##   ##     ##    ##          ##     ## ##     ## ##          ##    ##        #
#  ##     ## ##          ##     ##  ## ### ## ##     ##    ##    ######      ######### ##     ##  ######     ##     ######   #
#  ##     ## ##          ##     ##  ##     ## #########    ##    ##          ##     ## ##     ##       ##    ##          ##  #
#  ##     ## ##          ##     ##  ##     ## ##     ##    ##    ##          ##     ## ##     ## ##    ##    ##    ##    ##  #
#   #######  ########    ##    #### ##     ## ##     ##    ##    ########    ##     ##  #######   ######     ##     ######   #
#                                                                                                                            #
#  ########  ##          ###     ######  ##    ## ##       ####  ######  ########                                            #
#  ##     ## ##         ## ##   ##    ## ##   ##  ##        ##  ##    ##    ##                                               #
#  ##     ## ##        ##   ##  ##       ##  ##   ##        ##  ##          ##                                               #
#  ########  ##       ##     ## ##       #####    ##        ##   ######     ##                                               #
#  ##     ## ##       ######### ##       ##  ##   ##        ##        ##    ##                                               #
#  ##     ## ##       ##     ## ##    ## ##   ##  ##        ##  ##    ##    ##                                               #
#  ########  ######## ##     ##  ######  ##    ## ######## ####  ######     ##                                               #
#                                                                                                                            #
##############################################################################################################################

### MIT LICENSE

### You are free to copy and distribute this file for non-commercial uses,
### as long the original URL and attribution is included.

### Please forward any additions, corrections or comments by logging an issue at
### https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/issues

##### Version Information #
#### Version: This has been formatted for use in FortiOS
#### Updated: $(Get-Date -Format "yyyyMMddHHmm")
#### Total IP's: $numDomains
##### Version Information ##
# =========================================================================================
# This list has been modified from the original. It has been formatted for use with FortiOS.
# =========================================================================================
# Page $i of $([math]::Ceiling($numPages))

"@ -Encoding UTF8

    # Write the current page to a file.
    Out-File -FilePath "C:\IT_Tools\dns\Fort-Hole_ultimatehosts_blacklist_ips_$i.txt" -InputObject $pageDomains -Append -Encoding UTF8
	$i -= 1
}
Write-Host "Finished writing a total of $numPages pages."