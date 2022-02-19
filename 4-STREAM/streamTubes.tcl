#############################################################
#
# Project 4
#
# author: Christos Deligkaris
#
# This program creates a visualization of the deltawing
# dataset using streamtubes
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

# Now we will generate multiple streamlines in the data. We create a random
# cloud of points and then use those as integration seeds. We select the
# integration order to use (RungeKutta order 4) and associate it with the
# streamer. The start position is the position in world space where we want
# to begin streamline integration; and we integrate in both directions. 

# Create source for streamlines
#All the values used here (radius,center,points) were found with
#our program that included the slider

vtkPointSource seeds
	#the radius of the sphere
    	seeds SetRadius 0.02
	#the position of the center of the sphere
	eval seeds SetCenter 0.025 0.230 0.0
	#the number of points
    	seeds SetNumberOfPoints 50
	#use a uniform distribution of points
	#it is the default anyway
	seeds SetDistributionToUniform

vtkPlaneSource plane
	#set the plane to be perpendicular to the X axis
	plane SetNormal 1 0 0
	#set the number of points on the plane (X and Y direction)
	plane SetResolution 10 60
        #place the plane at the center of the volume
      	eval plane SetCenter [$input GetCenter]

#use R-K 4th order
#if we do not specify anything the default Runge-Kutte 2 order will be used

vtkRungeKutta4 integ

#create the stream lines

vtkStreamTracer streamer1
	streamer1 SetInputConnection  [reader GetOutputPort]
    	streamer1 SetSourceConnection [seeds GetOutputPort]
	#integrate in both directions   
 	streamer1 SetIntegrationDirectionToBoth
	#use the above method (instead of the default Runge-Kutte 2)
    	streamer1 SetIntegrator integ

vtkStreamTracer streamer2
	streamer2 SetInputConnection  [reader GetOutputPort]
    	streamer2 SetSourceConnection [plane GetOutputPort]
	#integrate in both directions   
 	streamer2 SetIntegrationDirectionToBoth
	#use the above method (instead of the default Runge-Kutte 2)
    	streamer2 SetIntegrator integ

# The tube is wrapped around the generated streamline. By varying the radius
# by the inverse of vector magnitude, we are creating a tube whose radius is
# proportional to mass flux (in incompressible flow).

vtkTubeFilter streamTube1
	streamTube1 SetInputConnection [streamer1 GetOutputPort]
    	streamTube1 SetRadius 0.003
    	streamTube1 SetNumberOfSides 12
    	streamTube1 SetVaryRadiusToVaryRadiusByVector

vtkTubeFilter streamTube2
	streamTube2 SetInputConnection [streamer2 GetOutputPort]
    	streamTube2 SetRadius 0.003
    	streamTube2 SetNumberOfSides 12
    	streamTube2 SetVaryRadiusToVaryRadiusByVector

#the mappers for the stream lines

vtkPolyDataMapper mapper1
	mapper1 SetInputConnection [streamTube1 GetOutputPort]
	#set the color range to be the same as the scalar data range
	mapper1 SetScalarRange $vmin $vmax

vtkPolyDataMapper mapper2
	mapper2 SetInputConnection [streamTube2 GetOutputPort]
	#set the color range to be the same as the scalar data range
	mapper2 SetScalarRange $vmin $vmax

#the actors for the stream lines

vtkActor actor1
	actor1 SetMapper mapper1

vtkActor actor2
	actor2 SetMapper mapper2

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

