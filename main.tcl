#!/bin/sh

# sticky note thingy in tcl/tk
# just tricking tcl here\
exec wish8.5 -f "$0" ${1+"$@"}

global filename
global filetypes
set filename " "
set currentfile " "
global os
set os $tcl_platform(os)
global xcom
set xcom ""

# bindings
########################


bind . <Escape> leave
bind . <Control-z> {catch {.txt.txt edit undo}}
bind . <Control-r> {catch {.txt.txt edit redo}}
bind . <Control-a> {.txt.txt tag add sel 1.0 end}
bind . <Control-s> {file_save}
bind . <Control-b> {file_saveas}
bind . <Control-n> {eval exec notes.tcl &}
bind . <Control-t> {eval exec xterm &}
bind . <Control-p> {prnt}
bind . <Control-o> {OpenFile}
bind . <Control-q> {clear}
bind . <F11> {eval exec ticklecal}
bind . <F12> {eval exec tcalcu}


## filetypes
################

set file_types {
{"All Files" * }
{"Text Files" { .txt .TXT}}
{"Tcl Scripts" {.tcl}}
{"Shell scripts" {.sh}}
{"PowerShell Scripts" {.ps1}}
{"Perl Scripts" {.pl}}
{"Ruby Scripts" {.rb}}
{"Python Scripts" {.py}}
{"Lua Scripts" {.lua}}
{"Web Pages" {.php,.html}}
{"NuSpec Files" {.nuspec}}
}

wm title . "NoTcl"

# menu bar buttons
frame .fluff -bd 1 -relief groove

tk::menubutton .fluff.mb -text File -menu .fluff.mb.f 
tk::menubutton .fluff.ed -text Edit -menu .fluff.ed.t
tk::menubutton .fluff.tul -text Tools -menu .fluff.tul.t
ttk::combobox .fluff.size -width 4 -value [list 8 10 12 14 16 18 20 22 24 28] -state readonly

# file menu
#############################
menu .fluff.mb.f -tearoff 1
.fluff.mb.f add command -label "New" -command {eval exec notcl &} -accelerator Ctrl+n
.fluff.mb.f add command -label "Open" -command {OpenFile} -accelerator Ctrl+o
.fluff.mb.f add command -label "Save" -command {file_save} -accelerator Ctrl+s
.fluff.mb.f add command -label "SaveAs" -command {file_saveas} -accelerator Ctrl-Shift-s
.fluff.mb.f add command -label "Close" -command {clear} -accelerator Ctrl+q
.fluff.mb.f add command -label "Print" -command {prnt} -accelerator Ctrl+p
.fluff.mb.f add command -label "Quit" -command {leave} -accelerator Esc

# edit menu
######################################3
menu .fluff.ed.t -tearoff 1
.fluff.ed.t add command -label "Cut" -command cut_text -accelerator Ctrl+x
.fluff.ed.t add command -label "Copy" -command copy_text -accelerator Ctrl+c
.fluff.ed.t add command -label "Paste" -command paste_text -accelerator Ctrl+v
.fluff.ed.t add command -label "Select all"	-command ".txt.txt tag add sel 1.0 end" -accelerator Ctrl+a
.fluff.ed.t add command -label "Undo" -command {catch {.txt.txt edit undo}} -accelerator Ctrl+z
.fluff.ed.t add command -label "Redo" -command {catch {.txt.txt edit redo}} -accelerator Ctrl+r
.fluff.ed.t add command -label "About" -command {about}

tk::button .fluff.abt -text About -command {about}

tk::button .fluff.term -text "Terminal" -command {termin}

#tk::label .fluff.cmdl -text "Execute external command: "
#tk::entry .fluff.cmde -textvar xcom
#tk::button .fluff.cmdb -text "GO" -command {xcmd}
# pack em in...
############################

pack .fluff.mb -in .fluff -side left
pack .fluff.ed -in .fluff -side left
pack .fluff.size -in .fluff -side left
#pack .fluff.cmdl -in .fluff -side left
#pack .fluff.cmde -in .fluff -side left
#pack .fluff.cmdb -in .fluff -side left
pack .fluff.term -in .fluff -side left
pack .fluff.abt -in .fluff -side right

# font combobox binding

bind .fluff.size <<ComboboxSelected>> [list sizeFont .txt.txt .fluff.size]

pack .fluff -in . -fill x

# Here is the text widget
########################################TEXT WIDGET
# amazingly simple, this part, considering the great power in this little widget...
# of course, that's because someone a lot smarter than me built the widget already.
# that sure was nice of them...

frame .txt -bd 2 -relief sunken
text .txt.txt -yscrollcommand ".txt.ys set" -xscrollcommand ".txt.xs set" -maxundo 0 -undo true

scrollbar .txt.ys -command ".txt.txt yview"
scrollbar .txt.xs -command ".txt.txt xview" -orient horizontal

pack .txt.xs -in .txt -side bottom -fill x
pack .txt.txt -in .txt -side left -fill both -expand true

pack .txt.ys -in .txt -side left -fill y
pack .txt -in . -fill both -expand true

focus .txt.txt
set foco .txt.txt
bind .txt.txt <FocusIn> {set foco .txt.txt}
# bind .txt.txt <Return> {indent %W;break}

proc termin {} {
	if { $::os == "Windows NT" } {
		#print routine for windows
		eval exec "C:/Windows/system32/cmd.exe /c start &"
	} elseif { $::os == "Linux" } {
				exec xterm &
	}
}

proc xcmd {} {
	eval exec $::xcom &
}

# font size
#################
proc sizeFont {txt combo} {
	set font [$txt cget -font]
	font configure $font -size [list [$combo get]]
}

# various saving / opening / exporting procs
################################################3

proc file_save {} {
	if {$::filename != " "} {
   set data [.txt.txt get 1.0 {end -1c}]
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
	} else {file_saveas}
 
}

proc file_saveas {} { 
global filename
set filename [tk_getSaveFile -filetypes $::file_types]
   set data [.txt.txt get 1.0 {end -1c}]
   wm title . "now tickling: [file tail $::filename]"
   set fileid [open $::filename w]
   puts -nonewline $fileid $data
   close $fileid
}

# open
############################

proc OpenFile {} {

if {$::filename != " "} {
	eval exec notcl &
	} else {
	global filename
	set filename [tk_getOpenFile -filetypes $::file_types]
	wm title . "now tickling: [file tail $::filename]"
	set data [open $::filename RDWR]
	.txt.txt delete 1.0 end
	while {![eof $data]} {
		.txt.txt insert end [read $data 1000]
		}
	close $data
	.txt.txt mark set insert 1.0
	}
}

# print it
############################PRINT

proc prnt {} {
	set data [.txt.txt get 1.0 {end -1c}]
	set fileid [open $::filename w]
	puts -nonewline $fileid $data
	close $fileid
	if { $::os == "Windows NT" } {
		#print routine for windows
		eval exec "C:/Windows/system32/cmd.exe /c start /min C:/Windows/system32/notepad.EXE /p $::filename"
	} elseif { $::os == "Linux" } {
		exec cat $::filename | lpr
	}
}

## b'bye
##################################

proc leave {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
		{file_save} 
		{exit}
				}
	if {$xanswer eq "no"} {exit}
		} else {exit}
}


## clear text widget / close document
#########################################

proc clear {} {
	if {[.txt.txt edit modified]} {
	set xanswer [tk_messageBox -message "Would you like to save your work?"\
 -title "B'Bye..." -type yesnocancel -icon question]
	if {$xanswer eq "yes"} {
	{file_save} 
	{yclear}
		}
	if {$xanswer eq "no"} {yclear}
	}
}

proc yclear {} {
	.txt.txt delete 1.0 end
	.txt.txt edit reset
	.txt.txt edit modified 0
	set ::filename " "
	wm title . "NoTcl"
}

# about message box
####################################ABOUT

proc about {} {

toplevel .about
wm title .about "About NoTcl"
# tk_setPalette background $::wbg 

tk::message .about.t -text "NoTcl\n by Tony Baldwin\n text editing made simple (and tclish)\n released under the GPL\n \n http://wiki.tonybaldwin.info" -width 270
tk::button .about.o -text "Okay" -command {destroy .about} 
pack .about.t -in .about -side top
pack .about.o -in .about -side top

}


