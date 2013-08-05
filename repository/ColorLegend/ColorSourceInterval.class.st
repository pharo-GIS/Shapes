"
ColorSourceInterval takes a numerical value and answers the Color associated with the interval (bin) corresponding to this value. Assuming regular intervals here!
"
Class {
	#name : #ColorSourceInterval,
	#superclass : #ColorSource,
	#instVars : [
		'minimum',
		'binWidth',
		'colors',
		'underflow',
		'overflow'
	],
	#category : #ColorLegend
}

{ #category : #'color editing' }
ColorSourceInterval >> allColorsAlpha: aFloat [
	"replace all colors with colors with transparency aFloat"

	colors := colors collect: [:each | each alpha: aFloat]
]

{ #category : #private }
ColorSourceInterval >> binIndex: aNumber [ 
	^((aNumber - minimum) / binWidth) floor + 1
]

{ #category : #translation }
ColorSourceInterval >> colorFor: aNumber [

	| index |
	((index := self binIndex: aNumber) between: 1 and: colors size) 
		ifTrue: [^colors at: index].
	index < 1 ifTrue: [^underflow].
	^overflow
]

{ #category : #accessing }
ColorSourceInterval >> mappedFrom: min step: step n: anInteger colors: aCollection [ 
	minimum := min.
	binWidth := step.
	colors := aCollection asArray.
	underflow := overflow := Color veryLightGray
]
