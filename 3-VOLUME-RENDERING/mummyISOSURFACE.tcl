#############################################################
#
# Project 3
#
# author: Christos Deligkaris
#
# display one isosurface of the data and a slider for scaling
# this code can be used to find good isosurface values for the 
# skin and the bone of the mummy data
#
#############################################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../data"

#the data are of Structured Points dataset

vtkStructuredPointsReader reader
	reader SetFileName $VTK_DATA/mummy.128.vtk
	#this is needed for the GetScalarRange function
	reader Update

#use the GetScalarRange function to find the minimum and maximum 
#values of the scalar data of the data set

set range [[reader GetOutput] GetScalarRange]

#now range is a list so we have to access the
#two elements of the list to get the actual values

set min [lindex $range 0]
set max [lindex $range 1]

vtkContourFilter contour
	contour SetInputConnection [reader GetOutputPort]
	#I would expect this to be correct
	#contour GenerateValues 1 $min $min
	#but it does not work (nothing appears on the screen)
	#if I use this everything is fine
	contour GenerateValues 10 $min $max

#mapper
#both mappers work

vtkPolyDataMapper mapper
#vtkDataSetMapper mapper
	mapper SetInputConnection [contour GetOutputPort]
	mapper SetScalarRange $min $max

#actor

vtkActor actor
	actor SetMapper mapper
  	#this will bring the head in the appropriate orientation
  	actor RotateX -90

#create the scale
#the scale allow the slider to vary from the minimum value of to the maximum

frame .f
label .f.label          -text "Visualization of the mummy data set"
label .f.label_scaling  -text "Scaling - adjust the isosurface value"
scale .f.scale      -from $min         -to     $max       -orient horizontal      -command SetScale	-resolution 0.001	-length 300
button .f.quit  -text "exit"     -command exit

# "pack"ing them is what actually places them on the screen
#the order is important, the order here determines the order of appearance on the screen 

pack .f.label .f.label_scaling .f.scale .f.quit
pack .f

#procedure SetScale should change the isosurface to be drawn on the image

proc SetScale {value} {

	#we only create one isosurface with the value determined from the slider
        contour GenerateValues 1 [.f.scale get] [.f.scale get]
        renwin Render
}

#create the renderer

vtkRenderer ren
        ren AddActor actor

#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        renwin Render
	#this creates a larger window
	renwin SetSize 512 512

#use the interactor

vtkRenderWindowInteractor iren
        iren SetRenderWindow renwin

	renwin Render





