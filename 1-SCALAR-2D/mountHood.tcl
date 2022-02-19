##############################################
#
# Project 1
#
# visualization of mount Hood
#
# author: Christos Deligkaris
#
###############################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../vtkdata"

# read in the image

vtkPNMReader reader
	reader SetFileName $VTK_DATA/MtHood.pgm	
	#reader SetFileName $VTK_DATA/mMtHood.pgm	

#get the geometry

vtkImageDataGeometryFilter geometry
	geometry SetInputConnection [reader GetOutputPort]

#create the height fields

vtkWarpScalar warp
  	warp SetInputConnection [geometry GetOutputPort]
  	warp SetScaleFactor 0.5

# Use vtkMergeFilter to combine the original image with the warped geometry.

vtkMergeFilter merge
  	merge SetGeometryConnection [warp GetOutputPort]
  	merge SetScalarsConnection  [reader GetOutputPort]

#create the mapper

vtkDataSetMapper mapper
  	mapper SetInputConnection [merge GetOutputPort]
  	mapper SetScalarRange 0 255
  	mapper ImmediateModeRenderingOff

#create the actor

vtkActor actor
  	actor SetMapper mapper

# Create renderer stuff

vtkRenderer ren1
	ren1 AddActor actor
vtkRenderWindow renWin
    	renWin AddRenderer ren1
vtkRenderWindowInteractor iren
   	 iren SetRenderWindow renWin

renWin Render

#we do not need the widget

wm withdraw .



