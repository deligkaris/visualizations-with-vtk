##############################################
#
# Project 1
#
# visualization of the body and brain 
# data sets
#
# author: Christos Deligkaris
#
###############################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../vtkdata"

#read the data for the body
#both readers work

vtkStructuredPointsReader readerBody
#vtkDataSetReader readerBody
	readerBody SetFileName $VTK_DATA/body.vtk
	#update is required for the GetScalarRange function  
	readerBody Update

#read the data for the brain
#again, both readers work

vtkStructuredPointsReader readerBrain
#vtkDataSetReader readerBrain
	readerBrain SetFileName $VTK_DATA/brain.vtk
	#update is required for the GetScalarRange function
	readerBrain Update

#use the GetScalarRange function to find the minimum and maximum
#values of the scalar data for both data sets

set body_range [[readerBody GetOutput] GetScalarRange]
set brain_range [[readerBrain GetOutput] GetScalarRange]

#now body_range and brain_range are lists so we have to access the
#two elements of the list to get the actual values

set body_min [lindex $body_range 0]
set body_max [lindex $body_range 1]
set brain_min [lindex $brain_range 0]
set brain_max [lindex $brain_range 1]

#pass the data through the contour filter
#we create 10 contour lines

vtkContourFilter contour
  contour SetInputConnection [readerBody GetOutputPort]
  contour GenerateValues 10 $body_min $body_max

#mapper
#both mappers work

vtkPolyDataMapper mapper
#vtkDataSetMapper mapper
  mapper SetInputConnection [contour GetOutputPort]
  mapper SetScalarRange 0.0 255.0

#actor

vtkActor actor
  actor SetMapper mapper

#create the two scales and the buttons
#the two scales allow the slider to vary from the minimum value of each data set to its maximum

frame .f
label .f.label 		-text "Visualization of the body and brain data sets"
label .f.label_dataset 	-text "Choose your dataset"
label .f.label_scaling	-text "Scaling - adjust the minimum value of the contours"
scale .f.bodyscale 	-from $body_min		-to	$body_max	-orient horizontal	-command SetScale 
scale .f.brainscale 	-from $brain_min 	-to 	$brain_max	-orient horizontal	-command SetScale 
radiobutton .f.button_body 	-text "body"	-command SetActor -variable choice -value body	
radiobutton .f.button_brain 	-text "brain"	-command SetActor -variable choice -value brain
button .f.quit	-text "bye" 	-command exit

# "pack"ing them is what actually places them on the screen
#the order is important, the order here determines the order of appearance on the screen 

pack .f.label .f.label_dataset .f.button_body .f.button_brain .f.label_scaling .f.bodyscale .f.brainscale .f.quit 
pack .f

#procedure SetScale should change the contours to be drawn on the image

proc SetScale {value} {

	#these global declarations are important, this is how these variables are
	#recognized inside the function definition
	global choice
	global body_max
	global brain_max

	switch $choice {
		"body" {
			contour GenerateValues 10 [.f.bodyscale get] $body_max
			renwin Render
		}
		"brain" {
			contour GenerateValues 10 [.f.brainscale get] $brain_max
			renwin Render
		}
	}
}

#procedure SetActor should change the image to the "brain" or the "body"

proc SetActor {} {

	#again we have to declare these global variables so that they can be accessed from 
	#inside the function definition
	global choice
	global body_max
	global brain_max

	switch $choice {
      	"body" {
			contour SetInputConnection [readerBody GetOutputPort]
			#this is necessary to ensure that whenever we switch from one data set to another
			#the correct contours are drawn (in case someone changes the slider of one data set
			#while visualizing the other data set)
			contour GenerateValues 10 [.f.bodyscale get] $body_max
			ren ResetCamera
			renwin Render
            }
            "brain" {
			contour SetInputConnection [readerBrain GetOutputPort]
			contour GenerateValues 10 [.f.brainscale get] $brain_max
			ren ResetCamera
			renwin Render
            }
        }
}

#we will visualize the body data set initially

set choice "body"

#create the renderer

vtkRenderer ren
        ren AddActor actor

#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        renwin Render

#use the interactor

vtkRenderWindowInteractor iren
	iren SetRenderWindow renwin






