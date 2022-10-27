"
ShapeMorph is the direct visual representation of a ShapeMap. As a morph, it may be a component of a ShapeViewerMorph (reference kept in <gis>). The spatial data (coordinates of polygons, lines or points) are obtained from a shapefile (in <shapeMap>) and the attributes of the shapes are hold in <data>. Data are arrays (1 per shape in the shapeMap) of (immediate) values read from the DBF that is (usually) part of the ESRI shape file set.

When creating a ShapeMap in a ShapeMorph in a ShapeViewerMorph caching of its image and faster redraw is available:
			
	ShapeViewerMorph on: (ShapeMap fromFile: 'c:\esri\esridata\europe\country.shp' ) 


Structure
 shapeMap			<ShapeMap>			-- the ShapeMap containing the geo-data (coordinates of all shapes, boundingboxes, etc)
 gis					<ShapeViewerMorph|nil>	-- ShapeMorphs are often components of a ShapeViewerMorph
 data				<Array|nil>			-- the attributes of the shapes (obtained from file shapename.dbf)
 polygonColor		<Color>				-- default polygon color
 arcColor			<Color>				-- default arc color
 pointColor			<Color>				-- default point color
 dataFields			<Dictionary|nil>		-- key is the name of attribute field, value is the index of this field in the attributes-array
 legend				<ColorLegend|nil>		-- an object that translates an (attribute-)value into a color
 coloringAttrIndex	<Integer|nil>			-- the index of the attribute that is used fed into the legend


ShapeMorphs can be created by e.g. 
	ShapeMorph new shapeMap: (ShapeMap fromFile: 'd:\etarcview\giovanna\uso_corr.shp').
Before displaying aShapeMorph (.. openInWorld) it can be handed a legend (ColorLegend).

 Note that to read the dbf file the package XBase has to be present. ColorLegend is not (yet) part of the Shapes package (any object that defines e.g., 
	colorFor: anObject
		^ Color random

will do as a ColorLegend surrogate - producing random colors, of course).



"
Class {
	#name : #ShapeMorph,
	#superclass : #VectorMapMorph,
	#instVars : [
		'shapeMap',
		'data',
		'polygonColor',
		'arcColor',
		'pointColor',
		'dataFields',
		'legend',
		'coloringAttrIndex',
		'viewer'
	],
	#category : #'Shp-Morphic'
}

{ #category : #examples }
ShapeMorph class >> legend1 [
	"self legend1"
	| sh legend |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\uso_corr.shp').
	legend := (Smalltalk
				at: #ColorLegend
				ifAbsent: [^ sh openInWorld])
				mapValues: (sh valuesOfAttribute: 'CODICE')
				mixing: {Color red. Color blue}.
	legend allColorsAlpha: 0.25.
	sh legend: legend.
	sh colorAccordingToAttribute: 'CODICE'.
	^ sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> legend2 [
	"self legend2"
	| sh legend |
	
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\kippen\poultry.shp').
	legend := (Smalltalk at: #ColorLegend ifAbsent: [^sh openInWorld]) 
			mapValues: (sh valuesOfAttribute: 'DIERSRT') "hue: 32" 
			mixing: {Color red. Color blue}.
"	legend allColorsAlpha: 0.25."
	sh legend: legend.
	sh colorAccordingToAttribute: 'DIERSRT'.
	^sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> openFrom: filePath [

	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: filePath).
	^ sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> readFrom: filePath [

	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: filePath).
	^ sh
]

{ #category : #examples }
ShapeMorph class >> test1 [
	"self test1"
	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\uso_corr.shp').
	^sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> test1a [
	"self test1a"
	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\aree_protette.shp').
	^sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> test2 [
	"self test2"
	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\abarr.shp').
	^sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> test3 [
	"self test3"
	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'j:\etarcview\kippen\poultry.shp').
	^sh openInWorld
]

{ #category : #examples }
ShapeMorph class >> test4 [
	"self test4"
	| sh |
	sh := self new.
	sh shapeMap: (ShapeMap fromFile: 'C:\ESRI\ESRIDATA\mexico\states.shp').
	^sh openInWorld
]

{ #category : #'accessing - coloring' }
ShapeMorph >> arcColor: aColor [
	"set Shape-specific arc color" 

	arcColor := aColor
]

{ #category : #converting }
ShapeMorph >> asForm [
	"answer a Form with the receiver drawn on it. The whole map is projected on the Form"

	| form |
	form := Form extent: self extent depth: Display depth.
	form fillWhite.
	self drawIsolatedOn: (FormCanvas on: form).
	^ form
]

{ #category : #converting }
ShapeMorph >> asSimpleVectorLandscapeMorph [
	"answer the receiver converted into a SimpleVectorLandscapeMorph"

	"the geo-data will be contained in a SimpleVectorLandscape!"

	"(ShapeMorph new shapeMap: (ShapeMap fromFile: 'd:\etarcview\giovanna\uso_corr.shp')) asSimpleVectorLandscapeMorph "

	" needs work "
	
	| landscape instance polygons fields |
	polygons := shapeMap asSimplePolygons.	"with vertices, boundingBoxes, possible attributes (userID), etc"
	"add also the attributes contained in receiver's <data>.."
	fields := dataFields associations asArray.
	1 to: data size
		do: 
			[:i | 
			| poly atts dict |
			poly := polygons at: i.
			atts := data at: i.
			dict := poly attributes.
			fields do: [:ass | dict at: ass key put: (atts at: ass value)]].
"	landscape := SimpleVectorLandscape polygons: polygons."
	landscape boundingBox: shapeMap boundingBox.
"	instance := SimpleVectorLandscapeMorph new landscape: landscape."
	instance viewer: viewer.	"this will function as the provider of scaling & transform"
	instance legend: legend.
	^instance
]

{ #category : #'accessing - coloring' }
ShapeMorph >> colorAccordingToAttribute: aString [
	"the coloringAttrIndex defines which attribute to hand over to the legend"

	self coloringAttrIndex: (dataFields at: aString ifAbsent: [0])
]

{ #category : #'accessing - coloring' }
ShapeMorph >> coloringAttrIndex [
	"the coloringAttrIndex defines which attribute to hand over to the legend"

	^coloringAttrIndex
]

{ #category : #'accessing - coloring' }
ShapeMorph >> coloringAttrIndex: anInteger [
	"the coloringAttrIndex defines which attribute to hand over to the legend"

	coloringAttrIndex := anInteger
]

{ #category : #accessing }
ShapeMorph >> data [
	^data
]

{ #category : #accessing }
ShapeMorph >> data: aCollection [
	"put the contents of the shapefile.dbf into <data>"

	data := aCollection
]

{ #category : #accessing }
ShapeMorph >> dataFields [
	"fieldname = key; field-index (in the attributes arrays) = value"

	^dataFields
]

{ #category : #accessing }
ShapeMorph >> dataFields: aDictionary [
	"fieldname = key; field-index = value"

	dataFields := aDictionary
]

{ #category : #'initialize-release' }
ShapeMorph >> delete [
	super delete.
	shapeMap := viewer := data := nil
]

{ #category : #drawing }
ShapeMorph >> drawEmbeddedOn: aCanvas [ 
	"drawing method when receiver is a component of a ShapeGISMorph"

	"draw on the cache Form in the ShapeGISMorph in <gis>, but only if the drawing is needed"

	| canvas scaling m multiplier rect setting |
	viewer needsDrawing ifFalse: [^self].
	canvas := FormCanvas on: viewer image.
	"although aCanvas is a BalloonCanvas, the following will not work (transparency is lost somehow):
	canvas _ aCanvas asBalloonCanvas."
	setting := viewer viewSetting.	"obtain settings for projection from the gis"
	canvas aaLevel: setting aaLevel.
	scaling := setting scaling.
	"NOTE: for shapes where decimals values of the coordinates matter (small
	scale, eg hundreds), the result will be too coarse, due to truncation of 
	floating point values being done before scaling. Simple solution is 
	multiplication of the coordinates by eg 1000.0 while dividing the scale 
	by 1000.0"
	"use the transform of the GISMorph"
	m := setting transform.
	multiplier := setting multiplier.
	multiplier isNil ifTrue: [multiplier := 1.0].
	canvas transformBy: m.
	"finally, the drawing-on-canvas code; slightly different depending on shapeMap type"
	shapeMap hasPolygons 
		ifTrue: 
			[polygonColor isNil 
				ifTrue: [polygonColor := shapeMap polygonColor alpha: 0.5].
			arcColor isNil ifTrue: [arcColor := shapeMap arcColor].
			1 to: shapeMap numberOfShapes
				do: 
					[:i | 
					| contours |
					contours := shapeMap vertices2DByPartsForShapeIndex: i.
					scaling > 1.0 
						ifTrue: 
							[contours := contours 
										collect: [:each | each collect: [:point | point * multiplier]]].
					legend isNil 
						ifFalse: 
							[polygonColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
					canvas 
						drawGeneralPolygon: contours
						color: polygonColor
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ line shapes ++++++++++++++++++++++++"
	shapeMap hasLines 
		ifTrue: 
			[arcColor isNil ifTrue: [arcColor := shapeMap arcColor].
			1 to: shapeMap numberOfShapes
				do: 
					[:i | 
					| contours |
					contours := shapeMap vertices2DByPartsForShapeIndex: i.
					scaling > 1.0 
						ifTrue: 
							[contours := contours 
										collect: [:each | each collect: [:point | point * multiplier]]].
					legend isNil 
						ifFalse: [arcColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
					canvas 
						drawGeneralPolygon: contours
						color: nil
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ point shapes ++++++++++++++++++++++++"
	shapeMap hasPoints 
		ifTrue: 
			[pointColor isNil ifTrue: [pointColor := shapeMap pointColor].
			rect := (Rectangle origin: -1.0 @ -1.0 corner: 1.0 @ 1.0) scaleBy: (10 
								raisedToInteger: (1.0 / (scaling / multiplier) max: 1.0) log truncated).
			shapeMap hasMultiPoints 
				ifTrue: 
					[1 to: shapeMap numberOfShapes
						do: 
							[:i | 
							| points |
							points := self multiPointsFromShapeIndex: i.
							legend isNil 
								ifFalse: [pointColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
							scaling > 1.0 
								ifTrue: 
									[points := points collect: [:each | each * multiplier].
									points do: 
											[:point | 
											canvas 
												drawRectangle: (rect translateBy: point)
												color: pointColor
												borderWidth: 0
												borderColor: nil]]]]
				ifFalse: 
					[1 to: shapeMap numberOfShapes
						do: 
							[:i | 
							| point |
							point := shapeMap point2DFromShapeIndex: i.
							scaling > 1.0 ifTrue: [point := point * multiplier].
							legend isNil 
								ifFalse: [pointColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
							canvas 
								drawRectangle: (rect translateBy: point)
								color: pointColor
								borderWidth: 0
								borderColor: nil]]]
]

{ #category : #drawing }
ShapeMorph >> drawIsolatedOn: aCanvas [ 
	"drawing when receiver is not embedded in a ShapeGISMorph"
	| canvas geoBB scaling m multiplier xMin yMax extent rect |
	canvas := aCanvas asBalloonCanvas.
	extent := self extent.
	canvas aaLevel: 4.
	"use shapemap's boundingBox"
	geoBB := shapeMap boundingBox.
	xMin := geoBB origin x.
	yMax := geoBB corner y.
	"map the whole shapeMap on the given extent"
	scaling := extent x / geoBB extent x min: extent y / geoBB extent y.
	"NOTE: for shapes where decimals values of the coordinates matter (small
	scale, eg hundreds), the result will be too coarse, due to truncation of 
	floating point values being done before scaling. Simple solution is 
	multiplication of the coordinates by eg 1000.0 while dividing the scale 
	by 1000.0"
	"calculate the transform"
	scaling > 1.0
		ifTrue: [multiplier := 1000.0.
			m := MatrixTransform2x3 withScale: 1 @ -1 * scaling / multiplier]
		ifFalse: [multiplier := 1.0.
			m := MatrixTransform2x3 withScale: 1 @ -1 * scaling].
	m offset: xMin negated @ yMax * scaling + self innerBounds origin.
	canvas transformBy: m.
	"finally, the drawing-on-canvas code; slightly different depending on
	shapeMap type"
	shapeMap hasPolygons
		ifTrue: [polygonColor isNil
				ifTrue: [polygonColor := shapeMap polygonColor alpha: 0.5].
			arcColor isNil
				ifTrue: [arcColor := shapeMap arcColor].
			1
				to: shapeMap numberOfShapes
				do: [:i | 
					| contours | 
					contours := shapeMap vertices2DByPartsForShapeIndex: i.
					scaling > 1.0
						ifTrue: [contours := contours
										collect: [:each | each
												collect: [:point | point * multiplier]]].
					legend isNil ifFalse: [polygonColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
					canvas
						drawGeneralPolygon: contours
						color: polygonColor
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ line shapes ++++++++++++++++++++++++"
	shapeMap hasLines
		ifTrue: [arcColor isNil
				ifTrue: [arcColor := shapeMap arcColor].
			1
				to: shapeMap numberOfShapes
				do: [:i | 
					| contours | 
					contours := shapeMap vertices2DByPartsForShapeIndex: i.
					scaling > 1.0
						ifTrue: [contours := contours
										collect: [:each | each
												collect: [:point | point * multiplier]]].
					legend isNil ifFalse: [arcColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
					canvas
						drawGeneralPolygon: contours
						color: nil
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ point shapes ++++++++++++++++++++++++"
	shapeMap hasPoints
		ifTrue: [pointColor isNil ifTrue: [pointColor := shapeMap pointColor].
			rect := (Rectangle origin: -1.0 @ -1.0 corner: 1.0 @ 1.0)
						scaleBy: (10 raisedToInteger: (1.0 / (scaling / multiplier) max: 1.0) log truncated).
			shapeMap hasMultiPoints
				ifTrue: [1
						to: shapeMap numberOfShapes
						do: [:i | 
							| points | 
							points := self multiPointsFromShapeIndex: i.
							legend isNil ifFalse: [pointColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
							scaling > 1.0
								ifTrue: [points := points
												collect: [:each | each * multiplier].
									points
										do: [:point | canvas
												drawRectangle: (rect translateBy: point)
												color: pointColor
												borderWidth: 0
												borderColor: nil]]]]
				ifFalse: [1
						to: shapeMap numberOfShapes
						do: [:i | 
							| point | 
							point := shapeMap point2DFromShapeIndex: i.
							scaling > 1.0
								ifTrue: [point := point * multiplier].
							legend isNil ifFalse: [pointColor := legend colorFor: ((data at: i) at: coloringAttrIndex)].
							canvas
								drawRectangle: (rect translateBy: point)
								color: pointColor
								borderWidth: 0
								borderColor: nil]]]
]

{ #category : #drawing }
ShapeMorph >> drawOn: aCanvas [ 
	viewer isNil 
		ifTrue: [^self drawIsolatedOn: aCanvas]
		ifFalse: [^self drawEmbeddedOn: aCanvas]
]

{ #category : #accessing }
ShapeMorph >> geoBoundingBox [
	"that is determined by the shapefile"

	^shapeMap boundingBox
]

{ #category : #'data queries' }
ShapeMorph >> indexOfAttribute: aString [ 
	"answer the index of attribute named aString"

	^dataFields at: aString ifAbsent: [0]
]

{ #category : #'initialize-release' }
ShapeMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self extent: 500 @ 500
]

{ #category : #accessing }
ShapeMorph >> landscape: aShapeLandscape attributes: aCollection [
]

{ #category : #accessing }
ShapeMorph >> legend: aColorLegend [
	"use aColorLegend to display the shapes"
	"for non-random coloring define also the coloringAttrIndex"

	legend := aColorLegend
]

{ #category : #'accessing - coloring' }
ShapeMorph >> pointColor: aColor [
	"set Shape-specific point color" 

	pointColor := aColor
]

{ #category : #'accessing - coloring' }
ShapeMorph >> polygonColor: aColor [
	"set Shape-specific polygon color" 

	polygonColor := aColor
]

{ #category : #'editable polygons' }
ShapeMorph >> removePolygonsAsPolygonMorphs [
	"delete all submorphs!" 
	
	submorphs do:  [:each | each delete]
]

{ #category : #accessing }
ShapeMorph >> shapeMap [
	"answer the ShapeMap holding the geo-data" 

	^shapeMap
]

{ #category : #accessing }
ShapeMorph >> shapeMap: aShapeMap [
	"load the map, read also the accompanying DBF with attributes"
	| dataAndFields fields dict |

	shapeMap := aShapeMap.
	shapeMap label isNil ifTrue: [^self].	"no label, probably a handmade file...."
	dataAndFields := (XBaseFile recordsAndFieldsFromFile: shapeMap label , '.dbf').
	self data: (dataAndFields copyFrom: 1 to: dataAndFields size - 1).
	fields := dataAndFields last.
	dict := Dictionary new: fields size.
	"shape dbf's may have duplicate fields. Make sure we only use the first!"
	1 to: fields size do: [: i | dict at: (fields at: i) ifAbsentPut: [ i ] ].
	self dataFields: dict
]

{ #category : #selection }
ShapeMorph >> shapesWithAttributes [
	"answer the vertices, the attributes, the boundingBoxes AND the indices
	of all shapes!"
	| shapes attributes bBoxes indices n |
	n := shapeMap numberOfShapes.
	shapes := OrderedCollection new: n.
	attributes := OrderedCollection new: n.
	bBoxes := OrderedCollection new: n.
	indices := OrderedCollection new: n.
	1
		to: n
		do: [:i | 
			shapes
				addLast: (shapeMap verticesByPartsForShapeIndex: i).
			attributes
				addLast: (data at: i).
			bBoxes
				addLast: (shapeMap boundingBoxForShapeIndex: i).
			indices addLast: i].
	^ Array
		with: shapes
		with: attributes
		with: bBoxes
		with: indices
]

{ #category : #selection }
ShapeMorph >> shapesWithAttributesSatisfying: aBlock [ 
	"iterate over the shapes & attributes and answer a selection for
	which a block (with the attributes as argument) evaluates to true"
	"answer the vertices, the attributes, the boundingBoxes AND the indices!"
	"self shapesWithAttributeSatisfying: [:attrs | (attrs at: 6) = 312] "

	| shapes attributes bBoxes indices |
	shapes := OrderedCollection new: 100.
	attributes := OrderedCollection new: 100.
	bBoxes := OrderedCollection new: 100.
	indices := OrderedCollection new: 100.
	1
		to: shapeMap numberOfShapes
		do: [:i | (aBlock
					value: (data at: i))
				ifTrue: [shapes
						addLast: (shapeMap verticesByPartsForShapeIndex: i).
					attributes
						addLast: (data at: i).
					bBoxes addLast: (shapeMap boundingBoxForShapeIndex: i).
					indices addLast: i]].
	^ Array with: shapes with: attributes with: bBoxes with: indices
]

{ #category : #'data queries' }
ShapeMorph >> valuesOfAttribute: aString [
	"answer an array with the unique values of attribute aString"
	| index set |
	data isNil ifTrue: [^#()].
	index := dataFields at: aString ifAbsent: [0].
	index > 0 ifFalse: [^#()].
	set := Set new: 100.
	data do: [:each | set add: (each at: index)].
	^set asSortedCollection asArray
]

{ #category : #accessing }
ShapeMorph >> viewer [
	"answer the Morph the receiver gets scaling & transform from"

	^viewer
]

{ #category : #accessing }
ShapeMorph >> viewer: aShapeViewerMorph [ 
	"set the Morph receiver gets its scaling & transform from"

	viewer := aShapeViewerMorph
]

{ #category : #'editable polygons' }
ShapeMorph >> withPolygonsAsPolygonMorphs [
	"convert receiver's polygons into individual PolygonMorphs. Add these as submorphs!" 

	" needs work "
	
	| polys c bw bc |
	polys := shapeMap asSimplePolygons.
	c := Color blue. bw := 1. bc := Color red.
"	transf := viewer transform."
	polys do: [:each | | bpm | 
"		bpm := BasicPolygonMorph2 polygonElement: each color: c borderWidth: bw borderColor: bc. "
		bpm viewer: viewer.
		self addMorph: bpm]
]
