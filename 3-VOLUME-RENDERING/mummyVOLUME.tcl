#############################################################
#
# Project 3
#
# author: Christos Deligkaris
#
# this creates the volume rendering of the mummy data set 
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

# Create transfer mapping scalar value to opacity
vtkPiecewiseFunction opacityTransferFunction
    	opacityTransferFunction AddPoint  40   0.0
    	opacityTransferFunction AddPoint  55   0.07
    	opacityTransferFunction AddPoint  80   0.07
    	opacityTransferFunction AddPoint  90   0.07
    	opacityTransferFunction AddPoint 100   0.1
    	opacityTransferFunction AddPoint 110   0.8
    	opacityTransferFunction AddPoint 240   1.

# Create transfer mapping scalar value to color
vtkColorTransferFunction colorTransferFunction
	colorTransferFunction AddHSVPoint  30.0 0.0 0.0 0.0
    	colorTransferFunction AddHSVPoint  60.0 0.05 0.5 0.4
    	colorTransferFunction AddHSVPoint 110.0 0.05 0.5 0.4
    	colorTransferFunction AddHSVPoint 120.0 0.0 0.0 1.0
    	colorTransferFunction AddHSVPoint 220.0 0.0 0.0 1.0

# The property describes how the data will look
vtkVolumeProperty volumeProperty
    	volumeProperty SetColor colorTransferFunction
	volumeProperty SetScalarOpacity opacityTransferFunction
	#choose an interpolation method, default is nearest neighbor
	#for best results use trilinear interpolation
	volumeProperty SetInterpolationTypeToLinear
	#volumeProperty SetInterpolationTypeToNearest


# The mapper / ray cast function know how to render the data
vtkVolumeRayCastCompositeFunction  compositeFunction

vtkVolumeRayCastMapper volumeMapper
    	volumeMapper SetVolumeRayCastFunction compositeFunction
    	volumeMapper SetInputConnection [reader GetOutputPort]
	#change the sample distance
	volumeMapper SetSampleDistance 0.05

# The volume holds the mapper and the property and
# can be used to position/orient the volume
vtkVolume volume
    	volume SetMapper volumeMapper
    	volume SetProperty volumeProperty
	#bring the head in the appropriate orientation
	volume RotateX -90
	#volume RotateZ 60

#create the renderer

vtkRenderer ren
        ren AddVolume volume
	#ren SetBackground 1 1 1
	#zoom into the scene
	ren ResetCamera
	[ren GetActiveCamera] Zoom 1.8
	
#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        #this creates a larger window
        renwin SetSize 512 512

#use the interactor

vtkRenderWindowInteractor iren
        iren SetRenderWindow renwin

#render after we add the interactor
	renwin Render

#we do not need the Tk widget

wm withdraw .




