"
Common superclass of all vector maps (derived from ESRI shapefiles, coverages, etc.)
"
Class {
	#name : #VectorMapMorph,
	#superclass : #Morph,
	#category : #'Shp-Morphic'
}

{ #category : #testing }
VectorMapMorph >> isVectorMapMorph [
	"of course Morph should answer false..."
	^true
]
