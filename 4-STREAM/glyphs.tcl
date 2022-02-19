#######################################################################
#
# Project 4
#
# author: Christos Deligkaris
#
# This program visualizes the deltawing dataset using glyphs
# The user can use cones or arrows to represent the velocity vectors
# A slider is created as user interface and with this the user can
# move the position of the plane on which we show the velocity vectors
#
#######################################################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../data"

#the data are of Structured Points dataset

vtkStructuredPointsReader reader
        #reader SetFileName $VTK_DATA/deltawing.vtk
	reader SetFileName $VTK_DATA/deltawing2.vtk
        #this is needed for the GetScalarRange function
	#and perhaps the GetBounds function
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

#create a plane used for cutting the volume

vtkPlane plane
	#initially place the plane at the minimum value of x
	set origin [list $xmin 0 0]
       	eval plane SetOrigin $origin
	#make the plane perpendicular to the X axis
	plane SetNormal 1. 0. 0.

#create the cutter, used as Input in the Probe filter

vtkCutter planeCut
	planeCut SetInputConnection [reader GetOutputPort] 
	planeCut SetCutFunction plane

#probe the volume data in the plane defined previously

vtkProbeFilter probe
	probe SetInputConnection [planeCut GetOutputPort]
	probe SetSourceConnection [reader GetOutputPort]

#this will subsample the dataset in case we have too many arrows/cones to visualize 

vtkMaskPoints ptMask
	ptMask SetInputConnection [probe GetOutputPort]
	#this determines the amount of subsampling
	#if the ratio is 1 then we keep all the data
	ptMask SetOnRatio 1
	#this can be used if we want random sampling of our data
	#ptMask RandomModeOn

#we can use various objects to show the direction of the velocity vectors

# In this case we are using a cone as a glyph. We transform the cone so
# its base is at 0,0,0. This is the point where glyph rotation occurs.

#vtkConeSource cone
#	cone SetResolution 6
#vtkTransform transform
#	transform Translate 0.5 0.0 0.0
#vtkTransformPolyDataFilter transformF
	#transformF SetInputConnection [cone GetOutputPort]
	#transformF SetTransform transform

#or we can use arrows to represent the velocity vectors 
#this seems more logical choice 
#in this case we do not have to do any translation 

vtkArrowSource arrow
	#make sure that the resolution of the arrows is good enough
	arrow SetTipResolution 6
	arrow SetShaftResolution 6

# vtkGlyph3D takes two inputs: the input point set (SetInputConnection)
# which can be any vtkDataSet; and the glyph (SetSourceConnection) which
# must be a vtkPolyData. 

vtkGlyph3D glyph
	glyph SetInputConnection  [ptMask GetOutputPort]
	#this should be used for cones
	#glyph SetSourceConnection [transformF GetOutputPort]
	#this should be used for arrows
	glyph SetSourceConnection [arrow GetOutputPort]
	#use the vector data (velocities in our case)
	glyph SetVectorModeToUseVector
	#scale the vectors according to their magnitude (speed in our case)
	#no need to use the scalar data since the magnitude of velocity is speed
	glyph SetScaleModeToScaleByVector
	#set the scale factor 
	glyph SetScaleFactor 0.0008

#create the appropriate mapper

vtkPolyDataMapper mapper
	mapper SetInputConnection [glyph GetOutputPort]
	#with this we set the range of the scalars the same as the range 
	#of the speed data
	mapper SetScalarRange $vmin $vmax

#create the appropriate actor

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
	#make the outline to appear as black lines
	[actorOutline GetProperty] SetColor 0 0 0

#create the scale
#the scale allow the slider to vary from the minimum value of to the maximum

frame .f
label .f.label          -text "Visualization of the deltawing data set"
label .f.label_scaling  -text "Scaling - adjust the X coordinate of the plane "
scale .f.scale      -from $xmin         -to     $xmax       -orient horizontal      -command SetScale     -resolution 0.0005       -length 300
button .f.quit  -text "exit"     -command exit

# "pack"ing them is what actually places them on the screen
#the order is important, the order here determines the order of appearance on the screen 

pack .f.label .f.label_scaling .f.scale .f.quit
pack .f

#procedure SetScale should actually change the position of the plane

proc SetScale {value} {

	#create a list with the current X value and set Y=Z=0, Y and Z do not play any role in this case
	set origin [list [.f.scale get] 0 0]
	eval plane SetOrigin $origin
        renwin Render
}

#create the renderer

vtkRenderer ren
	#use RGB to set the color of the background to white
	ren SetBackground 1 1 1
	#add the velocity vectors on the screen
        ren AddActor actor
	#add the outline on the screen
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



