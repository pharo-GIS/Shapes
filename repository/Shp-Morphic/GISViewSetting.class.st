"
GISViewSetting is just a holder of parameters defining the projection of a map

 Structure:
 aaLevel		<Integer> 				-- the level of anti-aliasing
 scaling			<Number> 				-- from map units to screen units
 transform		<MatrixTransform2x3>	-- the actual transform
 multiplier		<Number|nil>				-- optional number to multiply coordinates with (when the resolution is too small)
 geoOffset		<Point>					-- the coordinates of the upperleft corner of the map (xMin@yMax)
"
Class {
	#name : #GISViewSetting,
	#superclass : #Object,
	#instVars : [
		'aaLevel',
		'scaling',
		'transform',
		'multiplier',
		'geoOffset'
	],
	#category : #'Shp-Morphic'
}

{ #category : #accessing }
GISViewSetting >> aaLevel [
	^aaLevel
]

{ #category : #accessing }
GISViewSetting >> aaLevel: anInteger [
	aaLevel := anInteger
]

{ #category : #accessing }
GISViewSetting >> aaLevel: anInteger scaling: aFloat transform: aTransform multiplier: aNumberOrNil geoOffset: aPoint [
	aaLevel		:= anInteger.
	scaling		:= aFloat.
	transform	:= aTransform. 
	multiplier	:= aNumberOrNil.
	geoOffset	:= aPoint
]

{ #category : #accessing }
GISViewSetting >> geoOffset [
	^geoOffset
]

{ #category : #accessing }
GISViewSetting >> geoOffset: aPoint [
	geoOffset := aPoint
]

{ #category : #accessing }
GISViewSetting >> multiplier [
	^multiplier
]

{ #category : #accessing }
GISViewSetting >> multiplier: aNumber [
	multiplier := aNumber
]

{ #category : #accessing }
GISViewSetting >> scaling [
	^scaling
]

{ #category : #accessing }
GISViewSetting >> scaling: aNumber [
	scaling := aNumber
]

{ #category : #accessing }
GISViewSetting >> transform [
	^transform
]

{ #category : #accessing }
GISViewSetting >> transform: aTransform [
	transform := aTransform
]
