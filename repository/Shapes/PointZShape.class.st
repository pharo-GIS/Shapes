"
PointZShape represents a PointZ Type shape file. A PointZ consists of a triplet of double-precision coordinates in the order X, Y, Z plus a (optional) measure M.

Record structure (in Bytes):

[header: 8] [Data Type: 4] [X coordinate: 8] [Y coordinate: 8] [Z coordinate: 8] [Measure: 8]

(documentation:)
Position 	Field 			Value 	Type 		Number 	ByteOrder
Byte 0 		Shape Type 		11 		Integer 		1 			Little
Byte 4 		X 				X 		Double 		1 			Little
Byte 12 		Y 				Y 		Double 		1 			Little
Byte 20 		Z 				Y 		Double 		1 			Little
Byte 28 		M 				M 		Double 		1 			Little
"
Class {
	#name : #PointZShape,
	#superclass : #PointShape,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
PointZShape class >> fromPointsColl: pointsColl boundingBox: aRectangle [

	^self error: 'not yet implemented'
]

{ #category : #accessing }
PointZShape class >> shapeType [
	^11
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
PointZShape >> measureForShapeAtOffset: anInteger [ 
	"answer the measure (M) value of the shape whose record starts at 
	anInteger "
	^ "shpBytes doubleAt:" self shpDoubleAt: anInteger + 36 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PointZShape >> point2DFromShapeIndex: anInteger [ 
	"answer the 2Dpoint represented by the shape index anInteger"
	^ super pointFromShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PointZShape >> pointFromShapeAtOffset: anInteger [ 
	"answer the 3D point Array(x y z) represented by the shape whose  
	record starts at anInteger"
	"could return aB3DVector3 instead, by using ()@()@()"
	^ Array
		with: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 12 bigEndian: false)
		with: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 20 bigEndian: false)
		with: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 28 bigEndian: false)
]
