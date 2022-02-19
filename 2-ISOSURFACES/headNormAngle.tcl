#############################################################
#
# Project 2
#
# author: Christos Deligkaris
#
# display one isosurface of the head data and a slider for scaling
# the isosurface is colored with some volume data (norm or angle)
#
#############################################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../data"

#the data are of Structured Points dataset

vtkStructuredPointsReader readerHead
	readerHead SetFileName $VTK_DATA/head.60.vtk
	#this is needed for the GetScalarRange function
	readerHead Update

vtkStructuredPointsReader readerNorm
        readerNorm SetFileName $VTK_DATA/norm.60.vtk
        #this is needed for the GetScalarRange function
        readerNorm Update

vtkStructuredPointsReader readerAngle
        readerAngle SetFileName $VTK_DATA/angle.60.vtk
        #this is needed for the GetScalarRange function
        readerAngle Update

#use the GetScalarRange function to find the minimum and maximum 
#values of the scalar data of the data set

set rangeHead [[readerHead GetOutput] GetScalarRange]
set rangeNorm [[readerNorm GetOutput] GetScalarRange]
set rangeAngle [[readerAngle GetOutput] GetScalarRange]

#now range is a list so we have to access the
#two elements of the list to get the actual values

set minHead [lindex $rangeHead 0]
set maxHead [lindex $rangeHead 1]
set minNorm [lindex $rangeNorm 0]
set maxNorm [lindex $rangeNorm 1]
set minAngle [lindex $rangeAngle 0]
set maxAngle [lindex $rangeAngle 1]

vtkContourFilter contourHead
	contourHead SetInputConnection [readerHead GetOutputPort]
	#I would expect this to be correct
	#contour GenerateValues 1 $minHead $minHead
	#but it does not work (nothing appears on the screen)
	#if I use this everything is fine
	contourHead GenerateValues 10 $minHead $maxHead

vtkLookupTable lut
	lut SetHueRange 0.0 1.0 
	#changing the saturation does not seem to be a
	#good choice for this visualization 
	#lut SetSaturationRange 1.0 0.0

vtkProbeFilter probe
	probe SetInputConnection [contourHead GetOutputPort]
	#probe SetSourceConnection [readerNorm GetOutputPort]
	probe SetSourceConnection [readerAngle GetOutputPort]

#mapper
#both mappers work

vtkPolyDataMapper mapper
#vtkDataSetMapper mapper
	mapper SetInputConnection [probe GetOutputPort]
	#mapper SetScalarRange $minNorm $maxNorm
	mapper SetScalarRange $minAngle $maxAngle
	mapper SetColorModeToMapScalars
	mapper SetLookupTable lut

#actor

vtkActor actor
	actor SetMapper mapper
	#this will bring the head in the appropriate orientation
  	actor RotateX 90
  	actor RotateZ 180

vtkScalarBarActor actorScalarBar
	actorScalarBar SetLookupTable [mapper GetLookupTable]
	#actorScalarBar SetTitle "Norm"
	actorScalarBar SetTitle "Angle"

#create the scale
#the scale allow the slider to vary from the minimum value of to the maximum

frame .f
label .f.label          -text "Visualization of the head data set"
label .f.label_scaling  -text "Scaling - adjust the isosurface value"
scale .f.scale      -from $minHead         -to     $maxHead       -orient horizontal      -command SetScale	-resolution 0.001	-length 300
button .f.quit  -text "exit"     -command exit

# "pack"ing them is what actually places them on the screen
#the order is important, the order here determines the order of appearance on the screen 

pack .f.label .f.label_scaling .f.scale .f.quit
pack .f

#procedure SetScale should change the isosurface to be drawn on the image

proc SetScale {value} {

	#we only create one isosurface with the value determined from the slider
        contourHead GenerateValues 1 [.f.scale get] [.f.scale get]
        renwin Render
}

#create the renderer

vtkRenderer ren
        ren AddActor actor
	ren AddActor actorScalarBar
	ren SetBackground 0 1 1	

#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        renwin Render
	#this creates a larger window
	renwin SetSize 512 512

#use the interactor

vtkRenderWindowInteractor iren
        iren SetRenderWindow renwin







