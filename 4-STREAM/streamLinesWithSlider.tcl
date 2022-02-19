#############################################################
#
# Project 4
#
# author: Christos Deligkaris
#
# This program visualizes the deltawing dataset using 
# streamlines. A number of sliders are used in order to allow
# the user to change the radius of the sphere, the center 
# of the sphere and the number of seeds for the streamlines
# We use this program in order to identify interesting
# regions of the dataset
#
#############################################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../data"

#the data are of Structured Points dataset

vtkStructuredPointsReader reader
        reader SetFileName $VTK_DATA/deltawing2.vtk
        #this is needed for the GetScalarRange function 
	#and perhaps the GetBound function
        reader Update

#with the following we get the boundary values of x,y,z

set input [reader GetOutput]

set bounds [$input GetBounds]
set xmin [lindex $bounds 0]
set xmax [lindex $bounds 1]
set ymin [lindex $bounds 2]
set ymax [lindex $bounds 3]
set zmin [lindex $bounds 4]
set zmax [lindex $bounds 5]
#display on the screen the information
puts "$xmin $xmax $ymin $ymax $zmin $zmax"

#with the following we get the range of the scalar data
#deltawing has pressure scalar data whereas deltawing2 has speed scalar data

set range [$input GetScalarRange]
set vmin [lindex $range 0]
set vmax [lindex $range 1]
#display on the screen the information
puts "scalar data range: $vmin $vmax"

# Now we will generate multiple streamlines in the data. We create a random
# cloud of points and then use those as integration seeds. We select the
# integration order to use (RungeKutta order 4) and associate it with the
# streamer. The start position is the position in world space where we want
# to begin streamline integration; and we integrate in both directions. 

# Create source for streamlines

vtkPointSource seeds
	#set the radius of the sphere
    	seeds SetRadius 0.
	#set the center of the sphere
	seeds SetCenter $xmin $ymin $zmin
	#set the number of points that will be distributed uniformly in the sphere
	#essentially this is the number of streamlines
    	seeds SetNumberOfPoints 0

#use R-K 4th order
#if we do not specify anything the default Runge-Kutte 2 order will be used

vtkRungeKutta4 integ

#create the stream lines

vtkStreamTracer streamer
	streamer SetInputConnection  [reader GetOutputPort]
    	streamer SetSourceConnection [seeds GetOutputPort]
	#integrate in both directions
    	streamer SetIntegrationDirectionToBoth
	#use the above specified method
    	streamer SetIntegrator integ

#the mapper for the stream lines

vtkPolyDataMapper mapper
	mapper SetInputConnection [streamer GetOutputPort]
	#set the color range to be the same as the scalar data range
	mapper SetScalarRange $vmin $vmax

#the actor for the stream lines

vtkActor actor
	actor SetMapper mapper

# Create a vtkOutlineFilter to draw the bounding box of the data set
# Also create the associated mapper and actor.

vtkOutlineFilter outline
        outline SetInputConnection [reader GetOutputPort]
vtkPolyDataMapper mapperOutline
        mapperOutline SetInputConnection [outline GetOutputPort]
vtkActor actorOutline
        actorOutline SetMapper mapperOutline
        #make the outline to appear as white lines
        [actorOutline GetProperty] SetColor 1 1 1

#create the scale
#with the scale the user can change the radius of the sphere, the number of seed points, and the X, Y, Z coordinates of the sphere's center

frame .f
label .f.label          -text "Visualization of the deltawing data set"
label .f.label_radius  -text "Adjust the radius of the sphere"
scale .f.scale_radius	-from 0.         -to     $xmax       -orient horizontal      -command SetRadius     -resolution 0.001       -length 300
label .f.label_npoints  -text "Adjust the number of points used as seeds"
scale .f.scale_npoints	-from 0          -to     150	     -orient horizontal      -command SetNPoints    -resolution 1	 
label .f.label_center	-text "Adjust the position of the sphere's center"
label .f.label_x	-text "X"
scale .f.scale_x	-from $xmin      -to     $xmax       -orient horizontal      -command SetCenter	    -resolution 0.001       -length 300
label .f.label_y        -text "Y"
scale .f.scale_y  	-from $ymin      -to     $ymax       -orient horizontal      -command SetCenter     -resolution 0.001       -length 300
label .f.label_z        -text "Z"
scale .f.scale_z     	-from $zmin      -to     $zmax       -orient horizontal      -command SetCenter	    -resolution 0.001       -length 300
button .f.quit  	-text "exit"     -command exit

# "pack"ing them is what actually places them on the screen
#the order is important, the order here determines the order of appearance on the screen 

pack .f.label .f.label_radius .f.scale_radius .f.label_npoints .f.scale_npoints .f.label_center .f.label_x .f.scale_x .f.label_y .f.scale_y .f.label_z .f.scale_z .f.quit
pack .f

#procedure SetScale should change the position of the plane

proc SetRadius {value} {

	seeds SetRadius [.f.scale_radius get]
        renwin Render
}

proc SetNPoints {value} {

        seeds SetNumberOfPoints [.f.scale_npoints get]
        renwin Render
}

proc SetCenter {value} {

        seeds SetCenter [.f.scale_x get] [.f.scale_y get] [.f.scale_z get]
        renwin Render
}

#create the renderer

vtkRenderer ren
        ren AddActor actor
	ren AddActor actorOutline

#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        renwin Render
        #this creates a larger window
        renwin SetSize 512 512

#use the interactor

vtkRenderWindowInteractor iren
        iren SetRenderWindow renwin

#render after we have added the interactor
renwin Render

