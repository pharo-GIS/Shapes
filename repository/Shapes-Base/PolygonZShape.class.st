"
PolygonZShape represents a PolygonZ type of Shapefile. It contains Z values and (optional) measures M


Position		Field			Value		Type	Number		ByteOrder
Byte 0 		Shape Type 		15 			Integer 	1 			Little
Byte 4 		Box 			Box 		Double 	4 			Little
Byte 36 		NumParts 		NumParts 	Integer 	1 			Little
Byte 40 		NumPoints 		NumPoints 	Integer 	1 			Little
Byte 44 		Parts 			Parts 		Integer 	NumParts 	Little
Byte X 		Points 			Points 		Point 	NumPoints 	Little
Byte Y 		Zmin 			Zmin 		Double 	1 			Little
Byte Y + 8 	Zmax 			Zmax 		Double 	1 			Little
Byte Y + 16 Zarray 			Zarray 		Double 	NumPoints 	Little
Byte Z* 		Mmin 			Mmin 		Double 	1 			Little
Byte Z+8* 	Mmax 			Mmax 		Double 	1 			Little
Byte Z+16* 	Marray 		Marray 	Double 	NumPoints 	Little
Note: X = 44 + (4 * NumParts), Y = X + (16 * NumPoints), Z = Y + 16 + (8 * NumPoints)
* optional

"
Class {
	#name : #PolygonZShape,
	#superclass : #PolygonShape,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
PolygonZShape class >> fromOutlineVertsColl: vertsColl boundingBox: aRectangle [

	^self error: 'not yet implemented'
]

{ #category : #'instance creation' }
PolygonZShape class >> fromVertsColl: aColl boundingBox: aRectangle [

	^self error: 'not yet implemented'
]

{ #category : #accessing }
PolygonZShape class >> shapeType [
	^15
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

{ #category : #'accessing - contents' }
PolygonZShape >> shapes [
	"answer the receiver's data as anArray with Arrays with Points"
	| n shapes |
	n := self numberOfShapes.
	shapes := Array new: n.
	1
		to: n
		do: [:i | shapes
				at: i
				put: (self verticesByPartsForShapeIndex: i)].
	^ shapes
]

{ #category : #'accessing - shape by index' }
PolygonZShape >> vertices2DByPartsForShapeIndex: anInteger [ 
	"extract collections of vertices for all parts of shape index anInteger"
	"that's precisely what the superclass does (ignoring Z values)"

	^super verticesByPartsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonZShape >> verticesByPartsForShapeAtOffset: anInteger [ 
	"answers anArray with vertices (each vertex anArray(x y z)) organised per part (in an Array).
	Thus, anArray with Arrays with Arrays"
	"alternatively, create B3DVector3s instead of Arrays to represent 3D points"
	
	| offsets nRings n vOffset ends result zOffset |
	offsets := self partsOffsetsForShapeAtOffset: anInteger.
	n := self numPointsForShapeAtOffset: anInteger.
	nRings := offsets size.
	ends := OrderedCollection new: nRings.
	1
		to: nRings - 1
		do: [:i | ends addLast: (offsets at: i + 1)
					- 1].
	ends addLast: n.
	ends := ends asArray.
	result := Array new: nRings.
	vOffset := anInteger + 52 + (4 * nRings).
	"add the 8-byte header + the 4-byte shapeType + 4*8-byte Box + 4-byte 
	numParts + 4-byte numPoints + nRings*4-byte"
	zOffset := vOffset + (16 * n) + 16. "skip zMin and zMax"
	1
		to: nRings
		do: [:i | 
			| vertices | 
			vertices := OrderedCollection new: (ends at: i)
							+ 1
							- (offsets at: i).
			(offsets at: i)
				to: (ends at: i)
				do: [:j | vertices addLast: (Array 
							with: ("shpBytes doubleAt:" self shpDoubleAt: vOffset + (j - 1 * 16) bigEndian: false)
							with: ("shpBytes doubleAt:" self shpDoubleAt: vOffset + (j - 1 * 16) + 8 bigEndian: false)
							with: ("shpBytes doubleAt:" self shpDoubleAt: zOffset + (j - 1 * 8) bigEndian: false))].
			result at: i put: vertices asArray].
	^ result
]

{ #category : #'accessing - records' }
PolygonZShape >> zMaxForShapeAtOffset: anInteger [ 
	"answer the zMax value of the shape whose record starts at Byte anInteger "

	| nPoints nParts offset |
	nParts := shpBytes longAt: anInteger + 8 + 36 bigEndian: false.
	nPoints := shpBytes longAt: anInteger + 8 + 40 bigEndian: false.
	offset := anInteger + 8 + 44 + (4 * nParts) + (16 * nPoints).
	^ "shpBytes doubleAt:" self shpDoubleAt: offset + 8 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonZShape >> zMaxForShapeIndex: anInteger [
	^self zMaxForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonZShape >> zMinForShapeAtOffset: anInteger [ 
	"answer the zMin value of the shape whose record starts at Byte anInteger "

	| nPoints nParts offset |
	nParts := shpBytes longAt: anInteger + 8 + 36 bigEndian: false.
	nPoints := shpBytes longAt: anInteger + 8 + 40 bigEndian: false.
	offset := anInteger + 8 + 44 + (4 * nParts) + (16 * nPoints).
	^ "shpBytes doubleAt:" self shpDoubleAt: offset bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonZShape >> zMinForShapeIndex: anInteger [
	^self zMinForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonZShape >> zMinMaxForShapeAtOffset: anInteger [ 
	"answer the zMin@zMax value of the shape whose record starts at Byte anInteger "

	| nPoints nParts offset |
	nParts := shpBytes longAt: anInteger + 8 + 36 bigEndian: false.
	nPoints := shpBytes longAt: anInteger + 8 + 40 bigEndian: false.
	offset := anInteger + 8 + 44 + (4 * nParts) + (16 * nPoints).
	^ ("shpBytes doubleAt:" self shpDoubleAt: offset bigEndian: false) 
	@ ("shpBytes doubleAt:" self shpDoubleAt: offset + 8 bigEndian: false)
]

{ #category : #'accessing - shape by index' }
PolygonZShape >> zMinMaxForShapeIndex: anInteger [
	^self zMinMaxForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]
