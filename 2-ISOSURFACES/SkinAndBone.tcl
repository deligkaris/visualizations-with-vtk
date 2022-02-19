#############################################################
#
# Project 2
#
# author: Christos Deligkaris
#
# display two isosurfaces together, one for skin and one
# for the bone
#
#############################################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../data"

vtkStructuredPointsReader reader
	reader SetFileName $VTK_DATA/head.60.vtk

#this is the lookup table for the skin

vtkLookupTable lutSkin
	#set the skin to be transparent
	lutSkin SetAlphaRange 0.5 0.5
	#this will create a nice human color
	lutSkin SetHueRange 0.1 0.1
	lutSkin SetSaturationRange 0.5 0.5
	lutSkin SetValueRange 1. 1.
	#not sure if we need this
	lutSkin Build

#this is the lookup table for the bone

vtkLookupTable lutBone
	#set the bone to be opaque
	lutBone SetAlphaRange 1.0 1.0
	#this will create a nice bone color
	lutBone SetHueRange 0.0 0.0
	lutBone SetSaturationRange 0.0 0.0
	lutBone SetValueRange 0.8 0.8
	#not sure if we need this
	#lutBone Build
	
#this is the isosurface for the skin

vtkContourFilter contourSkin
	contourSkin SetInputConnection [reader GetOutputPort]
	#to show the skin the isosurface value of 26 seems to be fine
	#use either of the following
	contourSkin GenerateValues 1 26.0 26.0
	#contourSkin SetNumberOfContours 1
	#contourSkin SetValue 0 26.0

#the isosurface for the bone

vtkContourFilter contourBone
        contourBone SetInputConnection [reader GetOutputPort]
	#to show the bone the isosurface value of 72 seems to be fine
        #use either of the following
        contourBone GenerateValues 1 72.0 72.0
        #contourBone SetNumberOfContours 1
        #contourBone SetValue 0 72.0

#mappers
#both mappers work

vtkPolyDataMapper mapperSkin
#vtkDataSetMapper mapperSkin
	mapperSkin SetInputConnection [contourSkin GetOutputPort]
	mapperSkin SetScalarRange 0.0 255.0
	mapperSkin SetLookupTable lutSkin

vtkPolyDataMapper mapperBone
#vtkDataSetMapper mapperBone
	mapperBone SetInputConnection [contourBone GetOutputPort]
	mapperBone SetScalarRange 0.0 255.0
	mapperBone SetLookupTable lutBone

#actors

vtkActor actorSkin
	actorSkin SetMapper mapperSkin
  	#this will bring the head in the appropriate orientation
  	actorSkin RotateX 90
  	actorSkin RotateZ 180

vtkActor actorBone
  	actorBone SetMapper mapperBone
  	#this will bring the head in the appropriate orientation
  	actorBone RotateX 90
  	actorBone RotateZ 180

#create the renderer

vtkRenderer ren
        ren AddActor actorSkin
	ren AddActor actorBone

#create the renderer window

vtkRenderWindow renwin
        renwin AddRenderer ren
        renwin Render
	#this will create a larger window
	renwin SetSize 512 512

#use the interactor

vtkRenderWindowInteractor iren
        iren SetRenderWindow renwin

#we do not need the Tk widget

wm withdraw .







