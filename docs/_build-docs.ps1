<#
    .SYNOPSIS
        Builds the HTML documentation from markdown files using pandoc.

    .DESCRIPTION
        This script converts all markdown files in the ../sections directory
        and the root README.md into a static HTML website in the current directory.
        It requires pandoc to be installed and available in the system's PATH.

    .NOTES
        Author: Shivam Kumar
        Date:   July 10, 2026
#>

# --- Configuration ---
$ScriptPath = $PSScriptRoot
$MainTitle = "3D Game Shaders For Beginners"
$RepoURL = "https://github.com/ShivamKR12/3d-game-shaders-for-beginners"
$Author = "Shivam Kumar"
$CSS = "style.css"

# --- Build Sections ---
$sectionFiles = Get-ChildItem -Path "$ScriptPath/../sections/*.md"

foreach ($f in $sectionFiles) {
    Write-Host "Processing $($f.FullName)"
    $fileName = $f.BaseName
    $title = ($fileName -replace '-', ' ') | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }

    if ($title -eq "Ssao") { $title = "SSAO" }
    if ($title -eq "Glsl") { $title = "GLSL" }

    $outputFile = "$ScriptPath/$fileName.html"

    pandoc -f gfm -t html5 --highlight-style=breezedark --template="$ScriptPath/_template.html5" $f.FullName --metadata pagetitle="$title | $MainTitle" --metadata author-meta="$Author" --metadata css=$CSS -o $outputFile
}

# --- Build Index ---
Write-Host "Processing README.md"
$readmePath = "$ScriptPath/../README.md"
$indexPath = "$ScriptPath/index.html"
pandoc -f gfm -t html5 --highlight-style=breezedark --template="$ScriptPath/_template.html5" $readmePath --metadata pagetitle="$MainTitle" --metadata author-meta="$Author" --metadata css=$CSS -o $indexPath

# --- Fix Links ---
$htmlFiles = Get-ChildItem -Path "$ScriptPath/*.html"

foreach ($f in $htmlFiles) {
    Write-Host "Fixing links in $($f.Name)"
    $content = Get-Content $f.FullName -Raw

    # Replace .md links with .html
    $content = $content -replace 'href="(?:sections/)?([a-z-]+)\.md(.*)"', 'href="$1.html$2"'

    # Replace README.md link with index.html
    $content = $content -replace 'href="\.\./README.md"', 'href="index.html"'

    # Replace relative demonstration links with absolute GitHub links
    $content = $content -replace '<a href="\.\./demonstration/(.*?)">', ('<a href="' + $RepoURL + '/blob/master/demonstration/$1" target="_blank" rel="noopener noreferrer">')

    Set-Content -Path $f.FullName -Value $content
}

Write-Host "Build complete!"
