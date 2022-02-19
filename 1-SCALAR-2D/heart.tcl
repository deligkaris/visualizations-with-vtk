##############################################
#
# Project 1
#
# visualization of the electric field, epicardium
# and chest data sets
#
# author: Christos Deligkaris
#
###############################################

package require vtk
package require vtkinteraction
package require vtktesting

set VTK_DATA "../vtkdata"

# the PolyDataReader might not work so we can use the more 
#general reader DataSetReader in that case

#vtkPolyDataReader readerSamples
vtkDataSetReader readerSamples
	readerSamples SetFileName $VTK_DATA/samples.vtk

#both Chest.vtk and Epicardium.vtk are of Unstructured Grids DataSet
#we can use both readers to read our data

vtkUnstructuredGridReader readerEpicardium
#vtkDataSetReader readerEpicardium
	readerEpicardium SetFileName $VTK_DATA/epicardium.vtk

vtkUnstructuredGridReader readerChest
#vtkDataSetReader readerChest
        readerChest SetFileName $VTK_DATA/chest.vtk

#since there is no connectivity information we have to create a mesh
#with the Delaunay triangulation method

vtkDelaunay2D delSamples
	delSamples SetInputConnection [readerSamples GetOutputPort]

#the data for Chest and Epicardium already have connectivity information
#so there is no need to create a mesh for them

#create the height field 

vtkWarpScalar warp
	warp SetInputConnection [delSamples GetOutputPort]
	#with the scale factor you can make the height field smaller or larger
	#you do not want the height field to be too small or too large
	#in our case 3 seems to be a good choice   
	warp SetScaleFactor 3.

# We will now create a nice looking mesh by wrapping the edges in tubes,
# and putting fat spheres at the points.
# This is how we will visualize the chest 
vtkExtractEdges extract
	extract SetInputConnection [readerChest GetOutputPort]
#the radius determines how big the tubes for the visualization of the chest are
#we do not really care about the number of tube sides
vtkTubeFilter tubesChest
	tubesChest SetInputConnection [extract GetOutputPort]
	tubesChest SetRadius 0.3	
     	tubesChest SetNumberOfSides 6	

#create all the appropriate mappers

vtkDataSetMapper mapperChest
        mapperChest SetInputConnection [tubesChest GetOutputPort]

vtkDataSetMapper mapperSamples
	mapperSamples SetInputConnection [warp GetOutputPort]

vtkDataSetMapper mapperEpicardium
        mapperEpicardium SetInputConnection [readerEpicardium GetOutputPort]

#create all the appropriate actors

vtkActor actorSamples
	actorSamples SetMapper mapperSamples

vtkActor actorChest
        actorChest SetMapper mapperChest

vtkActor actorEpicardium
        actorEpicardium SetMapper mapperEpicardium

#create the renderer and add all the actors on the screen

vtkRenderer ren
	ren AddActor actorSamples
	ren AddActor actorChest
	ren AddActor actorEpicardium

#create the render window

vtkRenderWindow renwin
	renwin AddRenderer ren
	renwin Render

#include the interactor

vtkRenderWindowInteractor iren
	iren SetRenderWindow renwin

# we do not need the widget

wm withdraw .


