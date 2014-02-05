#!/bin/sh

# NoTcl started as a sticky note thingy in tcl/tk
# now it's a bit more than that, but still a very basic
# editor, quick, light, very simple, and easy to use.
# just tricking tcl here\
exec wish8.5 -f "$0" ${1+"$@"}

package require Tk
package require Ttk

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


bind . <Escape> {leave}
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
bind . <F3> {FindPopup}
bind . <F4> {termin}


## filetypes
################

set file_types {
{"All Files" * }
{"Text Files" { .txt .TXT}}
{"LaTex" {.tex}}
{"Tcl Scripts" {.tcl}}
{"Python" {.py}}
{"Perl" {.pl}}
{"PHP" {.php}}
{"Java" {.java}}
{"Ruby Scripts" {.rb}}
{"Lua Scripts" {.lua}}
{"C files" {.c}}
{"Shell scripts" {.sh}}
{"Xml" {.xml}}
{"Html" {.html}}
{"CSS" {.css}}
{"PowerShell Scripts" {.ps1}}
{"Visual Basic Scripts" {.vs}}
{"AutoIt" {.au3}}
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
.fluff.ed.t add separator
.fluff.ed.t add command -label "Search" -command {FindPopup} -accelerator F3
.fluff.ed.t add separator
.fluff.ed.t add command -label "Terminal" -command {termin} -accelerator F4
.fluff.ed.t add command -label "About" -command {about}

# terminal button starts xterm or cmd.exe
tk::button .fluff.term -text "Terminal" -command {termin}

# font combobox binding
tk::label .fluff.fnt -text "font size: " 
bind .fluff.size <<ComboboxSelected>> [list sizeFont .txt.txt .fluff.size]

# about button
tk::button .fluff.abt -text About -command {about}

pack .fluff.mb -in .fluff -side left
pack .fluff.ed -in .fluff -side left
pack .fluff.abt -in .fluff -side right
pack .fluff.size -in .fluff -side right
pack .fluff.fnt -in .fluff -side right
pack .fluff.term -in .fluff -side right
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
	} else {sorry}
}

proc sorry {} {
	toplevel .sorry
	wm title .sorry "Sorry"
	tk::message .sorry.t -text "I'm sorry, but I do not know what to do on $::os." -width 270
	tk::button .sorry.o -text "Okay" -command {destroy .sorry} 
	pack .sorry.t -in .sorry -side top
	pack .sorry.o -in .sorry -side top
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
	} else {sorry}
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

tk::message .about.t -text "NoTcl\n by Tony Baldwin\n text editing made simple (and tclish)\n released under the GPL\n \n http://tonyb.us/notcl" -width 270
tk::button .about.o -text "Okay" -command {destroy .about} 
pack .about.t -in .about -side top
pack .about.o -in .about -side top

}

# find/replace/go to line
############################################FIND REPLACE DIALOG

proc FindPopup {} {

global seltxt repltxt

toplevel .fpop 
# -width 12c -height 4c

wm title .fpop "Find Text"
bind .fpop <Escape> {destroy .fpop}

frame .fpop.l1 -bd 2 -relief raised

tk::label .fpop.l1.fidis -text "FIND     :"
tk::entry .fpop.l1.en1 -width 20 -textvariable seltxt
tk::button .fpop.l1.finfo -text "Forward" -command {FindWord  -forwards $seltxt}
tk::button .fpop.l1.finbk -text "Backward" -command {FindWord  -backwards $seltxt}
tk::button .fpop.l1.tagall -text "Highlight All" -command {TagAll}

pack .fpop.l1.fidis -in .fpop.l1 -side left
pack .fpop.l1.en1 -in .fpop.l1 -side left
pack .fpop.l1.finfo -in .fpop.l1 -side left
pack .fpop.l1.finbk -in .fpop.l1 -side left
pack .fpop.l1.tagall -in .fpop.l1 -side left
pack .fpop.l1 -in .fpop -fill x


frame .fpop.l2 -bd 2 -relief raised

tk::label .fpop.l2.redis -text "REPLACE:"
tk::entry .fpop.l2.en2 -width 20 -textvariable repltxt
tk::button .fpop.l2.refo -text "Forward" -command {ReplaceSelection -forwards}
tk::button .fpop.l2.reback -text "Backward" -command {ReplaceSelection -backwards}
tk::button .fpop.l2.repall -text "Replace All" -command {ReplaceAll}

pack .fpop.l2.redis -in .fpop.l2 -side left
pack .fpop.l2.en2 -in .fpop.l2 -side left
pack .fpop.l2.refo -in .fpop.l2 -side left
pack .fpop.l2.reback -in .fpop.l2 -side left
pack .fpop.l2.repall -in .fpop.l2 -side left
pack .fpop.l2 -in .fpop -fill x

frame .fpop.l3 -bd 2 -relief raised

tk::label .fpop.l3.goto -text "Line No. :"
tk::entry .fpop.l3.line -textvariable lino
tk::button .fpop.l3.now -text "Go" -command {gotoline}
tk::button .fpop.l3.dismis -text Done -command {destroy .fpop}

pack .fpop.l3.goto -in .fpop.l3 -side left
pack .fpop.l3.line -in .fpop.l3 -side left
pack .fpop.l3.now -in .fpop.l3 -side left
pack .fpop.l3.dismis -in .fpop.l3 -side right
pack .fpop.l3 -in .fpop -fill x


# focus .fpop.en1
}

## all this find-replace stuff needs work...

proc FindWord {swit seltxt} {
global found
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
scan [.txt.txt index insert] %d cl
if {[string compare $swit "-forwards"] == 0 } {
set curpos [.txt.txt index "insert + $l1 chars"]

for {set i $cl} {$i < $nl} {incr i} {
		
	#.txt.txt mark set first $i.0
	.txt.txt mark set last  $i.end ;#another way "first lineend"
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search $swit -exact $seltxt $curpos]
	if {$curpos != ""} {
		selection clear .txt.txt 
		.txt.txt mark set insert "$curpos + $l1 chars "
		.txt.txt see $curpos
		set found 1
		break
		} else {
		set curpos $lpos
		set found 0
			}
	}
} else {
	set curpos [.txt.txt index insert]
	set i $cl
	.txt.txt mark set first $i.0
	while  {$i >= 1} {
		
		set fpos [.txt.txt index first]
		set i [expr $i-1]
		
		set curpos [.txt.txt search $swit -exact $seltxt $curpos $fpos]
		if {$curpos != ""} {
			selection clear .txt.txt
			.txt.txt mark set insert $curpos
			.txt.txt see $curpos
			set found 1
			break
			} else {
				.txt.txt mark set first $i.0
				.txt.txt mark set last "first lineend"
				set curpos [.txt.txt index last]
				set found 0
			}
		
	}
}
}

proc FindSelection {swit} {

global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
FindWord $swit $seltxt
}

proc FindValue {} {

FindPopup
}

proc TagSelection {} {
global seltxt GotSelection
if {$GotSelection == 0} {
	set seltxt [selection get STRING]
	set GotSelection 1
	} 
TagAll 
}

proc ReplaceSelection {swit} {
global repltxt seltxt found
set l1 [string length $seltxt]
FindWord $swit $seltxt
if {$found == 1} {
	.txt.txt delete insert "insert + $l1 chars"
	.txt.txt insert insert $repltxt
	}
}

proc ReplaceAll {} {
global seltxt repltxt
set l1 [string length $seltxt]
set l2 [string length $repltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index 1.0]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
	
	if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		.txt.txt delete insert "insert + $l1 chars"
		.txt.txt insert insert $repltxt
		.txt.txt mark set insert "insert + $l2 chars"
		set curpos [.txt.txt index insert]
		} else {
			set curpos $lpos
			}
	}
}

proc TagAll {} {
global seltxt 
set l1 [string length $seltxt]
scan [.txt.txt index end] %d nl
set curpos [.txt.txt index insert]
for {set i 1} {$i < $nl} {incr i} {
	.txt.txt mark set last $i.end
	set lpos [.txt.txt index last]
	set curpos [.txt.txt search -forwards -exact $seltxt $curpos $lpos]
		if {$curpos != ""} {
		.txt.txt mark set insert $curpos
		scan [.txt.txt index "insert + $l1 chars"] %f pos
		.txt.txt tag add $seltxt $curpos $pos
		.txt.txt tag configure $seltxt -background yellow -foreground purple
		.txt.txt mark set insert "insert + $l1 chars"
		set curpos $pos
		} else {
			set curpos $lpos
			}
	}
}



# This program was written by Tony Baldwin / http://wiki.tonybaldwin.info
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


