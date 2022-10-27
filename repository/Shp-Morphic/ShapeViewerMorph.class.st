"
ShapeViewerMorph's purpose is to display a bunch of ShapeMorphs (or other morphs with a vector-based representation of a map) on top of each other. This mainly involves keeping the right scaling & transform. 
ShapeMorphs contained in <submorphs> are actually visible; all ShapeMorphs (also when not visible) are contained in <maps>. ShapeViewerMorph includes some general GIS functionality that could be transferred to a GIS-representing object (later...)

Structure:
 maps				<OrderedCollection>		-- with the ShapeMorphs
 aaLevel			<Integer>				-- the level of anti-aliasing
 geoOffset			<Point>					-- the geographical topLeft coordinate of the displayed map (minX @ maxY)
 transform			<MatrixTransform2x3>	-- to transform geographic coordinates to screen coordinates
 scaling				<Number>				-- the scaling factor (from geographic to screen units)
 multiplier			<Number|nil>				-- multiply coordinates with multiplier, when geographic range is too small
 image 				<Form>					-- the cached image of the submorphs
 drawingsNeeded	<Boolean>				-- true when the cached image needs to be recreated



ShapeViewerMorph new openInWorld   -> an empty ShapeViewerMorph
ShapeViewerMorph on: (ShapeMap fromFile: 'c:\esri\esridata\europe\country.shp' )  (provide the path to the shapename.shp file)
see instance creation protocol

self example2.
self example1.

"
Class {
	#name : #ShapeViewerMorph,
	#superclass : #Morph,
	#instVars : [
		'maps',
		'aaLevel',
		'geoOffset',
		'transform',
		'scaling',
		'multiplier',
		'image',
		'drawingsNeeded',
		'viewSetting'
	],
	#category : #'Shp-Morphic'
}

{ #category : #examples }
ShapeViewerMorph class >> example1 [
	"open aShapeViewerMorph combining two PointShapes. Points are coloured differently"

	| shpM1 shpM2 |
	shpM1 := ShapeMorph new shapeMap: (ShapeMap fromFile: 'D:\ETshapes\giabvarkenslbt2001\giabvarkenslbt2001.shp').
	shpM2 := ShapeMorph new shapeMap: (ShapeMap fromFile: 'D:\ETshapes\poultry\poultry.shp').
	shpM1 pointColor: Color blue.
	shpM2 pointColor: Color orange.
	self onAllShapeMorphs: (Array with: shpM1 with: shpM2).
]

{ #category : #examples }
ShapeViewerMorph class >> example2 [
	"open aShapeViewerMorph combining two PolygonShapes. Polygons are coloured differently"

	| shpM1 shpM2 |
	shpM1 := ShapeMorph new shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\uso_corr.shp').
	shpM2 := ShapeMorph new shapeMap: (ShapeMap fromFile: 'j:\etarcview\giovanna\aree_protette.shp').
	shpM1 polygonColor: (Color blue lighter lighter alpha: 0.5).
	shpM2 polygonColor: (Color red lighter lighter alpha: 0.5).
	self onAllShapeMorphs: (Array with: shpM1 with: shpM2)
]

{ #category : #'instance creation' }
ShapeViewerMorph class >> on: aShapeMap [
	"open a ShapeViewerMorph with a single ShapeMorph created from aShapeMap" 

	^(self new onShape: aShapeMap) openInWorld
]

{ #category : #'instance creation' }
ShapeViewerMorph class >> onAll: aCollection [
	"open a ShapeViewerMorph with ShapeMorphs created from each ShapeMap in aCollection"
 
	| instance |
	instance := self new.
	instance onShapes: aCollection.
	instance openInWorld
]

{ #category : #'instance creation' }
ShapeViewerMorph class >> onAllShapeMorphs: aCollection [
	"open a ShapeViewerMorph with submorphs all ShapeMorphs in aCollection" 

	| instance |
	instance := self new.
	instance onShapeMorphs: aCollection.
	instance openInWorld
]

{ #category : #'instance creation' }
ShapeViewerMorph class >> onShapeMorph: aShapeMorph [
	"make a ShapeViewerMorph with a single submorph aShapeMorph. Dont open it yet" 

	^ self new onShapeMorph: aShapeMorph
]

{ #category : #'instance creation' }
ShapeViewerMorph class >> openOnShapeMorph: aShapeMorph [
	"open a ShapeViewerMorph with a single submorph aShapeMorph" 

	^ (self onShapeMorph: aShapeMorph) openInWorld
]

{ #category : #accessing }
ShapeViewerMorph >> aaLevel [
	"answer the level of anti-aliasing"

	^aaLevel
]

{ #category : #menus }
ShapeViewerMorph >> addItemsToMenu: menu [
	menu add: 'set scaling' action: #setUserScaling.
	menu addLine.
	menu add: 'explore' action: #explore
]

{ #category : #accessing }
ShapeViewerMorph >> addShapeMorph: aMorph [
	"add aShapeMorph, or a ShapeLandscapeMorph or a SimpleVectorLandscapeMorph"

	maps addLast: aMorph.
	self addMorphFront: aMorph
]

{ #category : #'halos and balloon help' }
ShapeViewerMorph >> balloon [
	"add some sensible balloon info here"

	^ self showBalloon: self printString
]

{ #category : #private }
ShapeViewerMorph >> cacheReady [
	"submorphs have been drawn on the cached image"
	drawingsNeeded := false

]

{ #category : #'event handling' }
ShapeViewerMorph >> click: evt [
	"not needed anymore (menu pops up via #mouseDown:) "

	| menu |

	" needs work "
	evt yellowButtonPressed ifFalse: [^self].
	menu := MenuMorph new defaultTarget: self.
	self addItemsToMenu: menu.
	menu popUpEvent: evt in: self world

]

{ #category : #initialization }
ShapeViewerMorph >> defaultBounds [
	^0@0 corner: 550@550
]

{ #category : #initialization }
ShapeViewerMorph >> delete [
	super delete.
	(maps isNil or: [maps isEmpty]) ifFalse: [maps do: [:each | each delete]].
	maps := nil
	
]

{ #category : #drawing }
ShapeViewerMorph >> drawOn: aCanvas [ 
	"adjust the MatrixTransform2x3 in <transform>. Maps are drawn via the
	drawOn: in ShapeMorph"

	"prepare a cached image, if necessary"

	| canvas |
	submorphs isEmpty ifTrue: [^super drawOn: aCanvas].
	self needsToResetCachedImage 
		ifTrue: 
			[viewSetting isNil ifTrue: [self updateViewSetting].
			self invalidateCache. 
			image := Form extent: self innerBounds extent depth: Display depth.
			image fillWhite.
			canvas := FormCanvas on: image.
			submorphs 
				reverseDo: [:each | each isVectorMapMorph ifTrue: [each drawOn: canvas]].
			"the reverseDo: is there only because thats the default order"
			self cacheReady].
	aCanvas paintImage: image at: self innerBounds origin
]

{ #category : #geometry }
ShapeViewerMorph >> extent: aPoint [

	bounds extent = aPoint ifTrue: [^ self]. 
	"self changed. why?"
	bounds := (bounds topLeft extent: aPoint) rounded.

	self setInitialScaling.	"scaling based on receivers extent & map geo extent"
	self viewSetting: nil.	"otherwise #drawOn: will not use an updated transform"
	self invalidateCache.

	self layoutChanged.
	self changed.


]

{ #category : #'accessing - layers' }
ShapeViewerMorph >> firstMap [
	^ maps isEmpty ifTrue: [^nil] ifFalse: [maps first]
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> flushSetting [
	"refresh the projection parameters from the contents of <viewSetting> "

	aaLevel 	:= viewSetting aaLevel.
	scaling		:= viewSetting scaling.
	transform	:= viewSetting transform.
	multiplier	:= viewSetting multiplier.
	geoOffset	:= viewSetting geoOffset
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> gisViewSetting [
	"create a new aGISViewSetting with all relevant scaling & transformation parameters"

	^GISViewSetting new aaLevel: aaLevel scaling: scaling transform: transform multiplier: multiplier geoOffset: geoOffset
]

{ #category : #'event handling' }
ShapeViewerMorph >> handlesMouseDown: evt [
	"set this to true if you want a right-mousebutton menu"

	^ true
]

{ #category : #private }
ShapeViewerMorph >> image [
	"answer the cached Form"

	^image
]

{ #category : #initialization }
ShapeViewerMorph >> initialize [
	super initialize.
"	self extent: 550@550."
	self color: (Color "gray"white" alpha: 0.5").
	aaLevel := 4.
	maps := OrderedCollection new.
	self clipSubmorphs: true
	
]

{ #category : #private }
ShapeViewerMorph >> invalidateCache [
	"force redrawing the submorphs on the cached image" 
	image := nil.
	drawingsNeeded := true

]

{ #category : #accessing }
ShapeViewerMorph >> maps [
	"answer the collection of ShapeMorphs the receiver holds" 
	
	^maps
]

{ #category : #'event handling' }
ShapeViewerMorph >> mouseDown: evt [
	"Do nothing upon mouse-down except inform the hand to watch for a double-click; wait until an ensuing click:, doubleClick:, or drag: message gets dispatched"

	| menu |
	evt yellowButtonPressed
				ifFalse: [self balloon]
"---------------------------------------------------------------------------------------"
				"tried it this way (instead of putting this code in #click: "
				ifTrue: [ owner owner class name == #MapBookMorph ifTrue: [^owner owner mouseDown: evt "Ah, what a hack!"].
	menu _ MenuMorph new defaultTarget: self.
	self addItemsToMenu: menu.
	menu popUpEvent: evt in: self world]
"---------------------------------------------------------------------------------------"
.

"	and then also comment out the next line: "
"	evt hand waitForClicksOrDrag: self event: evt"


"	evt hand grabMorph: self"
]

{ #category : #accessing }
ShapeViewerMorph >> multiplier [
	"when the shapefile has very small scale, we need to multiply coordinates with e.g. 1000.0 to keep the detail after the transform"

	^multiplier
]

{ #category : #testing }
ShapeViewerMorph >> needsDrawing [
	"true if the cached image is no longer uptodate" 
 

	^drawingsNeeded
]

{ #category : #testing }
ShapeViewerMorph >> needsToResetCachedImage [
	"answer true if for some reason the cached image is no longer
	appropriate to display"
	"no cached image"
	image isNil
		ifTrue: [^ true].
	"size of the visible map has changed"
"	(image extent x < self innerBounds extent x
			or: [image extent y < self innerBounds extent y])
		ifTrue: [^ true]."
"	stricter: "
	(image extent ~= self innerBounds extent)
		ifTrue: [^ true].

	"future: add a check on geo-coordinates of topleft"
	^false
]

{ #category : #accessing }
ShapeViewerMorph >> onShape: aShapeMap [ 
	"hand the ShapeMap over to a ShapeMorph and incorporate the ShapeMorph"
	| shape |
	shape := ShapeMorph new shapeMap: aShapeMap.
	self onShapeMorph: shape
]

{ #category : #accessing }
ShapeViewerMorph >> onShapeMorph: aShapeMorph [ 
	"incorporate the shapeMorph"

	maps addLast: aShapeMorph.
	aShapeMorph viewer: self.
	"make the shapeMorph visible"
	self addMorph: aShapeMorph

]

{ #category : #accessing }
ShapeViewerMorph >> onShapeMorphs: aCollection [ 
	"just add all ShapeMorphs in aCollection separately"

	aCollection do: [:each | self onShapeMorph: each]
]

{ #category : #accessing }
ShapeViewerMorph >> onShapes: aCollection [ 
	"just add all ShapeMaps in aCollection separately"

	aCollection do: [:each | self onShape: each]
]

{ #category : #accessing }
ShapeViewerMorph >> scaling [
	scaling isNil
		ifTrue: [self setInitialScaling].
	^ scaling
]

{ #category : #private }
ShapeViewerMorph >> scalingScaledBy: aNumber [
	"dangerous...."
	scaling := scaling * aNumber
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> setInitialScaling [
	"when scaling is not yet defined, scale on the geoBoundingBox of the
	first map"
	| geoExt bb |
	bb := maps first geoBoundingBox.
	geoExt := bb extent.
	geoOffset := (bb origin x) @ (bb corner y). 
	^ scaling := self innerBounds extent x / geoExt x min: self innerBounds extent y / geoExt y
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> setTransform [
	"adjust the MatrixTransform2x3 in <transform>"
	| m xMin yMax |
	self scaling > 1.0
		ifTrue: [multiplier := 1000.0.
			m := MatrixTransform2x3 withScale: 1 @ -1 * scaling / multiplier]
		ifFalse: [multiplier := nil. m := MatrixTransform2x3 withScale: 1 @ -1 * scaling].
"	Transcript show: geoBB printString; cr."
	xMin := geoOffset x.
	yMax := geoOffset y.
	m offset: xMin negated @ yMax * scaling "+ self innerBounds origin".
"	Transcript show: m offset printString; cr."
	transform := m
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> setUserScaling [
	| value |
	value := UIManager default request: 'give new scaling' initialAnswer: scaling printString.
	value isNil ifTrue: [^self].
	scaling := value asNumber. " '0.0023' asNumber  0.0023"
	self viewSetting: nil.	"otherwise #drawOn: will not use an updated transform"
	self invalidateCache.
	self changed
]

{ #category : #accessing }
ShapeViewerMorph >> transform [
	"answer the current MatrixTransform2x3"

	^transform
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> updateViewSetting [
	"some aspect of the projection of the maps may have changed, e.g. the scaling. Recalculate the transform and create a new GISViewSetting"
	self setTransform.
	self viewSetting: self gisViewSetting
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> viewSetting [
	"answer the stored GISViewSetting"

	^viewSetting
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> viewSetting: aGISViewSetting [
	"store aGISViewSetting"

	viewSetting := aGISViewSetting
]

{ #category : #'scaling & transformation' }
ShapeViewerMorph >> viewSettingCreatedIfAbsent [
	"answer the stored GISViewSetting. If absent, recreate it from (hopefully available instance variables"

	viewSetting isNil ifTrue: [self updateViewSetting].
	^viewSetting
]
