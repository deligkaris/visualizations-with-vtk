#############################################################
#
# Project 4
#
# author: Christos Deligkaris
#
# This program creates a visualization of the deltawing
# dataset using streamsurfaces
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
#puts "$xmin $xmax $ymin $ymax $zmin $zmax"

#with the following we get the range of the scalar data
#deltawing has pressure scalar data whereas deltawing2 has speed scalar data

set range [$input GetScalarRange]
set vmin [lindex $range 0]
set vmax [lindex $range 1]
#display on the screen the information
#puts "scalar data range: $vmin $vmax"

# We use a rake to generate a series of streamline starting points
# scattered along a line. Each point will generate a streamline. These
# streamlines are then fed to the vtkRuledSurfaceFilter which stitches
# the lines together to form a surface.

vtkLineSource rake1
	#with the two points we define our line
	rake1 SetPoint1 0.07 0.140 0.0
	rake1 SetPoint2 0.07 0.200 0.0
	#this will set the number of streamlines
	rake1 SetResolution 40

vtkLineSource rake2
	#with the two points we define our line
	rake2 SetPoint1 0.07 0.240 0.0
	rake2 SetPoint2 0.07 0.300 0.0
	#this will set the number of streamlines
	rake2 SetResolution 40

#use R-K 4th order
#if we do not specify anything the default Runge-Kutte 2 order will be used

vtkRungeKutta4 integ

vtkStreamTracer sl1
	sl1 SetInputConnection [reader GetOutputPort]
	sl1 SetSourceConnection [rake1 GetOutputPort] 
	sl1 SetIntegrator integ 

vtkStreamTracer sl2
	sl2 SetInputConnection [reader GetOutputPort]
	sl2 SetSourceConnection [rake2 GetOutputPort] 
	sl2 SetIntegrator integ 

# The ruled surface stiches together lines with triangle strips.
# Note the SetOnRatio method. It turns on every other strip that
# the filter generates (only when multiple lines are input).

vtkRuledSurfaceFilter scalarSurface1
	scalarSurface1 SetInputConnection [sl1 GetOutputPort]
	scalarSurface1 SetOffset 0 
	scalarSurface1 SetOnRatio 1 
	scalarSurface1 PassLinesOff
	scalarSurface1 SetRuledModeToPointWalk
	scalarSurface1 SetDistanceFactor 200 

vtkRuledSurfaceFilter scalarSurface2
	scalarSurface2 SetInputConnection [sl2 GetOutputPort]
	scalarSurface2 SetOffset 0 
	scalarSurface2 SetOnRatio 1 
	scalarSurface2 PassLinesOff
	scalarSurface2 SetRuledModeToPointWalk
	scalarSurface2 SetDistanceFactor 100 

#the mappers for the stream surface

vtkPolyDataMapper mapper1
	mapper1 SetInputConnection [scalarSurface1 GetOutputPort]
	#set the scalar range equal to the data range
	mapper1 SetScalarRange $vmin $vmax

vtkPolyDataMapper mapper2
	mapper2 SetInputConnection [scalarSurface2 GetOutputPort]
	#set the scalar range equal to the data range
	mapper2 SetScalarRange $vmin $vmax

#create the actors

vtkActor actor1
	actor1 SetMapper mapper1
	[actor1 GetProperty] SetOpacity 0.8

vtkActor actor2
	actor2 SetMapper mapper2
	[actor2 GetProperty] SetOpacity 0.8

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

#create the renderer

vtkRenderer ren
        ren AddActor actor1
	ren AddActor actor2
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

wm withdraw .

