"
PolygonShape represents a Polygon Type shape file.

Excerpts from the documentation:

A polygon consists of one or more rings. A ring is a connected sequence of four or more points that form a closed, non-self-intersecting loop. A polygon may contain multiple outer rings. The order of vertices or orientation for a ring indicates which side of the ring is the interior of the polygon. The neighborhood to the right of an observer walking along the ring in vertex order is the neighborhood inside the polygon. Vertices of rings defining holes in polygons are in a counterclockwise direction. Vertices for a single, ringed polygon are, therefore, always in clockwise order. The rings of a polygon are referred to as its parts.

The following are important notes about Polygon shapes.
The rings are closed (the first and last vertex of a ring MUST be the same). The order of rings in the points array is not significant. Polygons stored in a shapefile must be clean. A clean polygon is one that
1. Has no self-intersections. This means that a segment belonging to one ring may not intersect a segment belonging to another ring. The rings of a polygon can touch each other at vertices but not along segments. Colinear segments are considered intersecting.
2. Has the inside of the polygon on the ""correct"" side of the line that defines it. The neighborhood to the right of an observer walking along the ring in vertex order is the inside of the polygon. Vertices for a single, ringed polygon are, therefore, always in clockwise order. Rings defining holes in these polygons have a counterclockwise orientation. ""Dirty"" polygons occur when the rings that define holes in the polygon also go clockwise, which causes overlapping interiors.


Position		Field			Value		Type	Number		ByteOrder
Byte 0 		Shape Type 	5 			Integer 	1 			Little
Byte 4 		Box 			Box 		Double 	4 			Little
Byte 36 	NumParts 		NumParts 	Integer 	1 			Little
Byte 40 	NumPoints 		NumPoints 	Integer 	1 			Little
Byte 44 	Parts 			Parts 		Integer 	NumParts 	Little
Byte X 		Points 			Points 		Point 	NumPoints 	Little
Note: X = 44 + 4 * NumParts


"
Class {
	#name : #PolygonShape,
	#superclass : #ShapeMap,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
PolygonShape class >> fromOutlineVertsColl: vertsColl boundingBox: aRectangle [ 
	"create a complete PolygonShape using only vertices & boundingBox info"

	"Only the outerboundary of each polygon is used"

	"(
	self fromOutlineVertsColl:  		
				{ 
				{1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 .
				{1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 50 .
				{1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (25@0) .
				{1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (50@0) .
				}
		boundingBox: (0@0 extent: 120@120)
	)
	drawForm
		"

	^self new fromOutlineVertsColl: vertsColl boundingBox: aRectangle
]

{ #category : #'instance creation' }
PolygonShape class >> fromVertsColl: aColl boundingBox: aRectangle [ 
	"create a complete PolygonShape using outline + holes vertices & boundingBox info"

	"per polygon a collection with 1 or more point-collections, making up its outerboundary AND any holes"
	"ArcView expects the polygon to be CLOSED (last vertex = first vertex)"

	"(
	self fromVertsColl:  		
				{ 
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20. } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 50.  {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} reversed * 25 + (35@35). } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (25@0). } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (50@0). } .
				}
		boundingBox: (0@0 extent: 120@120)
	)
	drawForm"

	"(
	self fromVertsColl:  		
				{ 
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20. } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 50. } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (25@0). } .
				{ {1.0@1.0. 1.0@2.0. 2.0@2.0. 2.0@1.0. 1.0@1.0.} * 20 + (50@0). } .
				}
		boundingBox: (0@0 extent: 120@120)
	)
	drawForm"

	"(PolygonShape fromVertsColl: (Array 
					with: (Array with: (Array with:1@100 with:  100@100  with: 100@1 with: 1@1 with:1@100  ) 
									with: (Array with:30@60 with:  60@60  with: 60@30 with: 30@30 with:30@60  ) reversed )
					with: (Array with: (Array with: 900@1000 with:  1000@1000  with: 1000@900 with: 900@900 with: 900@1000 ) ) )
					boundingBox: (Rectangle origin: 1@1 corner: 1000@1000) ) copyToFile "

	^self new fromVertsColl: aColl boundingBox: aRectangle
]

{ #category : #accessing }
PolygonShape class >> polygonClass [
	"answer the class representing the kind of polygons that my instances' shapes can be converted into" 

	^Smalltalk at: #SimplePolygon ifAbsent: [nil]
]

{ #category : #accessing }
PolygonShape class >> shapeType [
	^5
]

{ #category : #converting }
PolygonShape >> asSimplePolygons [
	"convert the contents of the Polygon Shape file into aCollection of SimplePolygons"
	"Expected functionality:
		#vertices: (setting the outer-vertices)
		#vertices
		#userID: (the record number in the shape is stored as userID)
		#hole (answering aCollection of other polygons representing the holes
		#absContainsPoint: (point-in-polygon test for outer boundary)"
	"when a single shape contains multiple (outer) rings, add only the first to the regular collection of SimplePolygons.
	This way, the index of the shape is preserved in the index of the SimplePolygon. Answer the collection of SimplePolygons,
	with any additional outer ring appended to the end of the collection (after index = numberOfShapes) " 

	"=> NB a thorough check of the spec is needed here: can we really have two outerboundaries for a single polygon-shape? "

	"(ShapeMap fromFile: 'd:\etarcview\giovanna\uso_corr.shp') asSimplePolygons"			
		
	"1 to: self numberOfShapes
		do: [:i | (self numPartsForShapeIndex: i) > 1 ifTrue: [result addLast: i]]. "

	| n polygons polygonClass additionalPolys |
	polygonClass := self class polygonClass.	
	polygonClass isNil ifTrue: [^nil].
	n := self numberOfShapes.
	polygons := OrderedCollection new: n + 100.
	additionalPolys := OrderedCollection new.
	1 to: self numberOfShapes
		do: 
			[:i | 
			| arcs newPolys bb |
			arcs := self verticesByPartsForShapeIndex: i.
			bb := self boundingBoxForShapeIndex: i.
			newPolys := arcs collect: [:each | polygonClass vertices: each].
			arcs size > 1 
				ifFalse: 
					[| newP |
					newP := newPolys first.
					newP userID: i.
					newP boundingBox: bb.
					polygons addLast: newP]
				ifTrue: 
					[| holes outers theOuter |
					holes := OrderedCollection new.
					outers := OrderedCollection new.
					newPolys do: 
							[:each | 
							each isPositive 
								ifTrue: [outers addLast: each]
								ifFalse: [holes addLast: each]].
					outers size > 1 
						ifTrue: 
							[holes isEmpty 
								ifFalse: 
									[holes do: 
											[:hole | 
											| testPoint index |
											testPoint := hole vertices first.
											index := outers findFirst: [:ring | ring absContainsPoint: testPoint].
											"assign the holes to the right outer ring" 
											index = 0 
												ifTrue: [self halt	"skip the hole --- dont know why this happens.."]
												ifFalse: 
													[theOuter := outers at: index.
													theOuter holes addLast: hole]]].
							outers do: [:each | each userID: i]. "dont set boundingBoxes here; things may not be what I think they are.." 
							polygons addLast: outers first.
							2 to: outers size do: [:index | additionalPolys addLast: (outers at: index)]]
						ifFalse: 
							[theOuter := outers first.	"only one outer-ring, so all holes should go into this ring"
							theOuter userID: i.
							theOuter boundingBox: bb.
							theOuter holes addAll: holes.
							polygons addLast: theOuter]]].
	additionalPolys isEmpty ifFalse: ["self halt. just to make you aware of this complication (that's not handled well)"].
	^polygons , additionalPolys
]

{ #category : #converting }
PolygonShape >> asSimpleVectorLandscape [
	"create polygon objects and answer a SimpleVectorLandscape with these polygons"
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\uso_corr.shp') asSimpleVectorLandscape"			

	| landscape |
	landscape := (Smalltalk at: #SimpleVectorLandscape ifAbsent: [^nil]) polygons: self asSimplePolygons.
	landscape boundingBox: self boundingBox.
	^landscape
]

{ #category : #'accessing - records' }
PolygonShape >> boundingBoxForShapeAtOffset: anInteger [ 
	^Rectangle origin: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 12 bigEndian: false) 
				@ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 20 bigEndian: false)
		corner: ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 28 bigEndian: false) 
				@ ("shpBytes doubleAt:" self shpDoubleAt: anInteger + 36 bigEndian: false)
]

{ #category : #'accessing - shape by index' }
PolygonShape >> boundingBoxForShapeIndex: anInteger [ 
	"extract the boundingBox for shape record anInteger"
	^ self
		boundingBoxForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #editing }
PolygonShape >> fromOutlineVertsColl: vertsColl boundingBox: aRectangle [ 
	"create a complete PolygonShape using only vertices & boundingBox info"

	"current limitation: only one collection of vertices per polygon/shape (so, only the outerboundary is handled)"

	"ShapeMorph new shapeMap: (ShapeMap fromFile: 'd:\squeak3\lgn4_clip_legenda2.shp')"

	"(PolygonShape fromOutlineVertsColl: (Array 
					with: (Array with:1@100 with:  100@100  with: 100@1 with: 1@1 with:1@100  )
					with: (Array with: 900@1000 with:  1000@1000  with: 1000@900 with: 900@900 with: 900@1000 ) )  
					boundingBox: (Rectangle origin: 1@1 corner: 1000@1000) ) copyToFile "

	| n numParts numPoints pointByteL basicRecHeaderByteL basicRecByteL totByteL fileByteL indexByteL stream recordContentByteL readStream offsetByte |
	n := vertsColl size.
	numParts := Array new: n withAll: 1.	"only 1 ring per shape"
	numPoints := vertsColl asArray collect: [:each | each size].	"number of vertices per shape"
	pointByteL := numPoints collect: [:each | each * 16].	"each point = 2 * 8 Bytes"
	basicRecHeaderByteL := 8.	"header: 4 + 4"
	basicRecByteL := 44.	" subheader: 4 + (4 * 8 bb) + 4 + 4 "
	recordContentByteL := Array new: n.
	1 to: n
		do: 
			[:i | 
			recordContentByteL at: i
				put: basicRecByteL + ((numParts at: i) * 4) + (pointByteL at: i)].	"record content in bytes"
	totByteL := recordContentByteL sum + (basicRecHeaderByteL * n).	"and with the fixed record header bytes added"
	fileByteL := 100 + totByteL.
	shpBytes := ByteArray new: fileByteL.
	indexByteL := 100 + (n * 8).	"same header, with 8 bytes per record/shape"
	shxBytes := ByteArray new: indexByteL.

	"fill the header"
	self fileCode: 9994.
	self fileLength: fileByteL / 2.	"in Words, not Bytes"
	self version: 1000.	"always 1000"
	self shapeType: self class shapeType.	"the Polygon type"
	self xMin: aRectangle origin x asFloat.
	self xMax: aRectangle corner x asFloat.
	self yMin: aRectangle origin y asFloat.
	self yMax: aRectangle corner y asFloat.

	"copy the header to shxBytes"
	1 to: 100 do: [:i | shxBytes at: i put: (shpBytes at: i)].
	shxBytes 
		longAt: 25
		put: indexByteL / 2
		bigEndian: true.	"but adjust file length!"

	"fill the records"
	stream := WriteStream on: shpBytes.
	readStream := ReadStream on: (shpBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	1 to: n
		do: 
			[:index | 
			"write record header"

			| xMin xMax yMin yMax nPa nPo start |
			self 
				on: stream
				putNextULong: index
				bigEndian: true.	"4 Bytes (Record Number)"
			self 
				on: stream
				putNextULong: (recordContentByteL at: index) / 2
				bigEndian: true.	"4 Bytes (Record Contents in 16bits words)"

			"write record contents"
			self 
				on: stream
				putNextULong: self class shapeType
				bigEndian: false.	"4 Bytes (ShapeType)"
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
			self 
				on: stream
				putNextDouble: xMin asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: yMin asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: xMax asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: yMax asFloat
				bigEndian: false.	"8 Bytes"
			nPa := numParts at: index.
			self 
				on: stream
				putNextULong: nPa
				bigEndian: false.	"4 Bytes (numParts)"
			nPo := numPoints at: index.
			self 
				on: stream
				putNextULong: nPo
				bigEndian: false.	"4 Bytes (tot number of points)"
			nPa timesRepeat: 
					[self 
						on: stream
						putNextULong: 0
						bigEndian: false].	"numParts * 4 Bytes"
			(vertsColl at: index) do: 
					[:vert | 
					self 
						on: stream
						putNextDouble: vert x asFloat
						bigEndian: false.
					self 
						on: stream
						putNextDouble: vert y asFloat
						bigEndian: false]].
	shpBytes := stream contents.

	"fill the index bytes"
	stream := WriteStream on: shxBytes.
	readStream := ReadStream on: (shxBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	offsetByte := 101.
	1 to: n
		do: 
			[:i | 
			self 
				on: stream
				putNextULong: (offsetByte - 1) / 2
				bigEndian: true.
			self 
				on: stream
				putNextULong: (recordContentByteL at: i) / 2
				bigEndian: true.
			offsetByte := offsetByte + 8 + (recordContentByteL at: i)].
	shxBytes := stream contents
]

{ #category : #editing }
PolygonShape >> fromVertsColl: aColl boundingBox: aRectangle [ 
	"create a complete PolygonShape using outline + holes vertices & boundingBox info"

	"per polygon a collection with 1 or more point-collections, making up its outboundary and any holes"

	"(PolygonShape fromVertsColl: (Array 
					with: (Array with: (Array with:1@100 with:  100@100  with: 100@1 with: 1@1 with:1@100  ) 
									with: (Array with:30@60 with:  60@60  with: 60@30 with: 30@30 with:30@60  ) reversed )
					with: (Array with: (Array with: 900@1000 with:  1000@1000  with: 1000@900 with: 900@900 with: 900@1000 ) ) )
					boundingBox: (Rectangle origin: 1@1 corner: 1000@1000) ) copyToFile "

	| n numParts numPoints pointByteL basicRecHeaderByteL basicRecByteL totByteL fileByteL indexByteL stream recordContentByteL readStream offsetByte shType |
	n := aColl size.	"number of shapes"
	numParts := aColl asArray collect: [:each | each size].	"1 or more rings per shape"
	numPoints := aColl asArray 
				collect: [:rings | rings inject: 0 into: [:sum :each | sum + each size]].	"number of vertices per shape (in one or more rings)"
	pointByteL := numPoints collect: [:each | each * 16].	"each point = 2 * 8 Bytes"
	basicRecHeaderByteL := 8.	"header: 4 + 4"
	basicRecByteL := 44.	" subheader: 4 + (4 * 8 bb) + 4 + 4 "
	recordContentByteL := Array new: n.
	1 to: n
		do: 
			[:i | 
			recordContentByteL at: i
				put: basicRecByteL + ((numParts at: i) * 4) + (pointByteL at: i)].	"record content in bytes"
	totByteL := recordContentByteL sum + (basicRecHeaderByteL * n).	"and with the fixed record header bytes added"
	fileByteL := 100 + totByteL.
	shpBytes := ByteArray new: fileByteL.
	indexByteL := 100 + (n * 8).	"same header, with 8 bytes per record/shape"
	shxBytes := ByteArray new: indexByteL.

	"fill the header"
	self fileCode: 9994.
	self fileLength: fileByteL / 2.	"in Words, not Bytes"
	self version: 1000.				"always 1000"
	shType := self class shapeType.	"ask the class"
	self shapeType: shType.			"the Polygon type"
	self xMin: aRectangle origin x asFloat.
	self xMax: aRectangle corner x asFloat.
	self yMin: aRectangle origin y asFloat.
	self yMax: aRectangle corner y asFloat.

	"copy the header to shxBytes"
	1 to: 100 do: [:i | shxBytes at: i put: (shpBytes at: i)].
	shxBytes 
		longAt: 25
		put: indexByteL / 2
		bigEndian: true.	"but adjust file length!"

	"fill the records"
	stream := WriteStream on: shpBytes.
	readStream := ReadStream on: (shpBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	1 to: n
		do: 
			[:index | 
			"write record header"

			| xMin xMax yMin yMax nPa nPo start rings |
			self 
				on: stream
				putNextULong: index
				bigEndian: true.	"4 Bytes (Record Number)"
			self 
				on: stream
				putNextULong: (recordContentByteL at: index) / 2
				bigEndian: true.	"4 Bytes (Record Contents in 16bits words)"

			"write record contents"
			self 
				on: stream
				putNextULong: shType
				bigEndian: false.	"4 Bytes (ShapeType)"
			"calculate and write boundingBox"
			rings := aColl at: index.	"collection of rings"
			start := rings first first.
			xMin := xMax := start x.
			yMin := yMax := start y.
			rings do: 
					[:ring | 
					ring do: 
							[:each | 
							xMin := xMin min: each x.
							xMax := xMax max: each x.
							yMin := yMin min: each y.
							yMax := yMax max: each y]].
			self 
				on: stream
				putNextDouble: xMin asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: yMin asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: xMax asFloat
				bigEndian: false.	"8 Bytes"
			self 
				on: stream
				putNextDouble: yMax asFloat
				bigEndian: false.	"8 Bytes"
			nPa := numParts at: index.
			self 
				on: stream
				putNextULong: nPa
				bigEndian: false.	"4 Bytes (numParts)"
			nPo := numPoints at: index.
			self 
				on: stream
				putNextULong: nPo
				bigEndian: false.	"4 Bytes (tot number of points)"
			nPa > 1 
				ifFalse: 
					[self 
						on: stream
						putNextULong: 0
						bigEndian: false	"numParts (=1) * 4 Bytes"]
				ifTrue: 
					[| ringOffsets ringSizes |
					ringSizes := (rings collect: [:each | each size]) asArray.	"ring sizes"
					2 to: nPa
						do: [:i | ringSizes at: i put: (ringSizes at: i - 1) + (ringSizes at: i)].	"cumulative"
					ringOffsets := #(0 ) , (ringSizes copyFrom: 1 to: ringSizes size - 1).	"translate into offsets"
					ringOffsets do: 
							[:each | 
							self 
								on: stream
								putNextULong: each
								bigEndian: false]].	"numParts * 4 Bytes"
			rings do: 
					[:ring | 
					ring do: 
							[:vert | 
							self 
								on: stream
								putNextDouble: vert x asFloat
								bigEndian: false.
							self 
								on: stream
								putNextDouble: vert y asFloat
								bigEndian: false]]].
	shpBytes := stream contents.

	"fill the index bytes"
	stream := WriteStream on: shxBytes.
	readStream := ReadStream on: (shxBytes copyFrom: 1 to: 100).
	100 timesRepeat: [stream nextPut: readStream next].
	offsetByte := 101.
	1 to: n
		do: 
			[:i | 
			self 
				on: stream
				putNextULong: (offsetByte - 1) / 2
				bigEndian: true.
			self 
				on: stream
				putNextULong: (recordContentByteL at: i) / 2
				bigEndian: true.
			offsetByte := offsetByte + 8 + (recordContentByteL at: i)].
	shxBytes := stream contents
]

{ #category : #accessing }
PolygonShape >> generalType [

	^'Polygon'
]

{ #category : #testing }
PolygonShape >> hasPolygons [
	^true
]

{ #category : #selecting }
PolygonShape >> indicesShapesWithMultipleParts [
	"answer a collection with the indices of shapes having more than one ring (part) - jmb, 5/4/2004"

	| result |
	result := OrderedCollection new: 100.
	1 to: self numberOfShapes
		do: [:i | (self numPartsForShapeIndex: i) > 1 ifTrue: [result addLast: i]].
	^result asArray
]

{ #category : #'accessing - records' }
PolygonShape >> numPartsForShapeAtOffset: anInteger [
	"anInteger is the byte number of the offset of the record holding polygon info"
	"numParts defines the number of rings in the polygon"

	^shpBytes longAt: anInteger + 8 + 36 bigEndian: false "add the 8-byte header + the 4-byte shapeType + (4 * 8-byte Box)"
]

{ #category : #'accessing - shape by index' }
PolygonShape >> numPartsForShapeIndex: anInteger [ 
	"extract the number of parts for shape record anInteger"

	^self 
		numPartsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> numPointsForShapeAtOffset: anInteger [
	"anInteger is the byte number of the offset of the record holding polygon info"
	"numPoints defines the TOTAL number of points (vertices) for all rings in the polygon"

	^shpBytes longAt: anInteger + 8 + 40 bigEndian: false "add the 8-byte header + the 4-byte shapeType + 4*8-byte Box + 4-byte numParts"
]

{ #category : #'accessing - shape by index' }
PolygonShape >> numPointsForShapeIndex: anInteger [ 
	"extract the number of points for shape record anInteger"
	"numPoints defines the TOTAL number of points (vertices) for all rings in the polygon"

	^self 
		numPointsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> partsOffsetsForShapeAtOffset: anInteger [ 
	"anInteger is the byte number of the offset of the record holding polygon info"
	"parts(Offsets) defines the offsets for all rings in the polygon. Use this info to retrieve vertices per ring"

	| start n result |
	start := anInteger + 8 + 44.	"add the 8-byte header + the 4-byte shapeType + 4*8-byte Box + 4-byte numParts + 4-byte numPoints"
	n := self numPartsForShapeAtOffset: anInteger.
	result := Array new: n.
	1 to: n do: [:i | result at: i put: 1 + (shpBytes longAt: (i - 1) * 4 + start bigEndian: false)].
	^result
]

{ #category : #'accessing - shape by index' }
PolygonShape >> partsOffsetsForShapeIndex: anInteger [ 
	"parts(Offsets) defines the offsets for all rings in the polygon. Use this info to retrieve vertices per ring"
	"NB offsets are relative to the start of the vertices (points) bytes. So the ring with offset 1 starts with the first x,y value"

	^ self partsOffsetsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - contents' }
PolygonShape >> shapes [
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

{ #category : #writing }
PolygonShape >> streamedShapesBytes [
	"create the shape data bytes by streaming" 
	"shpBytes copyFrom: 101 to: shpBytes size"
	"(ShapeMap fromFile: 'd:\etarcview\giovanna\navelli_cocullo.shp') shapesBytes "
"
Position		Field			Value		Type	Number		ByteOrder
Byte 0 		Shape Type 	5 			Integer 	1 			Little
Byte 4 		Box 			Box 		Double 	4 			Little
Byte 36 	NumParts 		NumParts 	Integer 	1 			Little
Byte 40 	NumPoints 		NumPoints 	Integer 	1 			Little
Byte 44 	Parts 			Parts 		Integer 	NumParts 	Little
Byte X 		Points 			Points 		Point 	NumPoints 	Little
Note: X = 44 + 4 * NumParts
"

	| stream source |
	source := self.	"to test, obtain data from the receiver. source is assumed to be a ShapeMap !!!"
	stream := WriteStream on: (ByteArray new: 10000).	"10000 bytes to start with"
	1 to: source numberOfShapes do: [:index |  | nPa nPo v | 
	"write record header"
	self on: stream putNextULong: index bigEndian: true.										"4 Bytes (Record Number)"	
	self on: stream putNextULong: (source recordSizeForShapeIndex: index) bigEndian: true.	"4 Bytes (Record Contents in 16bits words)"	

	"write record contents"
	self on: stream putNextULong: source shapeType bigEndian: false.			"4 Bytes (ShapeType)"
	self on: stream putNextDouble: (source xMinForShapeIndex: index) bigEndian: false.	"8 Bytes"
	self on: stream putNextDouble: (source yMinForShapeIndex: index) bigEndian: false.	"8 Bytes"
	self on: stream putNextDouble: (source xMaxForShapeIndex: index) bigEndian: false.	"8 Bytes"
	self on: stream putNextDouble: (source yMaxForShapeIndex: index) bigEndian: false.	"8 Bytes"
	nPa := source numPartsForShapeIndex: index.
	self on: stream putNextULong: nPa bigEndian: false.		"4 Bytes (numParts)".	
	nPo := source numPointsForShapeIndex: index.
	self on: stream putNextULong: nPo bigEndian: false.		"4 Bytes (tot number of points)".	
	nPa timesRepeat: [self on: stream putNextULong: 0 bigEndian: false].		"numParts * 4 Bytes"
	v := source verticesByPartsForShapeIndex: index. 
	v do: [:each | each do: [:vert | self on: stream putNextDouble: vert x bigEndian: false. self on: stream putNextDouble: vert y bigEndian: false]] 
	].

	^stream contents
]

{ #category : #'accessing - bytes' }
PolygonShape >> subHeaderBytesForShapeIndex: anInteger [
	"answer the Bytes of the shape record that appear between the actual header and the points collection"

	| offset |
	offset := (self byteOffsetForShapeAtIndex: anInteger) + 8. "skip the record header"
	^shpBytes copyFrom: offset
		to: offset - 1 + 44 + (4 * (self numPartsForShapeIndex: anInteger ) )
]

{ #category : #'accessing - bytes' }
PolygonShape >> subHeaderForShapeIndex: anInteger [
	"answer the data in the shape record that appear between the actual header and the points collection"


	| bytes all |
	bytes := self subHeaderBytesForShapeIndex: anInteger.
	all := OrderedCollection new.
	all addLast: (bytes longAt: 1 bigEndian: false).		"ShapeType"
	all addLast: (bytes doubleAt: 5 bigEndian: false).		"xMin"
	all addLast: (bytes doubleAt: 13 bigEndian: false).	"yMin"
	all addLast: (bytes doubleAt: 21 bigEndian: false).
	all addLast: (bytes doubleAt: 29 bigEndian: false).

	all addLast: (bytes longAt: 37 bigEndian: false).	"nr of parts"
	all addLast: (bytes longAt: 41 bigEndian: false).	"nr of points"

	1 to: (bytes size - 44) / 4 do: [:i |
			all addLast: (bytes longAt: 45 + ((i-1)*4) bigEndian: false)].	"each part takes 4 bytes (but the value seems to be always 0?)"

	^all asArray
]

{ #category : #writing }
PolygonShape >> testWriting [
	"answer the difference between a copy of the shapes-bytes and shapes-bytes generated by
	extracting data from the receiver and writing this data on a binary stream"

	| streamed copied n test |
	streamed := self streamedShapesBytes.
	copied := self shapesBytes.
	n := streamed size.
"	test := ByteArray new: n.
	1 to: n do: [:i | test at: i put: ((streamed at:i) = (copied at:i) ifFalse: [1] ifTrue: [0])].
"
	test := Dictionary new.
	1 to: n do: [:i | (streamed at:i) = (copied at:i) ifFalse: [test at: i put: ((streamed at:i) -> (copied at:i))]].

	^test
]

{ #category : #'accessing - shape by index' }
PolygonShape >> vertices2DByPartsForShapeIndex: anInteger [ 
	"extract collections of vertices for all parts of shape index anInteger"
	"identical to #verticesByPartsForShapeIndex: anInteger"

	^self 
		verticesByPartsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> verticesByPartsForShapeAtOffset: anInteger [ 
	| offsets nRings n vOffset ends result |
	offsets := self partsOffsetsForShapeAtOffset:anInteger. 
	n := self numPointsForShapeAtOffset: anInteger.
	nRings := offsets size.
	ends := OrderedCollection new: nRings.
	1 to: nRings - 1 do: [:i | ends addLast: ((offsets at: i + 1) - 1)].	"1 to: 0 do: [:i | self halt]"
	ends addLast: n.
	ends := ends asArray.
	result := Array new: nRings.
	vOffset := anInteger + 52 + (4 * nRings).	"add the 8-byte header + the 4-byte shapeType + 4*8-byte Box + 4-byte numParts + 4-byte numPoints + nRings*4-byte"
	1 to: nRings do: [:i | | vertices | vertices := OrderedCollection new: ((ends at: i) + 1 - (offsets at: i)).
		(offsets at: i) to: (ends at: i) do: [:j | vertices addLast: 
			("shpBytes doubleAt:" self shpDoubleAt: vOffset + (j - 1 * 16) bigEndian: false) 
			@ 
			("shpBytes doubleAt:" self shpDoubleAt: vOffset + (j - 1 * 16) + 8 bigEndian: false)].
		result at: i put: vertices asArray].
	^result
]

{ #category : #'accessing - shape by index' }
PolygonShape >> verticesByPartsForShapeIndex: anInteger [ 
	"extract collections of vertices for all parts of shape index anInteger"

	^self 
		verticesByPartsForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> xMaxForShapeAtOffset: anInteger [ 
	"xMax"
	^self shpDoubleAt: anInteger + 28 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonShape >> xMaxForShapeIndex: anInteger [ 
	"xMax in boundingBox of shape record anInteger"
	^ self
		xMaxForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> xMinForShapeAtOffset: anInteger [ 
	"xMin"
	^self shpDoubleAt: anInteger + 12 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonShape >> xMinForShapeIndex: anInteger [ 
	"xMin in boundingBox of shape record anInteger"
	^ self
		xMinForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> yMaxForShapeAtOffset: anInteger [ 
	"yMax"
	^self shpDoubleAt: anInteger + 36 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonShape >> yMaxForShapeIndex: anInteger [ 
	"yMax in boundingBox of shape record anInteger"
	^ self
		yMaxForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]

{ #category : #'accessing - records' }
PolygonShape >> yMinForShapeAtOffset: anInteger [ 
	"yMin"
	^self shpDoubleAt: anInteger + 20 bigEndian: false
]

{ #category : #'accessing - shape by index' }
PolygonShape >> yMinForShapeIndex: anInteger [ 
	"yMin in boundingBox of shape record anInteger"
	^ self
		yMinForShapeAtOffset: (self byteOffsetForShapeAtIndex: anInteger)
]
