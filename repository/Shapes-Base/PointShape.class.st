"
PointShape represents a Point Type shape file.

Record structure (in Bytes):

[header: 8] [Data Type: 4] [X coordinate: 8] [Y coordinate: 8]

(documentation:)
Position 	Field 			Value 	Type 		Number 	ByteOrder
Byte 0 		Shape Type 		1 		Integer 		1 			Little
Byte 4 		X 				X 		Double 		1 			Little
Byte 12 		Y 				Y 		Double 		1 			Little

"
Class {
	#name : #PointShape,
	#superclass : #ShapeMap,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
PointShape class >> fromPointsColl: pointsColl boundingBox: aRectangle [
	"create a complete PointShape using only points & boundingBox info"

	"(PointShape fromPointsColl: ((1 to: 100) collect: [:i | (i * 10) @ (i * 10)]) boundingBox: (Rectangle origin: 1@1 corner: 1000@1000)) copyToFile"
	"| rng | rng := Random new.
	(PointShape fromPointsColl: ((1 to: 100) collect: [:i | (rng next * 1000) @ (rng next * 1000)]) boundingBox: (Rectangle origin: 1@1 corner: 1000@1000)) copyToFile"
	"| rng | rng := Random new.
	(PointShape fromPointsColl: ((1 to: 100) collect: [:i | (rng next * 1000) @ (rng next * 1000)]) boundingBox: (Rectangle origin: 1@1 corner: 1000@1000)) drawForm"	"??"
	

	^self new fromPointsColl: pointsColl boundingBox: aRectangle
]

{ #category : #accessing }
PointShape class >> shapeType [
	^1
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

{ #category : #editing }
PointShape >> fromPointsColl: vertsColl boundingBox: aRectangle [
	"create a complete PointShape using only points & boundingBox info"


"Record structure (in Bytes):
[header: 8] [Data Type: 4] [X coordinate: 8] [Y coordinate: 8]
(documentation:)
Position 	Field 			Value 	Type 		Number 	ByteOrder
Byte 0 		Shape Type 		1 		Integer 		1 			Little
Byte 4 		X 				X 		Double 		1 			Little
Byte 12 		Y 				Y 		Double 		1 			Little"

	"(PointShape fromPointsColl: ((1 to: 100) collect: [:i | (i * 10) @ (i * 10)]) boundingBox: (Rectangle origin: 1@1 corner: 1000@1000)) copyToFile"


	| n basicRecHeaderByteL totByteL fileByteL indexByteL stream recordContentByteL readStream offsetByte shType ros |
	n := vertsColl size.
	basicRecHeaderByteL := 8.									"header: 4 + 4"
	recordContentByteL := Array new: n withAll: 20.				"record content in bytes (always 20: 4shptype + 8x + 8y)"
	totByteL := (20 * n) + (basicRecHeaderByteL * n).				"and with the fixed record header bytes added"
	fileByteL := 100 + totByteL.
	shpBytes := ByteArray new: fileByteL.
	indexByteL := 100 + (n * 8).									"same header, with 8 bytes per record/shape"
	shxBytes := ByteArray new: indexByteL.

		"fill the header"
	self fileCode: 9994.
	self fileLength: fileByteL / 2.			"in Words, not Bytes"
	self version: 1000.						"always 1000"
	shType := self class shapeType.			"ask the class"
	self shapeType: shType.					"the Point type = 1"
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
	1 to: n-1 do: [:i | offsetByte := offsetByte + 8 + (recordContentByteL at: i) "=20". ros addLast: offsetByte].
	ros := ros asArray.

		"fill the records"
	stream := WriteStream on: shpBytes.
	readStream := ReadStream on: (shpBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	1 to: n
		do: 
			[:index | 
			"write record header"

			| point |
			self on: stream putNextULong: index bigEndian: true.					"4 Bytes (Record Number)"
			self on: stream putNextULong: (recordContentByteL at: index) / 2
				bigEndian: true.													"4 Bytes (Record Contents in 16bits words)"

			"write record contents"
			self on: stream putNextULong: shType bigEndian: false.				"4 Bytes (ShapeType)"

			"write the single point"
			point := vertsColl at: index. 
			self on: stream putNextDouble: point x asFloat bigEndian: false.
			self on: stream putNextDouble: point y asFloat bigEndian: false].
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
PointShape >> generalType [

	^'Point'
]

{ #category : #testing }
PointShape >> hasPoints [
	^true
]

{ #category : #'accessing - shape by index' }
PointShape >> point2DFromShapeIndex: anInteger [ 
	"answer the point represented by the shape index anInteger"
	"identical to basic #pointFromShapeIndex: anInteger"

	^self pointFromShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PointShape >> pointFromShapeAtOffset: anInteger [ 
	"answer the point represented by the shape whose record starts at 
	anInteger "
	^ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 12 bigEndian: false)
		@ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 20 bigEndian: false)
]

{ #category : #'accessing - shape by index' }
PointShape >> pointFromShapeIndex: anInteger [ 
	"answer the point represented by the shape index anInteger"

	^self pointFromShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - contents' }
PointShape >> shapes [
	"answer the receiver's data as anArray with Points (or Array(x y z) for PointZShape)"
	| n shapes |
	n := self numberOfShapes.
	shapes := Array new: n.
	1
		to: n
		do: [:i | shapes
				at: i
				put: (self pointFromShapeIndex: i)].
	^ shapes
]
