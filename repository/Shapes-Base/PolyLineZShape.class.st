"
PolyLineZShape represents a PolyLineZ Type shape file.

Structure is identical to PolygonZShape
"
Class {
	#name : #PolyLineZShape,
	#superclass : #PolygonZShape,
	#category : #'Shapes-Base'
}

{ #category : #accessing }
PolyLineZShape class >> shapeType [
	^13
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
PolyLineZShape >> generalType [

	^'PolyLine'
]

{ #category : #testing }
PolyLineZShape >> hasLines [
	^true
]

{ #category : #testing }
PolyLineZShape >> hasPolygons [
	^false
]

{ #category : #displaying }
PolyLineZShape >> polygonColor [
	"avoid polygons being filled with color (receiver does not define polygons!)"
	
	^nil
]
