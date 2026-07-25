Add-Type -AssemblyName System.Drawing
$col = New-Object System.Drawing.Text.InstalledFontCollection
$fam = $col.Families | Where-Object { $_.Name -eq "JetBrainsMono NF" }

"Regular   : $($fam.IsStyleAvailable('Regular'))"
"Bold      : $($fam.IsStyleAvailable('Bold'))"
"Italic    : $($fam.IsStyleAvailable('Italic'))"
"BoldItalic: $($fam.IsStyleAvailable('Bold, Italic'))"