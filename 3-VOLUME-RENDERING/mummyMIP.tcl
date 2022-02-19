#############################################################
#
# Project 3
#
# author: Christos Deligkaris
#
# this code creates the MIP of the mummy data set 
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
	opacityTransferFunction AddPoint  10   0.
	opacityTransferFunction AddPoint  20   0.1
    	opacityTransferFunction AddPoint  40   0.2
    	opacityTransferFunction AddPoint  55   0.3
    	opacityTransferFunction AddPoint  70   0.4
    	opacityTransferFunction AddPoint  90   0.4
    	opacityTransferFunction AddPoint 100   0.5
    	opacityTransferFunction AddPoint 110   0.6
	opacityTransferFunction AddPoint 140   0.8
    	opacityTransferFunction AddPoint 240   1.

# Create transfer mapping scalar value to color
vtkColorTransferFunction colorTransferFunction
	colorTransferFunction AddHSVPoint  10.0 0.0 0. 0.
	colorTransferFunction AddHSVPoint  20.0 0.05 0.5 0.2
	colorTransferFunction AddHSVPoint  40.0 0.05 0.5 0.3
    	colorTransferFunction AddHSVPoint  60.0 0.05 0.5 0.5
    	colorTransferFunction AddHSVPoint 110.0 0.05 0.5 0.6
    	colorTransferFunction AddHSVPoint 120.0 0.0 0.0 0.7
    	colorTransferFunction AddHSVPoint 220.0 0.0 0.0 0.9

# The property describes how the data will look
vtkVolumeProperty volumeProperty
    	volumeProperty SetColor colorTransferFunction
	volumeProperty SetScalarOpacity opacityTransferFunction
	#with this we can change the interpolation method: trilinear or nearest neighbor
	#default is nearest neighbor
	volumeProperty SetInterpolationTypeToLinear
	#volumeProperty SetInterpolationTypeToNearest


# The mapper / ray cast function know how to render the data
vtkVolumeRayCastMIPFunction MIPFunction
	#MIPFunction SetMaximizeMethodToScalarValue
	#MIPFunction SetMaximizeMethodToOpacity

vtkVolumeRayCastMapper volumeMapper
    	volumeMapper SetVolumeRayCastFunction MIPFunction
    	volumeMapper SetInputConnection [reader GetOutputPort]
	#this can be used to change the distance
	volumeMapper SetSampleDistance 0.2

# The volume holds the mapper and the property and
# can be used to position/orient the volume
vtkVolume volume
    	volume SetMapper volumeMapper
    	volume SetProperty volumeProperty
	#we need to rotate the volume 
	volume RotateX -90
	volume RotateZ 60

#create the renderer

vtkRenderer ren
        ren AddVolume volume
	#ren SetBackground 1 1 1
	#we want to zoom into the scene
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




