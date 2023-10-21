# VMD DisRg: New User-Friendly Implement for calculation distance and radius of gyration in VMD program

# install plug-in

step 1: Create a new folder in $VMD/plugins/noarch/tcl with name of DisRg

step 2: Copy the files of vmd-DisRg.tcl and pkgIndex.tcl into DisRg folder

step 3: Open configuration file of VMD (.vmdrc for Unix platforms or vmd.rc for windows platforms) in directory of $VMD

step 4: Copy the following lines of code in the end of configuration file
set dir $VMD/plugins/noarch/tcl/DisRg
source $dir/pkgIndex.tcl
vmd_install_extension distance distance_tk_cb “Analysis/DisRg”

step 5: In the VMD Main window, choose Extensions → Analysis → DisRg


# use VMD- DisRg immediate

Copy the vmd-DisRg.tcl to the your root directory
In the VMD Main window, choose Extensions –> Tk Console and type:

source vmd-DisRg.tcl
distance_tk_cb
