# Create a function that downloads files from urls
function Get-ListFromUrl ($url) {
  Write-Host "Downloading hash list from $url..."
  try {
    $list = Invoke-WebRequest $url -UseBasicParsing -ContentType "text/plain; charset=utf-8" -OutVariable list
    Write-Host "     Removing lines that aren't hashes"
    $list = $list -split '\r?\n' | Where-Object { $_ -match '"sha256"' }
    Write-Host "     Splitting and joining the columns by newline"
    $list = $list -replace '"', '' -replace ':', '' -replace ',', '' -replace 'sha256', '' -replace ' ',''
    Write-Host "     Removing unneeded spaces"
    $list = $list | Where-Object { $_ -notmatch '^\s*$' }
	Write-Host "     Removing empty lines"
    $list = $list | ForEach-Object { if ($_ -ne "") { $_ } }
    Write-Host "     This list has $($list.Count) hashes on it"
    return $list
  }
  catch {
    Write-Host "Error downloading ${url}: $_. Skipping."
    return $null
  }
}
Write-Host "Splitting the hash into files with no more than 130,000 entries"

# Import the necessary modules.
Import-Module BitsTransfer

# Get the list of domains.
$domains = Get-ListFromUrl ('https://osint.digitalside.it/Threat-Intel/lists/latesthashes.txt') | Sort-Object -Unique

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
Out-File -FilePath "C:\IT_Tools\hashes\Fort-Hole_osint_hashfiles_$i.txt" -InputObject @"
#######################################################################
# The list contains file hashes collected in the latest 7 days by     #
# OSINT.digitalside.it                                                #
# The list is released without any warranty to the end users.         #
# INFO: info@digitalside.it                                           #
# Date: $(Get-Date -Format "yyyyMMdd-HH:MM")                          #
# Number of Hashes: $($domains.Count)                                 #
#######################################################################
# =========================================================================================
# This list has been modified from the original. It has been formatted for use with FortiOS.
# =========================================================================================
# Page $i of $([math]::Ceiling($numPages))

"@ -Encoding UTF8

    # Write the current page to a file.
    Out-File -FilePath "C:\IT_Tools\hashes\Fort-Hole_osint_hashfiles_$i.txt" -InputObject $pageDomains -Append -Encoding UTF8
	$i -= 1
}
Write-Host "Finished writing a total of $numPages pages."