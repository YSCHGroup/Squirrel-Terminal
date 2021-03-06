# Setup Functions and Localvariables
    #Get homepath from SquirrelTerminal.bin in Temp
$HomePath = Get-Content "C:\Temp\SquirrelTerminal.bin"

    #Setup Terminal Theme
$host.UI.RawUI.WindowTitle = "Squirrel Terminal"
$Host.UI.RawUI.BackgroundColor = "black"
$Host.UI.RawUI.ForegroundColor = "white"
$HostFColor = $Host.UI.RawUI.ForegroundColor
$ForceColor = "true"


# Go to the path squirrel terminal was opened in
$StartDir = Get-Content "C:\Temp\SquirrelTerminal.bin"
cd $StartDir

    #Add custom Modules path
$env:PSModulePath = "$env:PSModulePath;P\WINAPPS\Data\bin\modules\powershell;P\WINAPPS\Data\bin\modules\powershell\"
    #Assign new local variables
$ipaddress = Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address

    #Setup New Command Functions
function ipaddress { Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address }
function sqt-help { squirrel-help; }
function squirrel-help {write-host '--- Squirrel-Help -------------------------------------------------

    - Cmdlets
    
squirrel-help      List all available commands.
ip-help            Show the usage of ip commands and variables.
restart            restart the Terminal
background-color   Change the background color of the terminal.
foreground-color   Change the foreground color of the terminal.
output-color       Change the output color of cmdlets.
cd                 Change Current directory.
colors             List of all usable colors.
run                Read a squirrelterminalfile (.sqt) into the terminal.
view-sqif          Opens and displays a powershell image coded file.
draw-sqif          Create a new sqif file.
nut / nuts         "Easter egg"
$ForceColor        = "true" will set the executed commands Yellow. = "false" will set it to your foreground-color
dir-names          Shows only the filenames (+extention) in the current directory
Test-IsAdmin       Returns True if prompt is running with administrator rights.


    - Additions to external programs
(Thees commands will be executable from example a command prompt or powershell window.)

squirrel terminal  Starts a new Squirrel Terminal prompt window.
squirrelterminal   Starts a new Squirrel Terminal prompt window.
squirrel           Starts a new Squirrel Terminal prompt window.
sqt                Starts a new Squirrel Terminal prompt window.

'}

    #Create a function and test if the current user is admin...
function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}
#run it
$isAdmin = Test-IsAdmin

function run {
    # We are using the file path '$readFilePath' that's set before this is runned.
    if ($ForceColor -eq "true") { $outputColor = "Yellow" } else { $outputColor = $Host.UI.RawUI.ForegroundColor }
    foreach ($line in $readFilePath) {
        Get-Content $readFilePath | Foreach-Object {
            iex $_
            # This creates a problem with brackets and empty lines
        }
    }
}

function dir-names {
     write-host "Files in: $pwd `n"
     dir -name
}
function ip-help {
    write-host '--- IP Help ---

Ipaddress:
xxx.xxx.xxx.xxx

$ipaddress:
xxx.xxx.xxx.xxx

write-host $ipaddress:
@{IPV4Address=xxx.xxx.xxx.xxx}

---------------'   
}

function color {
    write-Host "Use: `n foreground-color = text color. `nor`n background-color = background color."; 
}
function colors {
    Write-Host "--- Colors ---"; Write-Host "(0) black"; Write-Host "(1) darkBlue"; Write-Host "(2) darkGreen"; Write-Host "(3) darkCyan"; Write-Host "(4) darkRed"; Write-Host "(5) darkMagenta"; Write-Host "(6) darkYellow"; Write-Host "(7) gray"; Write-Host "(8) darkGray"; Write-Host "(9) blue"; Write-Host "(10) green"; Write-Host "(11) cyan"; Write-Host "(12) red"; Write-Host "(13) magenta"; Write-Host "(14) yellow"; Write-Host "(15) white"; Write-Host "(-1) blank (only in sqifs)"; Write-Host "--------------";
}
function ForceColor {
    $Host.UI.RawUI.ForegroundColor = $outputColor
}
function ResetColor {
    $Host.UI.RawUI.ForegroundColor = $HostFColor
}
function foreground-color($fgcolor) {
    $Host.UI.RawUI.ForegroundColor = $fgcolor
    $HostFColor = $fgcolor
}
function output-color($opcolor) {
    $ForceColor = "false";
    $outputColor = $opcolor
}
function view-sqif {
    $readloop = 0
    $i = 0
    # We are using the file path '$readFilePath' that's set before this is runned.
    Get-Content $readFilePath | Foreach-Object {
                # The line code at each line is stored in "$_"
        if ($_ -eq "ImageInfo(") {
            # start info loop
            $readloop = 1
        }
        if ($_ -eq "ImageData(") {
            # start data loop
            $readloop = 2
        }
        
        
        if ($readloop -eq 1) {
            # Read all the nessesary info
            if ($_.ToLower().StartsWith("	title:") -eq "true") {
                $imageTitle = $_.TrimStart("	Title:")
                $imageTitle = $imageTitle.Trim()
                $imageTitle = $imageTitle.TrimStart('"')
                $imageTitle = $imageTitle.TrimEnd('"')
            }
            if ($_.ToLower().StartsWith("	description:") -eq "true") {
                $imageDescription = $_.TrimStart("	Description:")
                $imageDescription = $imageDescription.Trim()
                $imageDescription = $imageDescription.TrimStart('"')
                $imageDescription = $imageDescription.TrimEnd('"')
            }
            if ($_.ToLower().StartsWith("	sizex:") -eq "true") {
                $imageSizeX = $_.TrimStart("	SizeX:")
                $imageSizeX = $imageSizeX.Trim()
            }
            if ($_.ToLower().StartsWith("	sizey:") -eq "true") {
                $imageSizeY = $_.TrimStart("	SizeY:")
                $imageSizeY = $imageSizeY.Trim()
            }
            if ($_ -eq ")") {
                # exit loop and print data
                $readloop = 0
                if ($sqifNull -eq "False") {
                Write-Host "------- Info -------"
                write-host "File: " -f white -NoNewline; write-host $readFilePath -f yellow;
                if ($imageTitle) { write-host "Title: " -f white -NoNewline; write-host $imageTitle -f yellow; }
                if ($imageDescription) { write-host "Description: " -f white -NoNewline; write-host $imageDescription -f yellow; }
                write-host "Width: " -f white -NoNewline; write-host $imageSizeX -f yellow -NoNewline; write-host "x" -f white;
                write-host "Height: " -f white -NoNewline; write-host $imageSizeY -f yellow -NoNewline; write-host "y" -f white;
                $imageRatio = $imageSizeY/$imageSizeX
                write-host "Ratio: " -f white -NoNewline; write-host $imageRatio -f yellow;
                Write-Host "--------------------"
                }
            }
        }
        if ($readloop -eq 2) {
            # Read all image data
            $_ = $_.Trim();
            if ($_.StartsWith("(")) {
                # write-host $_
                $array = $_.Trim()
                $array = $array.Trim("(")
                $array = $array.Trim(")")
                $array = $array  -split ","
                # write-host $array
                while ($i -lt $imageSizeX) {
                    # Color determanding
                    switch ($array[$i]) {
                        "-1" {$DrawColor = "blank";}
                        "0" {$DrawColor = "black";}
                        "1" {$DrawColor = "darkblue";}
                        "2" {$DrawColor = "darkGreen";}
                        "3" {$DrawColor = "darkCyan";}
                        "4" {$DrawColor = "darkRed";}
                        "5" {$DrawColor = "darkMagenta";}
                        "6" {$DrawColor = "darkYellow";}
                        "7" {$DrawColor = "gray";}
                        "8" {$DrawColor = "darkGray";}
                        "9" {$DrawColor = "blue";}
                        "10" {$DrawColor = "green";}
                        "11" {$DrawColor = "cyan";}
                        "12" {$DrawColor = "red";}
                        "13" {$DrawColor = "magenta";}
                        "14" {$DrawColor = "yellow";}
                        "15" {$DrawColor = "white";}
                    }
                    if ($DrawColor -eq "blank") {
                        write-host "  " -NoNewline;
                    }else{
                        write-host "██" -f $DrawColor -NoNewline;
                    }
                    $i ++;
                }
                $i = 0;
                write-host "";
            }
                
            
            
            if ($_ -eq ")") {
                # exit loop and print data
                $readloop = 0
            }
        }
        if ($_ -eq ")") {
            # exit every again loop (in case)
            $readloop = 0
        }
    }
}
function draw-sqif {
    write-host "Create New .sqif-file:"
}

function restart {
    & "$HomePath\terminal_shell.ps1"
    exit
}
function hackermode {
    while ($True) { 
        foreground-color green
        background-color black
        
    }
}

# Import Modules
Import-Module -Name modules\Convert-DecimalToFraction.ps1










# Draw GUI
$DrawGUI = {
    cls
    write-Host ""
    Write-Host "     ╔══════════╗     ██" -f red -nonewline; Write-Host "     ██" -f red;
    Write-Host "     ║ Squirrel ║    ███" -f red -nonewline; Write-Host "████████" -f red -nonewline; Write-Host "  ████" -f darkred;
    Write-Host "     ║ Terminal ║    ██" -f red -nonewline; Write-Host "█" -f black -nonewline; Write-Host "███" -f red -nonewline; Write-Host "█" -f black -nonewline; Write-Host "████" -f red -nonewline; Write-Host " ██████" -f darkred;
    Write-Host "     ╚══════════╝■   ███" -f red -nonewline; Write-Host "█" -f Yellow -nonewline; Write-Host "█" -f darkred -nonewline; Write-Host "█" -f Yellow -nonewline; Write-Host "█████" -f red -nonewline; Write-Host "████████" -f darkred;
    Write-Host "                   ■ ███" -f red -nonewline; Write-Host "█" -f darkred -nonewline; Write-Host "█" -f Yellow -nonewline; Write-Host "█" -f darkred -nonewline; Write-Host "█████" -f red -nonewline; Write-Host "███████ " -f darkred;
    Write-Host "                      ██" -f red -nonewline; Write-Host "███" -f Yellow -nonewline; Write-Host "████ " -f red -nonewline; Write-Host "██████ " -f darkred;
    Write-Host "                        " -f red -nonewline; Write-Host " ██" -f Yellow -nonewline; Write-Host "██    " -f red -nonewline; Write-Host "████ " -f darkred;
    Write-Host "                        " -f red -nonewline; Write-Host "█" -f red -nonewline; Write-Host "█" -f Yellow -nonewline; Write-Host "███   " -f red -nonewline; Write-Host "█████ " -f darkred;
    Write-Host "                        " -f red -nonewline; Write-Host " ██" -f Yellow -nonewline; Write-Host "███  " -f red -nonewline; Write-Host "█████ " -f darkred;
    Write-Host "                        █" -f red -nonewline; Write-Host "██" -f Yellow -nonewline; Write-Host "████" -f red -nonewline; Write-Host "█████ " -f darkred;
    Write-Host "                       ██" -f red -nonewline; Write-Host "█" -f Yellow -nonewline; Write-Host "█████" -f red -nonewline; Write-Host "████ " -f darkred;
    write-Host "                         by Dotch" -f "darkgray";write-Host ""
    Start-Sleep -s 0.5
    write-Host "Admin: " -NoNewline; write-Host $isAdmin -f "Yellow";
}
.$DrawGUI

if ($isAdmin) {$host.UI.RawUI.WindowTitle = "Squirrel Terminal  -  Administrator";}


while($true){
    if ($ForceColor -eq "true") {
        $outputColor = "Yellow"
    } else {
        $outputColor = $Host.UI.RawUI.ForegroundColor
    }
    ResetColor
    $CD = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') # $PWD
    $Command = Read-Host "SQT $CD>"
    $HostFColor = $Host.UI.RawUI.ForegroundColor
    ForceColor
    if ($Command -eq "") {
        #Do nothing
    } elseif ($Command.ToLower().StartsWith("nut") -eq "true") {
        Write-Host "";Write-Host "I like nut(s) too... :3"; Write-Host ""
        
    } elseif ($Command.ToLower().StartsWith("nuts") -eq "true") {
        Write-Host "";Write-Host "I like nuts too... :3"; Write-Host ""
        
    }elseif ($Command.ToLower() -eq "cls") {
        .$DrawGUI
        
    }elseif ($Command.ToLower().StartsWith("cd ") -eq "true") {
        if ($Command.ToLower() -eq "cd ..") {
            Write-Host "To: Backwards"
            iex $Command
        } else {
            iex $Command
            $cdToPath = $Command.TrimStart("cd")
            Write-Host "To:$cdToPath"
        }
            
    }elseif ($Command.ToLower().StartsWith("background-color") -eq "true") {
        $bgcolor = $Command.TrimStart("background-color")
        $bgcolor = $bgcolor.Trim()
        if ($bgcolor -eq "") {
            Write-Host 'Please Enter a valid color, type "colors" to view a full list.' -f red
        } else {
            $Host.UI.RawUI.BackgroundColor = $bgcolor
        }
    }elseif ($Command.ToLower().StartsWith("run") -eq "true") {
        $readFilePath = $Command.TrimStart("run")
        $readFilePath = $readFilePath.Trim()
        $readFilePath = $readFilePath.Trim('"')
        # Write-Host $pwd\$readFilePath
        
        if ($readFilePath -eq "") {
            Write-Host "Error! Please enter a path!" -f red
        }else{
            $fileExist = Test-Path -path "$readFilePath"
            $fileExistHere = Test-Path -path "$pwd\$readFilePath"
            if ($fileExist -eq "True"){
                run
            }elseif ($fileExistHere -eq "True") {
                run
            }else{
                Write-Host "Error! Please enter a valid path!`n   ('$readFilePath' is not valid!)" -f red
            }
        }
        
    }elseif ($Command.ToLower() -eq "help") {
        Write-Host "";
        squirrel-help
        Write-Host "--- Command-Help --------------------------------------------------";
        help
        Write-Host "----------------------------------------------------------";
    }elseif ($Command.ToLower().StartsWith("view-sqif") -eq "true") {
        $readFilePath = $Command.TrimStart("view-sqif")
        
        if ($Command.ToLower() -contains "-null") {
            $sqifNull = "True";
            $readFilePath = $readFilePath.Trim('-null')
        }else{
            $sqifNull = "False";
        }
        
        $readFilePath = $readFilePath.Trim()
        $readFilePath = $readFilePath.Trim('"')
        
        if ($readFilePath -eq "") {
            Write-Host "Error! Please enter a path!" -f red
        }else{
            $fileExist = Test-Path -path "$readFilePath"
            $fileExistHere = Test-Path -path "$pwd\$readFilePath"
            if ($fileExist -eq "True"){
                view-sqif
            }elseif ($fileExistHere -eq "True") {
                view-sqif
            }else{
                Write-Host "Error! Please enter a valid path!`n   ('$readFilePath' is not valid!)" -f red
            }
        }
        
    }elseif ($Command.ToLower().StartsWith("x") -eq "true") {
        #Code
        
    }elseif ($Command.ToLower().StartsWith("x") -eq "true") {
        #Code
        
    }elseif ($Command.ToLower().StartsWith("x") -eq "true") {
        #Code
        
    } else {
        #Run as a normal command
        iex $Command
    }
}