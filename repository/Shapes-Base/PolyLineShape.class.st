"
PolyLineShape represents a PolyLine Type shape file.

From the official documentation:
A PolyLine is an ordered set of vertices that consists of one or more parts. A part is a connected sequence of two or more points. Parts may or may not be connected to one another. Parts may or may not intersect one another.

(For details, see class PolygonShape, as the organization of PolyLine shapes is identical to that of Polygon shapes)


"
Class {
	#name : #PolyLineShape,
	#superclass : #PolygonShape,
	#category : #'Shapes-Base'
}

{ #category : #'instance creation' }
PolyLineShape class >> fromVertsColl: aColl boundingBox: aRectangle [ 
	"create a complete PolyLineShape. Shapes may consist of multiple parts (that would be outline + holes vertices in case of a polygon shape)"


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

	^self new fromVertsColl: aColl boundingBox: aRectangle
]

{ #category : #accessing }
PolyLineShape class >> shapeType [
	^3
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

{ #category : #accessing }
PolyLineShape >> generalType [

	^'PolyLine'
]

{ #category : #testing }
PolyLineShape >> hasLines [
	^true
]

{ #category : #testing }
PolyLineShape >> hasPolygons [
	^false
]

{ #category : #displaying }
PolyLineShape >> polygonColor [
	"avoid polygons being filled with color (receiver does not define polygons!)"
	
	^nil
]
