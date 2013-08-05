"
MultiPointZShape represents a MultiPointZ Type shape file. Record contains separate arrays with Zvalues and (optional) measures

Record structure:
Position 	Field 			Value 		Type 		Number 	ByteOrder
Byte 0 		Shape Type 		18 			Integer 		1 			Little
Byte 4 		Box 			Box 		Double 		4 			Little
Byte 36 		NumPoints 		NumPoints 	Integer 		1 			Little
Byte 40 		Points 			Points 		Point 		NumPoints 	Little
Byte X 		Zmin 			Zmin 		Double 		1 			Little
Byte X+8 	Zmax 			Zmax 		Double 		1 			Little
Byte X+16 	Zarray 			Zarray 		Double 		NumPoints 	Little
Byte Y* 	Mmin 			Mmin 		Double 		1 			Little
Byte Y+8* 	Mmax 			Mmax 		Double 		1 			Little
Byte Y+16* 	Marray 		Marray 	Double 		NumPoints 	Little
Note: X = 40 + (16 * NumPoints); Y = X + 16 + (8 * NumPoints)
* optional									


"
Class {
	#name : #MultiPointZShape,
	#superclass : #MultiPointShape,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
MultiPointZShape class >> fromPointsColl: pointsColl boundingBox: aRectangle [

	^self error: 'not yet implemented'
]

{ #category : #accessing }
MultiPointZShape class >> shapeType [
	^18
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
MultiPointZShape >> mMaxForShapeAtOffset: anInteger [ 
	"answer the mMax value of the shape whose record starts at Byte anInteger "
	"Note: X = 40 + (16 * NumPoints); Y = X + 16 + (8 * NumPoints)"
	| nPoints |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at anInteger + 40 + 8 = anInteger + 48"
	^ "shpBytes doubleAt:" self shpDoubleAt: anInteger + 48 + (16 * nPoints) + 16 + (8 * nPoints) + 8 bigEndian: false


]

{ #category : #'accessing - records' }
MultiPointZShape >> mMinForShapeAtOffset: anInteger [ 
	"answer the mMin value of the shape whose record starts at Byte anInteger "
	"Note: X = 40 + (16 * NumPoints); Y = X + 16 + (8 * NumPoints)"
	| nPoints |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at anInteger + 40 + 8 = anInteger + 48"
	^ "shpBytes doubleAt:" self shpDoubleAt: anInteger + 48 + (16 * nPoints) + 16 + (8 * nPoints) bigEndian: false


]

{ #category : #'accessing - records' }
MultiPointZShape >> measuresFromShapeAtOffset: anInteger [ 
	"answer anArray with the measures (M values) for the shape whose record starts at Byte anInteger"
	"skip 8 Bytes for the Record Header + 4 for the Shape Type (18) + 32 Bytes 
	for the Bounding Box = 44"
	| nPoints ms mOffset |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	ms := Array new: nPoints.
	"anInteger + 8 -> skip header
	+ 40 + (16 * nPoints) -> X
	+ 16 + (8 * nPoints) -> Y
	+ 16 -> Marray"
"	mOffset := anInteger + 8 + 40 + (16 * nPoints) + 16 + (8 * nPoints) + 16."
	mOffset := anInteger + 80 + (24 * nPoints).	
	1
		to: nPoints
		do: [:i | ms at: i put: ("shpBytes doubleAt:" self shpDoubleAt: mOffset + ((i-1)*16) bigEndian: false)].
	^ ms
]

{ #category : #'accessing - records' }
MultiPointZShape >> multiPointsFromShapeAtOffset: anInteger [ 
	"answer a collection with the (B3DVector3) points in the shape whose 
	record starts at Byte anInteger"
	"points could be represented by B3DVector3. As I am not sure about 
	possible loss of precision, I avoided this. Replace the last Array 
	with:with:with: statement simply by ()@()@"

	| nPoints points offset zOffset |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at 44 + 4 = 48"
	points := OrderedCollection new: nPoints.
	offset := anInteger + 48.
	zOffset := offset + (16 * nPoints) + 16.
	"skip also zMin and zMax bytes (8+8)"
	"z values start at zOffset"
	1
		to: nPoints
		do: [:i | points
				addLast: (Array
						with: ("shpBytes doubleAt:" self shpDoubleAt: offset + (i - 1 * 16) bigEndian: false)
						with: ("shpBytes doubleAt:" self shpDoubleAt: offset + 8 + (i - 1 * 16) bigEndian: false)
						with: ("shpBytes doubleAt:" self shpDoubleAt: zOffset + (i - 1 * 16) bigEndian: false))].
	^ points asArray
]

{ #category : #'accessing - contents' }
MultiPointZShape >> shapes [
	"answer the receiver's data as anArray with Arrays (shape) with Arrays (x y z)"
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

{ #category : #'accessing - records' }
MultiPointZShape >> zMaxForShapeAtOffset: anInteger [ 
	"answer the zMax value of the shape whose record starts at Byte anInteger "
	"skip 8 Bytes for the Record Header + 4 for the Shape Type (18) + 32 
	for the Bounding Box = 44"
	| nPoints |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at 44 + 4 = 48"
	"skip also the zMin bytes (8)"
	^ "shpBytes doubleAt:" self shpDoubleAt: anInteger + 48 + (16 * nPoints) + 8 bigEndian: false
]

{ #category : #'accessing - records' }
MultiPointZShape >> zMinForShapeAtOffset: anInteger [ 
	"answer the zMin value of the shape whose record starts at Byte anInteger "
	"skip 8 Bytes for the Record Header + 4 for the Shape Type (18) + 32 
	for the Bounding Box = 44"
	| nPoints |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at 44 + 4 = 48"
	^ "shpBytes doubleAt:" self shpDoubleAt: anInteger + 48 + (16 * nPoints) bigEndian: false
]

{ #category : #'accessing - records' }
MultiPointZShape >> zMinMaxForShapeAtOffset: anInteger [ 
	"answer a zMin@zMax point for the shape whose record starts at Byte 
	anInteger "
	"skip 8 Bytes for the Record Header + 4 for the Shape Type (18) + 32  
	for the Bounding Box = 44"
	| nPoints pos |
	nPoints := self longAt: anInteger + 44 bigEndian: false.
	"4 Bytes for the NumPoints"
	"points start at 44 + 4 = 48"
	pos := anInteger + 48 + (16 * nPoints).
	^ ("shpBytes doubleAt:" self shpDoubleAt: pos bigEndian: false)
		@ "shpBytes doubleAt:" self shpDoubleAt: pos + 8 bigEndian: false
]
