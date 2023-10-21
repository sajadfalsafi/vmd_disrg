#
#                                   Dis.Rg Plug-in v1.0
#
# A GUI interface for Calculate Distance and Radius of gyration in pdb file and during simulation
#
#
# Authors:
#      Sajad Falsafi Zadeh, sajad.falsafi@yahoo.com
#      Zahra Karimi, z.karimi20@yahoo.com
#
# Thu Dec 29 13:44:29 +0330 2011
## [clock format [clock scan now]]

package provide distance 1.0

namespace eval ::distance:: {
	namespace export distance_gui
	variable currentmol none
	variable seldis1 ""
	variable seldis2 ""
	variable selrg ""
	variable logtext
	variable plotdis 1 
	variable plotrg 1
	variable outputdis  
	variable outputrg 
	variable radiusdis
    variable radiusrg
	variable avgdis
}


proc ::distance::distance_gui {} {
	variable win                                                                               
	variable currentmol none
	variable seldis1 ""
	variable seldis2 ""
	variable selrg "protein"
	variable logtext 
	variable plotdis  
	variable plotrg
	variable mollist "none"
	variable menumol
	variable outputdis
	variable outputrg
	variable radiusdis 0.40
	variable radiusrg 0.40
  
	trace add variable [namespace current]::currentmol write [namespace code {
		variable currentmol
		variable menumol
		if { ! [catch { molinfo $currentmol get name } name ] } {
			set menumol "$currentmol: $name"
		} else {
      set menumol $currentmol
		}
  # } ]
	set currentmol $mollist
	variable molid 0

######## distance gui ########   
	if {[winfo exists .distancegui]} {
		wm deiconify $win
		return
	}
	set win [toplevel ".distancegui"]
	wm title $win "DisRg"
	wm resizable $win 0 0

	variable guiPlotdis $plotdis 
	variable guiPlotrg $plotrg

	################ menu ###################
    menu $win.menu -tearoff 0
    menu $win.menu.file -tearoff 0
    menu $win.menu.help -tearoff 0
    $win.menu add cascade -label "File   " -menu $win.menu.file -underline 0
    $win.menu add cascade -label "Help" -menu $win.menu.help -underline 0

    #File menu
    $win.menu.file add command -label "Reset" \
		-command "[namespace current]::ResetPlugin"
	$win.menu.file add command -label "Save Log" \
		-command "[namespace current]::SaveLog" -underline 0
    #Help menu
    $win.menu.help add command -label "Help" \
        -command "vmd_open_url http://bioinfoservices.ir"  
    $win.menu.help add command -label "About us" \
		    -command  [namespace code {tk_messageBox -parent $win -type ok -message "Authors:\n\nSajad Falsafi & Zahra Karimi" } ]
    $win configure -menu $win.menu
	

	############## frame for select molecule #############
	labelframe $win.mol -bd 2 -relief ridge -text "Select molecule" -padx 1m -pady 1m
	set f [frame $win.mol.all]
	set row 0
	grid [label $f.mollable -text "Molecule: "] \
    -row $row -column 0 -sticky e
	grid [menubutton $f.mol -textvar [namespace current]::menumol \
    -menu $f.mol.menu -relief raised -cursor hand2 ] \
    -row $row -column 1 -columnspan 3 -sticky w 
	menu $f.mol.menu -tearoff no
	incr row
	fill_mol_menu $f.mol.menu
	trace add variable ::vmd_initialize_structure write [namespace code "
    fill_mol_menu $f.mol.menu
	# " ]
	pack $f -side top -padx 0 -pady 5 -expand 1 -fill x
	pack $win.mol -side top -pady 5 -padx 3 -fill x -anchor w 
	################# frame for distance #################
	labelframe $win.dis -bd 2 -relief ridge -text "Distance" -padx 1m -pady 1m
	set f [frame $win.dis.all]
	set row 0
   grid [label $f.sellabel1 -text "Selection 1 : "] \
    -row $row -column 0 -sticky e
	grid [entry $f.sel1 -width 50 -highlightthickness 3 \
    -textvariable [namespace current]::seldis1] \
    -row $row -column 1 -columnspan 3 -sticky ew
	incr row
	grid [label $f.sellabel2 -text "Selection 2 :"] \
    -row $row -column 0 -sticky e
	grid [entry $f.sel2 -width 50 -highlightthickness 3 \
    -textvariable [namespace current]::seldis2] \
    -row $row -column 1 -columnspan 3 -sticky ew
	incr row
	grid [checkbutton $f.check1 -text \
    "Plot...?" \
    -variable [namespace current]::guiPlotdis] \
    -row $row  -column 0 -columnspan 1 -sticky w
	grid [label $f.rdlabel -text "Sphere Scale (for center of mass of a selection) :"] \
    -row $row -column 1 -columnspan 1 -sticky w
	grid [spinbox $f.rad -from 0.10 -to 5.0 -increment 0.10 -format %5.2f -width 9 -highlightthickness 3 \
	-textvariable [namespace current]::radiusdis ] \
    -row $row -column 3 -columnspan 1 -sticky w
	incr row
	grid [label $f.label -text "Output File: "] \
    -row $row -column 0 -columnspan 1 -sticky w
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
	grid [entry $f.entry -textvariable ::distance::outputdis -highlightthickness 3 \
    -width 35 -relief sunken -justify left ] \
    -row $row -column 1 -columnspan 1 -sticky w
	grid [button $f.button -text "Save as.."   -width 10 -cursor hand2 -command [namespace code OutputFileDis] ] \
    -row $row -column 3 -columnspan 1 -sticky w 
	incr row
	set f [frame $win.dis.cal]
	set row 1
	button $f.buttondis -text "Calculate Distance" -width 20 -cursor hand2 -command { ::distance::distance }  
	pack $f $f.buttondis
	pack $win.dis -side top -pady 5 -padx 3 -fill x -anchor w
	################### frame for rgyr ###################
	labelframe $win.rgyr -bd 2 -relief ridge -text "Radius of gyration" -padx 1m -pady 1m
	set f [frame $win.rgyr.all]
	set row 0
	grid [label $f.sellabel1 -text "Selection : "] \
    -row $row -column 0 -sticky e
	grid [entry $f.sel1 -width 50 -highlightthickness 3 \
    -textvariable [namespace current]::selrg] \
    -row $row -column 1 -columnspan 3 -sticky ew
	incr row
	grid [checkbutton $f.check1 -text \
    "Plot...?" \
    -variable [namespace current]::guiPlotrg] \
    -row $row -column 0 -columnspan 1 -sticky w
	grid [label $f.rdrglabel -text "Sphere Scale (for center of mass of a selection) :"] \
    -row $row -column 1 -columnspan 1 -sticky w
	grid [spinbox $f.radrg -from 0.10 -to 5.0 -increment 0.10 -format %5.2f -width 9 -highlightthickness 3 \
	-textvariable [namespace current]::radiusrg ] \
    -row $row -column 3 -columnspan 1 -sticky w
	incr row
	grid [label $f.label -text "Output File: "] \
    -row $row -column 0 -columnspan 1 -sticky w
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
	grid [entry $f.entry -textvariable ::distance::outputrg -highlightthickness 3 \
    -width 35 -relief sunken -justify left ] \
    -row $row -column 1 -columnspan 1 -sticky e
	grid [button $f.button -text "Save as.."   -width 10 -cursor hand2 -command [namespace code OutputFilerg] ] \
    -row $row -column 3 -columnspan 1 -sticky w 
	incr row
	set f [frame $win.rgyr.cal]
	set row 1
	button $f.buttondis -text "Calcuate Rgyr" -width 20 -cursor hand2 -command { ::distance::rgyr }  
	pack $f $f.buttondis
	pack $win.rgyr -side top -pady 5 -padx 3 -fill x -anchor w
	################### frame for Log File ###################
	labelframe $win.log -bd 2 -relief ridge -text "Log File" -padx 1m -pady 1m
	set f [frame $win.log.all]
	set row 0
	text $f.logtext -width 60 -height 8 -yscrollcommand "$f.srl_y set" -highlightthickness 3 
	scrollbar $f.srl_y -command "$f.logtext yview" -orient v  
	grid $f.logtext -row 1 -column 1
	grid $f.srl_y -row 1 -column 2 -sticky ns
	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
	pack $win.log -side top -pady 5 -padx 3 -fill x -anchor w
	#about us #
#	labelframe $win.about -bd 2 -relief ridge -text "" -padx 1m -pady 1m
#	set f [frame $win.about.all]
#	set row 0
#	grid [label $f.lab -text "Authors: Sajad Falsafi & Zahra Karimi"] -row $row -column 0
#	pack $f -side top -padx 0 -pady 0 -expand 1 -fill none
#	pack $win.about -side top -pady 5 -padx 3 -fill x -anchor w
}

# Adapted from pmepot gui
proc ::distance::fill_mol_menu {name} {

	variable molid
	variable currentmol
	variable mollist0
	$name delete 0 end
	set molList ""
	foreach mm [array names ::vmd_initialize_structure] {
		if { $::vmd_initialize_structure($mm) != 0} {
      lappend molList $mm
      $name add radiobutton -variable [namespace current]::currentmol \
        -value $mm -label "$mm [molinfo $mm get name]"
		}
	}
}

proc ::distance::distance {} {
	global tk_version
	variable currentmol
	variable seldis1
	variable seldis2 
	variable plotdis
	variable guiPlotdis
	variable nf
	variable outputdis	
	variable logtext
	variable win
	variable radiusdis
	variable avgdis

	# check molecule	
	if { $currentmol == "none" } {
		tk_messageBox -type ok -title "Select molecule" \
		 -message "Please Select the molecule"
		return
	}
	
	# check selection	
	if { $seldis1 == "" } {
		tk_messageBox -type ok -title "Inter Selection" \
		 -message "Please Inter Selection 1"
		return
	}
	
	if { $seldis2 == "" } {
		tk_messageBox -type ok -title "Inter Selection" \
		 -message "Please Inter Selection 2"
		return
	}

	# set log file	
	if {$outputdis == ""} {
		set log "stdout"
	} else {
		set log [open "$outputdis" w]
	}	
	puts $log "frame--distance"
	$win.log.all.logtext insert end "distance \n"
	set sel1 [atomselect $currentmol "$seldis1"]
	set sel2 [atomselect $currentmol "$seldis2"]
	set nf [molinfo $currentmol get numframes]
	# graphical #
	set cr1 [measure center $sel1]
	set cr2 [measure center $sel2]
	set all [atomselect $currentmol all]
	mol delrep 0 $currentmol
	mol delrep 0 $currentmol
	mol delrep 0 $currentmol
	mol color ColorID 1
	mol representation Licorice 0.1 10.0 10.0
	mol selection "same residue as ($seldis1)"
	mol addrep $currentmol
	mol color ColorID 1
	mol representation Licorice 0.1 10.0 10.0
	mol selection "same residue as ($seldis2)"
	mol addrep $currentmol
	mol color ColorID 2
	mol representation NewCartoon
	mol selection "protein"
	mol addrep $currentmol
	color Display Background white
	axes location off
	graphics $currentmol delete all
	graphics $currentmol sphere $cr1 radius $radiusdis resolution 80
	graphics $currentmol sphere $cr2 radius $radiusdis resolution 80
	# zoom selection
	set selcenter [atomselect $currentmol "($seldis1) or ($seldis2)"]
	set center [measure center $selcenter]
	$selcenter delete
	molinfo $currentmol set center [list $center]
	scale to 0.1
	translate to 0 0 0
	display update	
	# loop	
	for { set i 0 } { $i < $nf } { incr i } {
		$sel1 frame $i
		$sel2 frame $i
		set com1 [measure center $sel1 weight mass]
		set com2 [measure center $sel2 weight mass]
		set dis [veclength [vecsub $com1 $com2]]
		$win.log.all.logtext insert end "$i    $dis\n"
		puts $log "$i  $dis"
		lappend framecount $i
		lappend numdistance $dis
	}

	if {$outputdis != ""} {
		close $log
	}
	
	# 
	set average 0
	foreach n $numdistance {
		set average [expr $average+$n]
	}
	set avgdis [expr $average / [llength $numdistance]]
	set rounddis [expr {wide(($avgdis*10**2) + 0.5) / double(10**2)}]
	# plot
	if { $guiPlotdis == 1 } {	
		set title [format "%s %s %s: %s" Molecule $currentmol, [molinfo $currentmol get name]  "Distance vs. Frame"]
		set plothandle [multiplot -title $title -xlabel "Frame " -ylabel "Distance"]
		$plothandle add $framecount $numdistance -lines -linewidth 1 -linecolor black -marker none
		$plothandle replot
	}
	# add label
	graphics $currentmol line $cr1 $cr2 width 5 style dashed
	draw color blue
	graphics $currentmol text $center " $rounddis"
}
	

proc ::distance::rgyr {} {
	global tk_version
	variable win
	variable currentmol
	variable selrg
	variable plotrg
	variable guiPlotrg
	variable plotDistance
	variable outputrg
	variable logtext
	variable radiusrg

	# check molecule	
	if { $currentmol == "none" } {
		tk_messageBox -type ok -title "Select molecule" \
		 -message "Please Select the molecule"
		return
	}
	
	# check selection	
	if { $selrg == "" } {
		tk_messageBox -type ok -title "Inter Selection" \
		 -message "Please Inter Selection"
		return
	}
	
	# set log file
	if {$outputrg == ""} {
		set log "stdout"
	} else {
		set log [open "$outputrg" w]
	}
	
	puts $log "frame--distance"
	set sel1 [atomselect $currentmol "$selrg"]
	set nf [molinfo $currentmol get numframes]
	$win.log.all.logtext insert end "the rgyr of $selrg of [molinfo $currentmol get name] is:\n"
	
	# graphical
	set centerrg [measure center $sel1]
	mol delrep 0 $currentmol
	mol delrep 0 $currentmol
	mol delrep 0 $currentmol
	mol color ColorID 1
	mol representation Licorice 0.1 10.0 10.0
	mol selection "same residue as ($selrg)"
	mol addrep $currentmol
	color Display Background white
	axes location off
	graphics $currentmol delete all
	graphics $currentmol sphere $centerrg radius $radiusrg resolution 80
	# zoom selection
	molinfo $currentmol set center [list $centerrg]
	scale to 0.05
	translate to 0 0 0
	display update	
	
	#loop
	for { set i 0 } { $i < $nf } { incr i } {
		$sel1 frame $i
		set rgyr [measure rgyr $sel1 weight mass]
		$win.log.all.logtext insert end "$i  $rgyr\n"
		puts $log "$i  $rgyr"
	
		lappend framecount $i
		lappend numdistance $rgyr
	}
	
	if {$outputrg != ""} {
		close $log
	}
	
	if { $guiPlotrg == 1 } {	
		set title [format "%s %s %s: %s" Molecule top, [molinfo top get name]  "Rgyr vs. Frame"]
		set plothandle [multiplot -title $title -xlabel "Frame " -ylabel "Rgyr"]
		$plothandle add $framecount $numdistance -lines -linewidth 1 -linecolor black -marker none
		$plothandle replot
	}

}
	

proc ::distance::OutputFileDis {} {
	variable outputdis
	set typeFile {
		{"XVG Files" ".xvg"}
	}
	set fd [tk_getSaveFile -filetypes $typeFile -defaultextension ".xvg"]
	set outputdis "$fd"
}	
	

proc ::distance::OutputFilerg {} {
	variable outputrg
	set typeFile {
		{"XVG Files" ".xvg"}
	}
	set fd [tk_getSaveFile -filetypes $typeFile -defaultextension ".xvg"]
	set outputrg "$fd"
}


proc ::distance::SaveLog { } {
	variable save
	set typeFile {
		{"Data Files" ".dat .txt"}
		{"All files" ".*"}
	}
	set file [tk_getSaveFile -filetypes $typeFile -defaultextension ".dat" -title "Inter File name to save data" -parent .distancegui]
	if {$file != ""} {
	set save $file
	set fd [open $file w]
	set savealllog [.distancegui.log.all.logtext get 1.0 end]
	puts $fd "$savealllog"
	close $fd
	}
	return
}


proc ::distance::ResetPlugin {} {
	variable win
	variable currentmol
	variable radiusdis 0.40
	variable guiPlotdis 1
	variable guiPlotrg 1
	variable radiusrg 0.40

	$win.log.all.logtext delete 1.0 end
	$win.dis.all.sel1 delete 0 end
	$win.dis.all.sel2 delete 0 end
	$win.rgyr.all.sel1 delete 0 end
	$win.rgyr.all.sel1 insert end "protein"
	$win.dis.all.entry delete 0 end
	$win.rgyr.all.entry delete 0 end
	if { $currentmol != "none" } {
		mol delrep 0 $currentmol
		mol delrep 0 $currentmol
		mol delrep 0 $currentmol
		mol color Name
		mol representation Lines
		mol selection "all"
		mol addrep $currentmol
		graphics $currentmol delete all
		color Display Background black
		axes location lowerleft
	}
}


proc distance_tk_cb {} {
	::distance::distance_gui 
	return $::distance::win
}