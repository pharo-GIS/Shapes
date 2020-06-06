"
ShapeEnsemble contains both the shape file (with extension SHP) and the dbf file (with extension DBF). Information from the dbf can be used to color the map. Define a legend and the attribute to be used in the legend. Note that the ColorLegend and XBase packages are required then....

Structure:
 shape		ShapeMap -- comment about the purpose of instVar1
 data		DBF -- comment about the purpose of instVar2
 legend		ColorLegend -- comment about the purpose of instVar2
 attribute	String -- comment about the purpose of instVar2


Useful expressions:

	shown on Display: 
	| shpE |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	shpE legend: ( ColorLegend mappedFrom: 0 step: 1000000 n: 20 hue: (Color red hue)).
	shpE attribute: 'POP1991'.
	^shpE display 

	show in an ImageMorph:
	| shpE legend |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	legend := ColorLegend mapValuesToRandom: (shpE valuesOfAttribute: 'CODE').
	shpE legend: legend.
	shpE attribute: 'CODE'.
	^shpE displayMorphic	
"
Class {
	#name : #ShapeEnsemble,
	#superclass : #Object,
	#instVars : [
		'shape',
		'data',
		'legend',
		'attribute'
	],
	#category : #'Shapes-Base'
}

{ #category : #examples }
ShapeEnsemble class >> display1 [
	"self display1"
	| shpE |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	shpE legend: ( ColorLegend mappedFrom: 0 step: 1000000 n: 20 hue: (Color red hue)).
	shpE attribute: 'POP1991'.
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> display2 [
	"self display2"

	| shpE legend |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	shpE attribute: 'CODE'.
	legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
	shpE legend: legend.
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> display3 [
	"self display3"

	| shpE legend |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	shpE attribute: 'CODE'.
	legend := ColorLegend mapValues: shpE valuesOfCurrentAttribute
				mixing: { (Color red). (Color blue) }.
	legend allColorsAlpha: 0.1.
	shpE legend: legend.
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> display4 [
	"self display4"

	| shpE legend |
	shpE := ShapeEnsemble fromFile: 'j:\etarcview\3D\poultry3D.shp'.
	shpE attribute: 'DIERSRT'.
	legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
	shpE legend: legend.
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> display5 [
	"self display5"

	| shpE legend |
	shpE := ShapeEnsemble 
				fromFile: 'j:\etarcview\bushcricket\withET_CLASS\SmallSteps_B-HOE.shp'.
	shpE attribute: 'HabitatTyp'.
	legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
	shpE legend: legend.
	"legend storeOnFile."
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> display6 [
	"self display6"

	| shpE legend |
	shpE := ShapeEnsemble 
				fromFile: 'j:\etarcview\bushcricket\withET_CLASS\SmallSteps_B-HOE.shp'.
	shpE attribute: 'ET_CLASS'.
	legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
	shpE legend: legend.
"	legend storeOnFile."
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> displayNoLegend [
	"self displayNoLegend"
	| shpE |
	shpE := ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp'.
	shpE attribute: 'POP1991'.
	^shpE displayMorphic
]

{ #category : #examples }
ShapeEnsemble class >> displayNoLegend2 [
	"self displayNoLegend2"

	| shpE |
	shpE := ShapeEnsemble fromFile: 'j:\etarcview\bushcricket\withET_CLASS\SmallSteps_B-HOE.shp'.
	shpE attribute: 'HabitatTyp'.
	^shpE displayMorphic
]

{ #category : #'instance creation' }
ShapeEnsemble class >> fromFile: aStringOrFileReference [
	"ShapeEnsemble fromFile: 'c:\esri\esridata\CANADA\province.shp' "

	^ self new 
		shape: (ShapeMap fromFile: aStringOrFileReference)
		data: (self readDBFFromFile: aStringOrFileReference)
]

{ #category : #accessing }
ShapeEnsemble class >> readDBFFromFile: aFileReference [ 

	^ DBF on: (aFileReference withExtension: 'dbf') asFileReference fullName
]

{ #category : #converting }
ShapeEnsemble >> asForm [
	"answer a Form with the receiver drawn on it. The whole map is projected on the Form"

	| form |
	form := Form extent: shape preferredFormExtent depth: Display depth.
	form fillWhite.
	self setColorsFromLegend.
	shape drawOn: (BalloonCanvas on: form).
	^form
]

{ #category : #accessing }
ShapeEnsemble >> attribute: aString [
	"the attribute whose values are used by the legend"

	attribute := aString
]

{ #category : #accessing }
ShapeEnsemble >> dataAtCurrentAttribute [
	"answer an Array with all the values for field referred to by attribute"

	^data contentsAtField: attribute
]

{ #category : #accessing }
ShapeEnsemble >> dataAtField: aString [
	"answer an Array with all the values for field named aString"

	^data contentsAtField: aString
]

{ #category : #accessing }
ShapeEnsemble >> dataFields [
	"data fields in the DBF"

	^data fields
]

{ #category : #accessing }
ShapeEnsemble >> dataRecords [
	"answer all the records in the DBF file, extracted from the bytes-stream"

	^data contents
]

{ #category : #displaying }
ShapeEnsemble >> display [
	"show on the Display"

	^self asForm displayOn: Display
]

{ #category : #displaying }
ShapeEnsemble >> displayMorphic [
	"open an ImageMorph with the receiver as an image"

	^(ImageMorph new image: self asForm) openInWorld
]

{ #category : #displaying }
ShapeEnsemble >> drawOn: aCanvas [
	
	self setColorsFromLegend.
	shape drawOn: aCanvas
]

{ #category : #accessing }
ShapeEnsemble >> gtInspectorMorphIn: composite [
	<gtInspectorPresentationOrder: 90>  
	| morphPresentation |
	morphPresentation := composite morph.
	morphPresentation 
		title: 'View';
		display: [ :each |
			ImageMorph new image: self asForm];
		act: [ :pres | self exportAsPNG ] entitled: 'Export as PNG';
		act: [ :pres | self delete ] entitled: 'Delete'
]

{ #category : #'accessing - legend' }
ShapeEnsemble >> legend: aLegend [
	"use a predefined legend"
	legend := aLegend
]

{ #category : #displaying }
ShapeEnsemble >> reasonableColorLegend [
	^(Smalltalk at: #ColorLegend ifAbsent: [^nil]) 
		reasonableLegendForValues: (self dataAtField: attribute)
]

{ #category : #displaying }
ShapeEnsemble >> reasonableColorLegendFor: aCollection [
	^(Smalltalk at: #ColorLegend ifAbsent: [^nil]) 
		reasonableLegendForValues: aCollection
]

{ #category : #'accessing - legend' }
ShapeEnsemble >> setColorMixLegendForAttribute: aString [ 
	attribute := aString.
	legend := ColorLegend mapValues: self valuesOfCurrentAttribute
				mixing: { (Color red). (Color blue) }
]

{ #category : #displaying }
ShapeEnsemble >> setColorsFromLegend [
	"fill the color array of the shape with colors determined by the Legend (and the selected attribute)"

	"if there is no ColorLegend defined, ask the ColorLegend for one"

	| values |
	legend isNil 
		ifTrue: 
			[values := self dataAtField: attribute.
			legend := self reasonableColorLegendFor: values.
			legend isNil ifTrue: [^self]].
	values isNil ifTrue: [values := self dataAtField: attribute].	"avoid going twice over the data values"
	shape colors: (legend colorForAll: values)
]

{ #category : #'accessing - legend' }
ShapeEnsemble >> setRandomColorLegendForAttribute: aString [ 
	attribute := aString.
	legend := ColorLegend mapValuesToRandom: self valuesOfCurrentAttribute
]

{ #category : #accessing }
ShapeEnsemble >> shape [
	"answer the ShapeMap wrapped in the receiver"

	^shape
]

{ #category : #accessing }
ShapeEnsemble >> shape: aShapeMap data: aDBF [

	shape := aShapeMap.
	data := aDBF
]

{ #category : #accessing }
ShapeEnsemble >> shapeRecords [
	"answer all the shapes in the shape file (extracted from the bytes)"

	^shape shapes
]

{ #category : #accessing }
ShapeEnsemble >> valuesOfAttribute: aString [
	"answer an array with the unique values of attribute aString"

	^(self dataAtField: aString) asSet asSortedCollection asArray
]

{ #category : #accessing }
ShapeEnsemble >> valuesOfCurrentAttribute [
	"answer an array with the unique values of attribute aString"

	attribute isNil ifTrue: [^#()].
	^(self dataAtField: attribute) asSet asSortedCollection asArray
]
