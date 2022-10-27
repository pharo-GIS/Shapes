"
MultiPointShape represents a MultiPoint Type shape file - jmb, 13/4/2004

Record structure:
Position 	Field 			Value 		Type 		Number 	ByteOrder
Byte 0 		Shape Type 	8 			Integer 		1 			Little
Byte 4 		Box 			Box 		Double 		4 			Little
Byte 36 	NumPoints 		NumPoints 	Integer 		1 			Little
Byte 40 	Points 			Points 		Point 		NumPoints 	Little


"
Class {
	#name : #MultiPointShape,
	#superclass : #ShapeMap,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
MultiPointShape class >> fromPointsColl: pointsColl boundingBox: aRectangle [
	"create a complete PointShape using only points & boundingBox info"
	"send copyToFile to the instance, to move the bytes to files (*.shx, *.shp and *.dbf)"

	"(MultiPointShape fromPointsColl: 
		((1 to: 100) collect: [:i | Array with: (i * 10) @ (i * 10) with: (i * 10) @ (i * 10) + (100@0) ]) 
					boundingBox: 
		(Rectangle origin: 1@1 corner: 1000@1000)) copyToFile"

	"(MultiPointShape fromPointsColl: 
		((1 to: 100) collect: [:i | Array with: (i * 10) @ (i * 10) with: (i * 10) @ (i * 10) + (100@0) ]) 
					boundingBox: 
		(Rectangle origin: 1@1 corner: 1000@1000)) drawForm"	"??"


	^self new fromPointsColl: pointsColl boundingBox: aRectangle
]

{ #category : #accessing }
MultiPointShape class >> shapeType [
	^8
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

{ #category : #converting }
MultiPointShape >> asFormExtent: aPoint depth: anInteger geoBoundingBox: aRect scaling: aNumber [
	"answer the receiver displayed on a Form, within geographical bounds set by aRect and scaling determined by aNumber"

	| form canvas geoBB scaling m pointColor rect multiplier xMin yMax |
	form := Form extent: aPoint depth: anInteger.
	pointColor := self pointColor.
	form fillColor: self backgroundColor.
	canvas := (BalloonCanvas on: form) ensuredEngine.
	canvas aaLevel: 0.
	"points stand out better without anti-aliasing"
	geoBB := aRect.
	xMin := geoBB origin x.
	yMax := geoBB corner y.
	scaling := aNumber.
	scaling > 1.0
		ifTrue: [multiplier := 1000.0.
			m := MatrixTransform2x3 withScale: 1 @ -1 * scaling / multiplier.
			m offset: xMin negated @ yMax * scaling.
			canvas transformBy: m.
			rect := (Rectangle origin: -1.0 @ -1.0 corner: 1.0 @ 1.0)
						scaleBy: (10 raisedToInteger: (1.0 / (scaling / multiplier) max: 1.0) log truncated).
			1
				to: self numberOfShapes
				do: [:i | 
					| points | 
					points := self multiPointsFromShapeIndex: i.
					points
						do: [:point | canvas
								drawRectangle: (rect translateBy: point * multiplier)
								color: pointColor
								borderWidth: 0
								borderColor: nil]]]
		ifFalse: [m := MatrixTransform2x3 withScale: 1 @ -1 * scaling.
			m offset: xMin negated @ yMax * scaling.
			canvas transformBy: m.
			rect := (Rectangle origin: -1.0 @ -1.0 corner: 1.0 @ 1.0)
						scaleBy: (10 raisedToInteger: (1.0 / scaling max: 1.0) log truncated).
			1
				to: self numberOfShapes
				do: [:i | 
					| points | 
					points := self multiPointsFromShapeIndex: i.
					points
						do: [:point | canvas
								drawRectangle: (rect translateBy: point)
								color: pointColor
								borderWidth: 0
								borderColor: nil]]].
	^ form
]

{ #category : #'accessing - records' }
MultiPointShape >> boundingBoxForShapeAtOffset: anInteger [ 

	^ Rectangle origin: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 12 bigEndian: false) 
				@ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 20 bigEndian: false)
		corner: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 28 bigEndian: false) 
				@ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 36 bigEndian: false)
]

{ #category : #editing }
MultiPointShape >> fromPointsColl: vertsColl boundingBox: aRectangle [
	"create a complete MultiPointShape using only points & boundingBox info"

"Record structure:
Position 	Field 			Value 		Type 		Number 	ByteOrder
Byte 0 		Shape Type 		8 			Integer 		1 			Little
Byte 4 		Box 			Box 		Double 		4 			Little
Byte 36 		NumPoints 		NumPoints 	Integer 		1 			Little
Byte 40 		Points 			Points 		Point 		NumPoints 	Little"

	"(MultiPointShape fromPointsColl: ((1 to: 100) collect: [:i | Array with: (i * 10) @ (i * 10) with: (i * 10) @ (i * 10) + (100@0) ]) boundingBox: (Rectangle origin: 1@1 corner: 1000@1000)) copyToFile"


	| n numPoints pointByteL basicRecHeaderByteL basicRecByteL totByteL fileByteL indexByteL stream recordContentByteL readStream offsetByte shType ros |
	n := vertsColl size.
	numPoints := vertsColl asArray collect: [:each | each size].	"number of points per shape"
	pointByteL := numPoints collect: [:each | each * 16].			"each point = 2 * 8 Bytes"
	basicRecHeaderByteL := 8.									"header: 4 + 4"
	basicRecByteL := 40.											"subheader: 4 (shptype) + (4 * 8 bb) + 4 (numpoints) "
	recordContentByteL := Array new: n.
	1 to: n
		do: 
			[:i | 
			recordContentByteL at: i
				put: basicRecByteL + (pointByteL at: i)].	"record content in bytes"
	totByteL := recordContentByteL sum + (basicRecHeaderByteL * n).	"and with the fixed record header bytes added"
	fileByteL := 100 + totByteL.
	shpBytes := ByteArray new: fileByteL.
	indexByteL := 100 + (n * 8).									"same header, with 8 bytes per record/shape"
	shxBytes := ByteArray new: indexByteL.

		"fill the header"
	self fileCode: 9994.
	self fileLength: fileByteL / 2.			"in Words, not Bytes"
	self version: 1000.						"always 1000"
	shType := self class shapeType.			"ask the class"
	self shapeType: shType.					"the MultiPoint type = 8"
	self xMin: aRectangle origin x asFloat.
	self xMax: aRectangle corner x asFloat.
	self yMin: aRectangle origin y asFloat.
	self yMax: aRectangle corner y asFloat.

		"copy the header to shxBytes"
	1 to: 100 do: [:i | shxBytes at: i put: (shpBytes at: i)].
		"but adjust file length!"
	shxBytes longAt: 25 put: indexByteL / 2 bigEndian: true.	

	ros := OrderedCollection new: n.		"store for each record the index of its offset byte"
	offsetByte := 101.
	ros addFirst: offsetByte.
	1 to: n-1 do: [:i | offsetByte := offsetByte + 8 + (recordContentByteL at: i). ros addLast: offsetByte].
	ros := ros asArray.

		"fill the records"
	stream := WriteStream on: shpBytes.
	readStream := ReadStream on: (shpBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	1 to: n
		do: 
			[:index | 
			"write record header"

			| xMin xMax yMin yMax nPo start |
			self on: stream putNextULong: index bigEndian: true.					"4 Bytes (Record Number)"
			self on: stream putNextULong: (recordContentByteL at: index) / 2
				bigEndian: true.													"4 Bytes (Record Contents in 16bits words)"

			"write record contents"
			self on: stream putNextULong: shType bigEndian: false.				"4 Bytes (ShapeType)"
			"calculate and write boundingBox"
			start := (vertsColl at: index) first.
			xMin := xMax := start x.
			yMin := yMax := start y.
			(vertsColl at: index) do: 
					[:each | 
					xMin := xMin min: each x.
					xMax := xMax max: each x.
					yMin := yMin min: each y.
					yMax := yMax max: each y].
			self on: stream putNextDouble: xMin asFloat bigEndian: false.		"8 Bytes"
			self on: stream putNextDouble: yMin asFloat bigEndian: false.		"8 Bytes"
			self on: stream putNextDouble: xMax asFloat bigEndian: false.		"8 Bytes"
			self on: stream putNextDouble: yMax asFloat bigEndian: false.	"8 Bytes"

			nPo := numPoints at: index.
			self on: stream putNextULong: nPo bigEndian: false.		"4 Bytes (tot number of points)"

			(vertsColl at: index) do: 
					[:vert | 
					self on: stream putNextDouble: vert x asFloat bigEndian: false.
					self on: stream putNextDouble: vert y asFloat bigEndian: false]].
	shpBytes := stream contents.

	"fill the index bytes"
	stream := WriteStream on: shxBytes.
	readStream := ReadStream on: (shxBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].

	1 to: n
		do: 
			[:i | | offB | offB := ros at: i. 
			self on: stream putNextULong: ((offB - 1) / 2) bigEndian: true.
			self on: stream putNextULong: ((recordContentByteL at: i) / 2) bigEndian: true].
	shxBytes := stream contents

]

{ #category : #accessing }
MultiPointShape >> generalType [

	^'Point'
]

{ #category : #testing }
MultiPointShape >> hasMultiPoints [
	^true
]

{ #category : #testing }
MultiPointShape >> hasPoints [
	^true
]

{ #category : #'accessing - records' }
MultiPointShape >> multiPointsFromShapeAtOffset: anInteger [ 
	"answer a collection with the points in the shape whose record starts at Byte anInteger"

	"skip 8 Bytes for the Record Header + 4 for the Shape Type (8) + 32 Bytes for the Bounding Box = 44"

	| nPoints points offset |
	nPoints := shpBytes longAt: anInteger + 44 bigEndian: false.	"4 Bytes for the NumPoints"
	"points start at 44 + 4 = 48"
	points := OrderedCollection new: nPoints.
	offset := anInteger + 48.
	1 to: nPoints
		do: 
			[:i | 
			points addLast: ("shpBytes doubleAt:" self shpDoubleAt: offset + ((i - 1) * 16) bigEndian: false) 
						@ ("shpBytes doubleAt:" self shpDoubleAt: offset + 8 + ((i - 1) * 16) bigEndian: false)].
	^points asArray
]

{ #category : #'accessing - shape by index' }
MultiPointShape >> multiPointsFromShapeIndex: anInteger [ 
	"answer the collection of points represented by the shape index anInteger - jmb, 13/4/2004"

	^self 
		multiPointsFromShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - contents' }
MultiPointShape >> shapes [
	"answer the receiver's data as anArray with Arrays with Points"
	| n shapes |
	n := self numberOfShapes.
	shapes := Array new: n.
	1
		to: n
		do: [:i | shapes
				at: i
				put: (self multiPointsFromShapeIndex: i)].
	^ shapes
]
