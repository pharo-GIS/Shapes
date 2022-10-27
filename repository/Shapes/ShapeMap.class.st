"
ShapeMap is the abstract superclass of classes representing different types of Shapes (maps in ESRI Shape format)
	
	Example: (ShapeMap fromFile: 'c:\esri\esridata\europe\country.shp' )
	or just extract all shapes from the file: (ShapeMap shapesFromFile: 'c:\esri\esridata\europe\country.shp' )

	For further displaying, the shapes can be rendered on a Form, using the asForm method.

	To display a ShapeMap with colors defined by attribute values of the DBF, wrap it in a ShapeEnsemble. 
	You will need the ColorLegend and XBase package in your image!


The format is well-documented (google for ESRI shapefile format); relevant sections are reproduced in the comments. Usually also a .dbf file (XBase, dBase format) belongs to the actual 'shape'; a reader/writer for this format is available on SqueakMap. The records in the dbf (should) correspond to the shapes in the ShapeMap.

Currently handled shapefile formats: Point, PolyLine, Polygon, MultiPoint, PointZ, PolyLineZ, PolygonZ, MultiPointZ.
Not yet handled are: Null Shape, PointM, PolyLineM, PolygonM, MultiPointM, MultiPatch.
Should work on both little-endian and big-endian platforms.

Instance Variables:
	label	<String>	name of the shape file (without extension, without file path)
	shpBytes	<ByteArray>	the bytes in the .shp file (main file)
	shxBytes	<ByteArray>	the bytes in the .shx file (index file)

Accessing the Bytes is completely handled by the ShapeMap. The ShapeMap knows how to extract header info and shape or shape-index info, from the shpBytes and shxBytes. 
Header (100 Bytes, structure identical for shp|Bytes and shxBytes):
Position 	Field 			Value 		Type 	Order
Byte 0 		File Code 		9994 		Integer 	Big
Byte 4 		Unused 		0 			Integer 	Big
Byte 8 		Unused 		0 			Integer 	Big
Byte 12 	Unused 		0 			Integer 	Big
Byte 16 	Unused 		0 			Integer 	Big
Byte 20 	Unused 		0 			Integer 	Big
Byte 24 	File Length 		File Length 	Integer 	Big
Byte 28 	Version 		1000 		Integer 	Little
Byte 32 	Shape Type 	Shape Type Integer 	Little
Byte 36 	Bounding Box 	Xmin 		Double 	Little
Byte 44 	Bounding Box 	Ymin 		Double 	Little
Byte 52 	Bounding Box 	Xmax 		Double 	Little
Byte 60 	Bounding Box 	Ymax 		Double 	Little
Byte 68* 	Bounding Box 	Zmin 		Double 	Little
Byte 76* 	Bounding Box 	Zmax 		Double 	Little
Byte 84* 	Bounding Box 	Mmin 		Double 	Little
Byte 92* 	Bounding Box 	Mmax 		Double 	Little
* Unused, with value 0.0, if not Measured or Z type

The value for file length is the total length of the file in 16-bit words (including the fifty 16-bit words that make up the header). All the non-Null shapes in a shapefile are required to be of the same shape type. The values for shape type are as follows:
Value 	Shape Type
0 		Null Shape
1 		Point
3 		PolyLine
5 		Polygon
8 		MultiPoint
11 		PointZ
13 		PolyLineZ
15 		PolygonZ
18 		MultiPointZ
21 		PointM
23 		PolyLineM
25 		PolygonM
28 		MultiPointM
31 		MultiPatch

The Bounding Box in the main file header stores the actual extent of the shapes in the file: the minimum bounding rectangle orthogonal to the X and Y (and potentially the M and Z) axes that contains all shapes. If the shapefile is empty (that is, has no records), the values for Xmin, Ymin, Xmax, and Ymax are unspecified. Mmin and Mmax can contain ""no data"" values (see Numeric Types on page 2) for shapefiles of measured shape types that contain no measures.

Record Headers
The header for each record stores the record number and content length for the record. Record headers have a fixed length of 8 bytes. Table 2 shows the fields in the file header with their byte position, value, type, and byte order. In the table, position is with respect to the start of the record.

Position 	Field 				Value 			Type 	ByteOrder
Byte 0 		Record Number 		Record Number 	Integer 	Big
Byte 4 		Content Length 		Content Length 	Integer 	Big

Record numbers begin at 1.
The content length for a record is the length of the record contents section measured in 16-bit words. Each record, therefore, contributes (4 + content length) 16-bit words toward the total length of the file, as stored at Byte 24 in the file header.

Record Contents
Shapefile record contents consist of a shape type followed by the geometric data for the shape. The length of the record contents depends on the number of parts and vertices in a shape. For each shape type, we first describe the shape and then its mapping to record contents on disk. In the Tables (see subclasses), position is with respect to the start of the record contents.

Index file
The index file (.shx) contains a 100-byte header followed by 8-byte, fixed-length records. 
Position 	Field 			Value 			Type 	ByteOrder
Byte 0 		Offset 			Offset 			Integer 	Big
Byte 4 		Content Length 	Content Length 	Integer 	Big

The offset of a record in the main file is the number of 16-bit words from the start of the main file to the first byte of the record header for the record. Thus, the offset for the first record in the main file is 50, given the 100-byte header. The content length stored in the index record is the same as the value stored in the main file record header.
"
Class {
	#name : #ShapeMap,
	#superclass : #Object,
	#instVars : [
		'shpBytes',
		'shxBytes',
		'label',
		'colors'
	],
	#category : #'Shapes-Base'
}

{ #category : #examples }
ShapeMap class >> examples [
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\varkens\giabvarkenslbt2001.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\bushcricket\withET_CLASS\SmallSteps_B-HOE.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\bushcricket\withET_CLASS\SmallSteps_B-HOE_line.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\bushcricket\withET_CLASS\SmallSteps_H_REE_line.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\dasenweg\road99.shp') displayMorphic"	"not working..."
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\uso_corr.shp') displayMorphic"
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\abarr.shp') displayMorphic"
	"(ShapeMap fromFile: 'c:\esri\esridata\CANADA\province.shp') displayMorphic "
	"(ShapeMap fromFile: 'c:\esri\esridata\USA\cities.shp') displayMorphic "
	"(ShapeMap fromFile: 'c:\esri\esridata\world\cities.shp') displayMorphic "
	"(ShapeMap fromFile: 'c:\esri\esridata\europe\country.shp') displayMorphic "		
	"(ShapeMap fromFile: 'C:\ESRI\AV_GIS30\AVTUTOR\ARCVIEW\qstart\world94.shp') displayMorphic "
	"(ShapeMap fromFile: 'C:\ESRI\AV_GIS30\AVTUTOR\SPATIAL\pop.shp') displayMorphic "
	"(ShapeMap fromFile: 'C:\ESRI\AV_GIS30\AVTUTOR\SPATIAL\lifstyle.shp') displayMorphic "
	"(ShapeMap fromFile: 'C:\ESRI\AV_GIS30\AVTUTOR\ARCVIEW\qstart\attract.shp') displayMorphic "
	"(ShapeMap fromFile: 'd:\etarcview\3D\abr-z.shp') displayMorphic"			
	

]

{ #category : #'instance creation' }
ShapeMap class >> fromBytes: aShpBytes [ 
	"create a new instance of the appropriate subclass of ShapeMap.
	The instance will act as a wrapper of the raw bytes (stored in ShpBytes)"

	"in case of different types (subclasses), select the relevant one here"

	"ESRI shape file types include:
0	Null Shape
1	Point
3	PolyLine
5	Polygon
8	MultiPoint
11	PointZ
13	PolyLineZ
15	PolygonZ
18	MultiPointZ
21	PointM
23	PolyLineM
25	PolygonM
28	MultiPointM
31	MultiPatch
	Types > 20 are not yet accounted for"

	| instance type theClass |
	type := aShpBytes longAt: 33 bigEndian: false.
	(type // 10) = 0 ifTrue: ["no Z, no M"
		(type \\ 10) = 1 ifTrue: [theClass := PointShape]. 
		(type \\ 10) = 3 ifTrue: [theClass := PolyLineShape]. 	
		(type \\ 10) = 5 ifTrue: [theClass := PolygonShape].
		(type \\ 10) = 8 ifTrue: [theClass := MultiPointShape]].
	(type // 10) = 1 ifTrue: ["with Z, optional M"
		(type \\ 10) = 1 ifTrue: [theClass := PointZShape]. 
		(type \\ 10) = 3 ifTrue: [theClass := PolyLineZShape]. 	
		(type \\ 10) = 5 ifTrue: [theClass := PolygonZShape].
		(type \\ 10) = 8 ifTrue: [theClass := MultiPointZShape]].
	theClass isNil ifTrue: [^self halt "not accounted for yet" ].
	instance := theClass new.
	instance setBytes: aShpBytes.
	^instance
]

{ #category : #'instance creation' }
ShapeMap class >> fromFile: aStringOrFileReference [
	"create ShapeMap from the bytes read from file aString"
	" ShapeMap fromFile: 'c:\etarcview\giovanna\navelli_cocullo.shp' "
	
	| stream instance tail fileRef |

	fileRef := aStringOrFileReference asFileReference.
	stream := fileRef binaryReadStream.
	instance := self fromBytes: ([ stream contents ] ensure: [ stream close ]).
	tail := fileRef withoutExtension fullName.
	instance label: tail.
	instance shxBytes: (self readSHXBytesFrom: fileRef).
	^ instance
]

{ #category : #'instance creation' }
ShapeMap class >> readSHXBytesFrom: fileRef [

	^ (fileRef withExtension: 'shx') asFileReference exists 
		ifFalse: [ self error: 'Missing shx file'.  ]
		ifTrue: [ 
			| shxStream |
			shxStream := (fileRef withExtension: 'shx') asFileReference binaryReadStream.
			[ shxStream contents ] ensure: [ shxStream close ] ].
]

{ #category : #accessing }
ShapeMap class >> shapeType [
	"each type has a typical number"

	^self subclassResponsibility
]

{ #category : #'instance creation' }
ShapeMap class >> shapesFromFile: aString [
	"extract all shapes from file aString"

	"ShapeMap shapesFromFile: 'd:\3D\abr-z.shp' "

	"ShapeMap shapesFromFile: 'c:\etshapes\giabvarkenslbt2001\giabvarkenslbt2001.shp' "

	| inst |
	inst := self fromFile: aString.
	inst ifNotNil: [ ^ inst shapes ].
	^ inst
]

{ #category : #'accessing - index' }
ShapeMap >> allShapeRecordByteOffsets [
	"collect all the offsets as they can be used to query the shpBytes"
	"so NOT zero-based but one-based count; NOT in 16-bit words but in Bytes"

	| n offsets |
	n := self numberOfShapes.
	offsets := Array new: n.
	1 to: n do: [:i | offsets at: i put: (self byteOffsetForShapeAtIndex: i)].
	^offsets
]

{ #category : #'accessing - index' }
ShapeMap >> allShapeRecordOffsets [
	"collect all the offsets (in words, zero-based) as they are stored in the shx.shp"

	| n offsets |
	n := self numberOfShapes.
	offsets := Array new: n.
	1 to: n do: [:i | offsets at: i put: (self offsetForShapeAtIndex: i)].
	^offsets
]

{ #category : #displaying }
ShapeMap >> arcColor [
	^ Color black
]

{ #category : #converting }
ShapeMap >> asForm [
	"answer a Form with the receiver drawn on it. The whole map is projected on the Form"

	"(ImageMorph new image: (ShapeMap fromFile: 'c:\esri\esridata\CANADA\province.shp') asForm) openInWorld"
	"(ImageMorph new image: (ShapeMap fromFile: 'c:\esri\esridata\europe\country.shp') asForm) openInWorld"

	| form |
	form := Form extent: self preferredFormExtent depth: Display depth.
	form fillWhite.
	self drawOn: (BalloonCanvas on: form).
	^form
]

{ #category : #'converting - morphic' }
ShapeMap >> asShapeMorph [
	"create a ShapeMorph holding the receiver"
	| shpMClass |
	shpMClass := Smalltalk at: #ShapeMorph ifAbsent: [^nil].
	^ shpMClass new shapeMap: self
]

{ #category : #converting }
ShapeMap >> asSimpleVectorLandscape [
	self subclassResponsibility
]

{ #category : #displaying }
ShapeMap >> backgroundColor [
	^Color r: 0.774 g: 0.903 b: 0.903
]

{ #category : #accessing }
ShapeMap >> boundingBox [
	^Rectangle origin: self xMin @ self yMin corner: self xMax @ self yMax
]

{ #category : #'accessing - index' }
ShapeMap >> byteOffsetForShapeAtIndex: anInteger [ 
	"answer the offset (for the record of shape number anInteger in the main file) in number of Bytes from the start of the main file"

	"Note that the result is now based on count starting with ONE!"

	^(self offsetForShapeAtIndex: anInteger)  * 2 + 1
]

{ #category : #displaying }
ShapeMap >> colors: anArray [
	"defines the colors of the shapes (anArray size = nr of shapes!)"

	colors := anArray
]

{ #category : #writing }
ShapeMap >> copyToFile [
	"ask the user for a (shape) file name and dump the shpBytes and shxBytes"
	"default, the associated dbf file is also copied to newName.dbf"

	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFile "

	|  newName |
	newName := UIManager default
		request: 'New File Name?' translated
		initialAnswer: 'test'.
	newName isEmpty ifTrue: [^self].
	self copyToFile: newName
]

{ #category : #writing }
ShapeMap >> copyToFile: newName [ 
	"dump the shpBytes and shxBytes on files newName.shp and newName.shx"
	"a dbf file with the receiver's shape name should exist. It is read and also copied to newName.dbf"

	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFile: 'd:\etarcview\atestshape2' "

	| aString stream aString2 stream2 dbfBytes aString3 stream3 |

	aString := (FileSystem disk / newName) fullName , '.shp'.
	stream := aString asFileReference binary.
	[stream next: shpBytes basicSize putAll: shpBytes] ensure: [stream close].

	aString2 := (FileSystem disk / newName) fullName , '.shx'.
	stream2 := aString2 asFileReference  binary.
	[stream2 next: shxBytes basicSize putAll: shxBytes] 
		ensure: [stream2 close].

	Smalltalk at: #XBaseFile ifAbsent: [ ^ self ].
	(label notNil and: [ label asFileReference exists , '.dbf' ]) 
		ifFalse: [ ^ self writeMiniMinimalDBF: newName , '.dbf' ]. "create a minimal dbf"
	dbfBytes := XBaseFile dbfBytesFrom: label , '.dbf'.	"the bytes are read into memory, and directly written to the newName.dbf file"
	aString3 := (FileSystem disk / newName) fullName , '.dbf'.
	stream3 := aString3 asFileReference  binary.
	[stream3 next: dbfBytes basicSize putAll: dbfBytes] 
		ensure: [stream3 close]
]

{ #category : #writing }
ShapeMap >> copyToFileInDir: aDirString [ 
	"ask the user for a (shape) file name and dump the shpBytes, shxBytes and dbf bytes"

	"the user should make sure the directory actually exists!"

	" (ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFileInDir: 'd:\squeak3\temp' "

	| newName dir fullName |
	newName := UIManager default request: 'New File Name?' translated initialAnswer: 'test'.
	dir := FileSystem disk / aDirString.
	fullName := dir asFileReference / newName.
	self copyToFile: fullName
]

{ #category : #writing }
ShapeMap >> copyToFileInDir: aDirString dbf: aDBF [
	"ask the user for a (shape) file name and dump the shpBytes and shxBytes.
	The dbf bytes in aDBF are dumped as well"

	" (ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFileInDir: 'd:\squeak3\temp' dbf: (DBF on: 'd:\etarcview\giovanna\navelli_cocullo.dbf') "

	| newName dir fullName |
	newName := UIManager default request: 'New File Name?' translated initialAnswer: 'test'.
	dir := FileSystem disk / aDirString.
	fullName := dir asFileReference / newName.
	self copyToFileNoDBF: fullName.

	aDBF dbfBytesToFile: fullName , '.dbf'
]

{ #category : #writing }
ShapeMap >> copyToFileNoDBF [
	"ask the user for a (shape) file name and dump the shpBytes & shxBytes only"

	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFile "

	|  newName |
	newName := UIManager default 
		request: 'New File Name?' translated
		initialAnswer: 'test'.
	newName isEmpty ifTrue: [^self].
	self copyToFileNoDBF: newName
]

{ #category : #writing }
ShapeMap >> copyToFileNoDBF: newName [
	"dump the shpBytes and shxBytes on files newName.shp and newName.shx"

	" (ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') copyToFileNoDBF: 'd:\etarcview\atestshape2' "

	| aString stream aString2 stream2 |

	aString :=  newName asFileReference fullName , '.shp'. 
	stream := aString asFileReference binary.
	[ stream next: shpBytes basicSize putAll: shpBytes ]
						ensure: [ stream close ].

	aString2 :=  newName asFileReference fullName , '.shx'. 
	stream2 := aString2 asFileReference  binary.
	[ stream2 next: shxBytes basicSize putAll: shxBytes ]
						ensure: [ stream2 close ]
]

{ #category : #displaying }
ShapeMap >> display [
	"show on the Display"

	^self asForm displayOn: Display
]

{ #category : #displaying }
ShapeMap >> displayMorphic [
	"open an ImageMorph with the receiver as an image"

	^(ImageMorph new image: self asForm) openInWorld
]

{ #category : #'displaying - morphic' }
ShapeMap >> draw [
	^self asShapeMorph openInWorld
]

{ #category : #'displaying - morphic' }
ShapeMap >> drawForm [
	"draw receiver on a Form and show the form"

	| imageMorph |
	imageMorph := self asForm asMorph.
	imageMorph isOpaque: true.
	imageMorph openInWorld
]

{ #category : #displaying }
ShapeMap >> drawOn: aCanvas [ 
	"draw the shape in default colors (no legend using information from the dbf is required)"
	| canvasEngine geoBB scaling m multiplier xMin yMax rect polygonColor arcColor pointColor |

	canvasEngine := aCanvas ensuredEngine.
	canvasEngine aaLevel: 4.

	"boundingBox & scale"
	geoBB := self boundingBox.
	xMin := geoBB origin x.
	yMax := geoBB corner y.
	scaling := self preferredScaling.

	"if we have a legend, let it calculate all colors at once"
	"legend isNil ifFalse: [colors := legend colorForAll: (data collect: [:each | each at: coloringAttrIndex ]) ]. "

	polygonColor := self polygonColor.
	polygonColor isNil ifFalse: [ polygonColor := polygonColor alpha: 0.5 ].
	arcColor := self arcColor.
	pointColor := self pointColor.

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
	m offset: xMin negated @ yMax * scaling.
	aCanvas transformBy: m.
	"finally, the drawing-on-canvas code; slightly different depending on shapeMap type"
	self hasPolygons
		ifTrue: [1
				to: self numberOfShapes
				do: [:i | 
					| contours | 
					contours := self vertices2DByPartsForShapeIndex: i.
					scaling > 1.0
						ifTrue: [contours := contours
										collect: [:each | each
												collect: [:point | point * multiplier]]].
					(colors isNil or: [colors isEmpty]) ifFalse: [polygonColor := colors at: i].
					aCanvas
						drawGeneralPolygon: contours
						color: polygonColor
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ line shapes ++++++++++++++++++++++++"
	self hasLines
		ifTrue: [1
				to: self numberOfShapes
				do: [:i | 
					| contours | 
					contours := self vertices2DByPartsForShapeIndex: i.
					scaling > 1.0
						ifTrue: [contours := contours
										collect: [:each | each
												collect: [:point | point * multiplier]]].
					colors isNil ifFalse: [arcColor := colors at: i].
					aCanvas
						drawGeneralPolygon: contours
						color: nil
						borderWidth: 1
						borderColor: arcColor]].
	"+++++++++++ point shapes ++++++++++++++++++++++++"
	self hasPoints
		ifTrue: [
			rect := (Rectangle origin: -1.0 @ -1.0 corner: 1.0 @ 1.0) scaleBy: (10 raisedToInteger: (1.0 / (scaling / multiplier) max: 1.0) log truncated).
			self hasMultiPoints
				ifTrue: [1
						to: self numberOfShapes
						do: [:i | 
							| points | 
							points := self multiPointsFromShapeIndex: i.
							colors isNil ifFalse: [pointColor := colors at: i].
							scaling > 1.0
								ifTrue: [
									points := points collect: [:each | each * multiplier ].
									points do: [:point | 
										aCanvas
											drawRectangle: (rect translateBy: point)
											color: pointColor
											borderWidth: 0
											borderColor: nil]]]]
				ifFalse: [1
						to: self numberOfShapes
						do: [:i | 
							| point | 
							point := self point2DFromShapeIndex: i.
							scaling > 1.0
								ifTrue: [point := point * multiplier].
							colors isNil ifFalse: [pointColor := colors at: i].
							aCanvas
								drawRectangle: (rect translateBy: point)
								color: pointColor
								borderWidth: 0
								borderColor: nil]]]
]

{ #category : #'accessing - header' }
ShapeMap >> fileCode [
	"position 0, Integer, Big Endian"

	^shpBytes longAt: 1 bigEndian: true
]

{ #category : #'editing - header' }
ShapeMap >> fileCode: anInteger [
	"position 0, Integer, Big Endian. Always 9994"

	^shpBytes longAt: 1 put: 9994 bigEndian: true
]

{ #category : #'accessing - header' }
ShapeMap >> fileLength [
	"position 24, Integer, Big Endian"
	"total length of the file in 16-bit words (including the fifty 16-bit words that make up the file header"

	^shpBytes longAt: 25 bigEndian: true
]

{ #category : #'editing - header' }
ShapeMap >> fileLength: anInteger [
	"position 24, Integer, Big Endian"
	"total length of the file in 16-bit words (including the fifty 16-bit words that make up the file header"

	^shpBytes longAt: 25 put: anInteger bigEndian: true
]

{ #category : #accessing }
ShapeMap >> generalType [
	"subclass answer 'Point', 'Polygon' or 'PolyLine' "

	^self subclassResponsibility
]

{ #category : #testing }
ShapeMap >> hasLines [
	^false
]

{ #category : #testing }
ShapeMap >> hasMultiPoints [
	^false
]

{ #category : #testing }
ShapeMap >> hasPoints [
	^false
]

{ #category : #testing }
ShapeMap >> hasPolygons [
	^false
]

{ #category : #'accessing - bytes' }
ShapeMap >> headerBytes [
	"answer the header part of the bytes" 

	^shpBytes copyFrom: 1 to: 100
]

{ #category : #'accessing - bytes' }
ShapeMap >> headerBytesForShapeIndex: anInteger [ 
	"extract the header bytes for shape with index anInteger"
	| offset |
	offset := self byteOffsetForShapeAtIndex: anInteger.
	^shpBytes copyFrom: offset
		to: offset - 1 + 8
]

{ #category : #'accessing - index' }
ShapeMap >> headerForShapeIndex: anInteger [
	"answer the header in numbers (not bytes!). First value is the index of the shape; second value record contents size in 16bit words"

	| bytes |
	bytes := self headerBytesForShapeIndex: anInteger.
	^Array with: (bytes longAt: 1 bigEndian: true) with: (bytes longAt: 5 bigEndian: true)
]

{ #category : #'accessing - index' }
ShapeMap >> indexFileLength [
	"position 24, Integer, Big Endian"
	"total length of the file in 16-bit words (including the fifty 16-bit words that make up the file header"

	^shxBytes longAt: 25 bigEndian: true
]

{ #category : #accessing }
ShapeMap >> label [
	"answer the shape file name (aString)"

	^label
]

{ #category : #accessing }
ShapeMap >> label: aString [
	"set the name of the shape (the file name, excluding the shp suffix)"

	label := aString
]

{ #category : #'accessing - header' }
ShapeMap >> mMax [
	"byte 92, Double, Little Endian"
	"may be undefined!"

	"^shpBytes doubleAt: 93 bigEndian: false "
	
	^self shpDoubleAt: 93 bigEndian: false	
]

{ #category : #'accessing - header' }
ShapeMap >> mMin [
	"byte 84, Double, Little Endian"
	"may be undefined!"

	"^shpBytes doubleAt: 85 bigEndian: false "
	
	^self shpDoubleAt: 85 bigEndian: false	
]

{ #category : #'accessing - records' }
ShapeMap >> nextRecordOffsetForRecordAtOffset: anInteger [ 
	"answer the offset of the next record. Using this info we could ignore the index file"

	^(self totalRecordSizeForRecordAtOffset: anInteger) * 2 + anInteger
]

{ #category : #accessing }
ShapeMap >> numberOfShapes [
	"answer the total number of shapes in the Shape file"
	"what a shapefile contains, depends on the Shape Type. The index file is 
	identical for all Shape Types, though"
	^ self indexFileLength - 50 * 2 / 8	 "subtract header (50 16-bit words), convert to bytes (50*2), divide by 
	record size in bytes (8: four bytes for Offset and 4 for Content Length)"
]

{ #category : #'accessing - index' }
ShapeMap >> offsetForShapeAtIndex: anInteger [ 
	"answer the offset (for the record of shape number anInteger in the main file) in number of 16-bits words from the start of the main file"

	"Note that the result is based on count starting with zero"
	"From the documentation:
	The offset of a record in the main file is the number of 16-bit words from the start of the main file to the first byte of the record header for the record. Thus, the offset for the first record in the main file is 50, given the 100-byte header."

	^shxBytes longAt: 101 + ((anInteger - 1) * 8) bigEndian: true
]

{ #category : #'writing - support' }
ShapeMap >> on: aStream putNextDouble: number bigEndian: aBoolean [ 
	"convenience method"
	| bytes |
	bytes := ByteArray new: 8.
	bytes 
		doubleAt: 1
		put: number
		bigEndian: aBoolean.
	aStream next: 8 putAll: bytes
]

{ #category : #'writing - support' }
ShapeMap >> on: aStream putNextLong: number bigEndian: aBoolean [ 
	"convenience method"

	| bytes |
	bytes := ByteArray new: 4.
	bytes 
		longAt: 1
		put: number
		bigEndian: aBoolean.
	aStream next: 4 putAll: bytes
]

{ #category : #'writing - support' }
ShapeMap >> on: aStream putNextShort: number bigEndian: aBoolean [ 
	"convenience method"

	| bytes |
	bytes := ByteArray new: 2.
	bytes 
		shortAt: 1
		put: number
		bigEndian: aBoolean.
	aStream next: 2 putAll: bytes
]

{ #category : #'writing - support' }
ShapeMap >> on: aStream putNextULong: number bigEndian: aBoolean [ 
	"convenience method"

	| bytes |
	bytes := ByteArray new: 4.
	bytes 
		unsignedLongAt: 1
		put: number
		bigEndian: aBoolean.
	aStream next: 4 putAll: bytes
]

{ #category : #'writing - support' }
ShapeMap >> on: aStream putNextUShort: number bigEndian: aBoolean [ 
	"convenience method"

	| bytes |
	bytes := ByteArray new: 2.
	bytes 
		unsignedShortAt: 1
		put: number
		bigEndian: aBoolean.
	aStream next: 2 putAll: bytes
]

{ #category : #displaying }
ShapeMap >> pointColor [
	^Color red
]

{ #category : #displaying }
ShapeMap >> polygonColor [
	^Color r: 0.903 g: 0.742 b: 0.387
]

{ #category : #converting }
ShapeMap >> preferredFormExtent [
	"derive the proportions from the geo-bounding box; use a preferred x-dimension in pixels"
	
	| gbb ext prop |
	gbb := self boundingBox.
	ext := gbb extent.
	prop := ext y / ext x.
	^1000 * (1@prop)
]

{ #category : #converting }
ShapeMap >> preferredScaling [
	"derive the scaling from the preferred extent in pixels"
	
	| gbb |
	gbb := self boundingBox.
	^1000.0 / gbb extent x.

]

{ #category : #'accessing - bytes' }
ShapeMap >> recordBytesForShapeIndex: anInteger [ 
	"extract the whole ByteArray constituting the complete record for shape with index anInteger"

	| offset |
	offset := self byteOffsetForShapeAtIndex: anInteger.
	^shpBytes copyFrom: offset
		to: offset - 1 + ((self totalRecordSizeForRecordAtOffset: offset) * 2)
]

{ #category : #'accessing - records' }
ShapeMap >> recordNumberForRecordAtOffset: anInteger [
	"answer the index of the shape contained in the record starting at offset anInteger"
	"Byte 1 to Byte 4 in the record header contain this Record Number"

	^shpBytes longAt: anInteger bigEndian: true.
]

{ #category : #'accessing - records' }
ShapeMap >> recordSizeForRecordAtOffset: anInteger [
	"answer record contents size (in 16-bit words) for record starting at offset anInteger"
	"Byte 5 to Byte 8 in the record header contain this Record Contents Size"

	^shpBytes longAt: anInteger + 4 bigEndian: true.
]

{ #category : #'accessing - index' }
ShapeMap >> recordSizeForShapeIndex: anInteger [
	"answer record contents size (in 16-bit words) for shape with index anInteger"

	^self recordSizeForRecordAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #private }
ShapeMap >> setBytes: aByteArray [
	"store all the Bytes in shpBytes"

	shpBytes := aByteArray. "no need to copy the ByteArray, as done for UninterpretedBytes?"
	"self initializeFromHeaderInfo"
]

{ #category : #'accessing - header' }
ShapeMap >> shapeType [
	"position 32, Integer between 0 and 31, Little Endian"

	^shpBytes longAt: 33 bigEndian: false

"
0	Null Shape
1	Point
3	PolyLine
5	Polygon
8	MultiPoint
11	PointZ
13	PolyLineZ
15	PolygonZ
18	MultiPointZ
21	PointM
23	PolyLineM
25	PolygonM
28	MultiPointM
31	MultiPatch
"
]

{ #category : #'editing - header' }
ShapeMap >> shapeType: anInteger [
	"position 32, Integer between 0 and 31, Little Endian"

	^shpBytes longAt: 33 put: anInteger bigEndian: false

"
0	Null Shape
1	Point
3	PolyLine
5	Polygon
8	MultiPoint
11	PointZ
13	PolyLineZ
15	PolygonZ
18	MultiPointZ
21	PointM
23	PolyLineM
25	PolygonM
28	MultiPointM
31	MultiPatch
"
]

{ #category : #'accessing - records' }
ShapeMap >> shapeTypeForShapeAtOffset: anInteger [
	"anInteger is the byte number of the offset of the record holding Shape info"

	^shpBytes longAt: anInteger + 8 bigEndian: false	"add the 8-byte record header"
]

{ #category : #'accessing - contents' }
ShapeMap >> shapes [
	"answer the receiver's data as Squeak objects"
	"the context will determine the kind of objects needed.... Points, Arrays with Points, etc."
	
	self subclassResponsibility
]

{ #category : #'accessing - bytes' }
ShapeMap >> shapesBytes [
	"create the shape data bytes"

	^shpBytes copyFrom: 101 to: shpBytes size

]

{ #category : #'ByteArray methods' }
ShapeMap >> shpDoubleAt: index bigEndian: bool [ 
	"when ByteArray doubleAt:bigEndian: is defined, replace this method by 'shpBytes doubleAt:bigEndian:' "
	"Return a 64 bit float starting from the given byte index"
	| w1 w2 dbl |
	w1 := shpBytes unsignedLongAt: index bigEndian: bool.
	w2 := shpBytes unsignedLongAt: index + 4 bigEndian: bool.
	dbl := Float new: 2.
	bool
		ifTrue: [dbl basicAt: 1 put: w1.
			dbl basicAt: 2 put: w2]
		ifFalse: [dbl basicAt: 1 put: w2.
			dbl basicAt: 2 put: w1].
	^ dbl
]

{ #category : #'ByteArray methods' }
ShapeMap >> shpDoubleAt: index put: value bigEndian: bool [ 
	"when ByteArray doubleAt:put:bigEndian: is defined, replace this method by 'shpBytes doubleAt:put:bigEndian:' "
	"Store a 64 bit float starting from the given byte index"
	| w1 w2 |
	bool
		ifTrue: [w1 := value basicAt: 1.
			w2 := value basicAt: 2]
		ifFalse: [w1 := value basicAt: 2.
			w2 := value basicAt: 1]. 
	shpBytes unsignedLongAt: index put: w1 bigEndian: bool.
	shpBytes unsignedLongAt: index + 4 put: w2 bigEndian: bool.
	^ value

]

{ #category : #private }
ShapeMap >> shxBytes: aShpBytes [
	"store the contents of the index file in shxBytes"

	shxBytes := aShpBytes
]

{ #category : #writing }
ShapeMap >> streamedHeaderBytes [
	"create the header bytes by streaming" 
	"shpBytes copyFrom: 1 to: 100"
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') streamedHeaderBytes "
"
Header (100 Bytes, structure identical for shp|Bytes and shxBytes):
Position 	Field 			Value 		Type 	Order
Byte 0 		File Code 		9994 		Integer 	Big
Byte 4 		Unused 		0 			Integer 	Big
Byte 8 		Unused 		0 			Integer 	Big
Byte 12 	Unused 		0 			Integer 	Big
Byte 16 	Unused 		0 			Integer 	Big
Byte 20 	Unused 		0 			Integer 	Big
Byte 24 	File Length 		File Length 	Integer 	Big
Byte 28 	Version 		1000 		Integer 	Little
Byte 32 	Shape Type 	Shape Type Integer 	Little
Byte 36 	Bounding Box 	Xmin 		Double 	Little
Byte 44 	Bounding Box 	Ymin 		Double 	Little
Byte 52 	Bounding Box 	Xmax 		Double 	Little
Byte 60 	Bounding Box 	Ymax 		Double 	Little
Byte 68* 	Bounding Box 	Zmin 		Double 	Little
Byte 76* 	Bounding Box 	Zmax 		Double 	Little
Byte 84* 	Bounding Box 	Mmin 		Double 	Little
Byte 92* 	Bounding Box 	Mmax 		Double 	Little
* Unused, with value 0.0, if not Measured or Z type "

	| stream source |
	source := self.	"to test, obtain data from the receiver"
	stream := WriteStream on: (ByteArray new: 100).	"100 bytes for the header"
	stream nextNumber: 4 put: 9994.	"magic number"
	5 timesRepeat: [stream uint32: 0].
	stream nextNumber: 4 put: source fileLength.	"file length"
	stream nextLittleEndianNumber: 4 put: source version.	"version = 1000" 
	stream nextLittleEndianNumber: 4 put: source shapeType.
	(Array with: source xMin with: source yMin with: source xMax with: source yMax) 
		do: [:double | self on: stream putNextDouble: double bigEndian: false].
	stream next: 32 putAll: (ByteArray new: 32).
	^stream contents
]

{ #category : #consistency }
ShapeMap >> testByteSizes [
	"test the size in Bytes"
	
	| totBytes recsBytes |
	totBytes := self fileLength * 2.
	recsBytes := 0.
	1 to: self numberOfShapes do: [:i | 
		recsBytes := recsBytes + (self recordBytesForShapeIndex: i ) size].
	^(100 + recsBytes) = totBytes ifFalse: [self halt] ifTrue: [true]
	
]

{ #category : #'accessing - records' }
ShapeMap >> totalRecordSizeForRecordAtOffset: anInteger [ 
	"answer Record Header + Record Contents Size (in 16-bit words) for record starting at offset anInteger"

	^(self recordSizeForRecordAtOffset: anInteger) + 4
]

{ #category : #'accessing - header' }
ShapeMap >> version [
	"position 28, always 1000, Little Endian"

	^shpBytes longAt: 29 bigEndian: false
]

{ #category : #'editing - header' }
ShapeMap >> version: anInteger [
	"position 28, always 1000, Little Endian"

	^shpBytes longAt: 29 put: 1000 bigEndian: false
]

{ #category : #writing }
ShapeMap >> writeMiniMinimalDBF: aString [ 
	"produce something that is accepted by ArcView"
	"Include just an ID. I think it is also OK to have zero fields...."

	| fields writeBlock xbase |
	fields := OrderedCollection new.
	fields addLast: #('ID' $N 8 0 nil).
	writeBlock := 
			[xbase := XBaseFile on: aString fields: fields.
			1 to: self numberOfShapes
				do: 
					[:i | 
					xbase append.
					xbase atField: 1 put: i]].
	writeBlock ensure: [xbase close]
]

{ #category : #'accessing - header' }
ShapeMap >> xMax [
	"byte 52, Double, Little Endian"

	"^shpBytes doubleAt: 53 bigEndian: false "
	
	^self shpDoubleAt: 53 bigEndian: false
]

{ #category : #'editing - header' }
ShapeMap >> xMax: aDouble [
	"byte 52, Double, Little Endian"

	"^shpBytes doubleAt: 53 bigEndian: false "
	
	^self shpDoubleAt: 53 put: aDouble bigEndian: false
]

{ #category : #'accessing - header' }
ShapeMap >> xMin [
	"byte 36, Double, Little Endian"

	"^shpBytes doubleAt: 37 bigEndian: false "
	
	^self shpDoubleAt: 37 bigEndian: false		
]

{ #category : #'editing - header' }
ShapeMap >> xMin: aDouble [
	"byte 36, Double, Little Endian"

	"^shpBytes doubleAt: 37 bigEndian: false "
	
	^self shpDoubleAt: 37 put: aDouble bigEndian: false		
]

{ #category : #'accessing - header' }
ShapeMap >> yMax [
	"byte 60, Double, Little Endian"

	"^shpBytes doubleAt: 61 bigEndian: false "
	
	^self shpDoubleAt: 61 bigEndian: false
]

{ #category : #'editing - header' }
ShapeMap >> yMax: aDouble [
	"byte 60, Double, Little Endian"

	"^shpBytes doubleAt: 61 bigEndian: false "
	
	^self shpDoubleAt: 61 put: aDouble bigEndian: false
]

{ #category : #'accessing - header' }
ShapeMap >> yMin [
	"byte 44, Double, Little Endian"

	"^shpBytes doubleAt: 45 bigEndian: false "
	
	^self shpDoubleAt: 45 bigEndian: false
	
]

{ #category : #'editing - header' }
ShapeMap >> yMin: aDouble [
	"byte 44, Double, Little Endian"

	"^shpBytes doubleAt: 45 bigEndian: false "
	
	^self shpDoubleAt: 45 put: aDouble bigEndian: false
	
]

{ #category : #'accessing - header' }
ShapeMap >> zMax [
	"byte 76, Double, Little Endian"
	"may be undefined!"

	"^shpBytes doubleAt: 77 bigEndian: false "
	
	^self shpDoubleAt: 77 bigEndian: false		
]

{ #category : #'accessing - header' }
ShapeMap >> zMin [
	"byte 68, Double, Little Endian"
	"may be undefined!"

	"^shpBytes doubleAt: 69 bigEndian: false "
	
	^self shpDoubleAt: 69 bigEndian: false
]
