"
ColorSourceNominal translates an object into a Color, simply by looking up this object as a key in its table (aDictionary). Alternative implementations could use an IdentityDictionary as the table, for a faster lookup of Symbols. 

Possible useful expressions for doIt or printIt.

Structure:
 table				<Dictionary>		-- keys are the objects, values the colors
 outOfRangeColor	<Color>			-- the Color of objects that are not in the table
 labelTable			<Dictionary>		-- keys are the objects, values the labels (Strings)


"
Class {
	#name : #ColorSourceNominal,
	#superclass : #ColorSource,
	#instVars : [
		'table',
		'outOfRangeColor',
		'labelTable',
		'outOfRangeLabel'
	],
	#category : #ColorLegend
}

{ #category : #'color editing' }
ColorSourceNominal >> allColorsAlpha: aFloat [
	"replace all colors in the ColorSource by colors with transparency aFloat"

	| newTable |
	newTable := Dictionary new: table size.
	table associationsDo: [:each | newTable at: each key put: (each value alpha: aFloat)].
	table := newTable
]

{ #category : #translation }
ColorSourceNominal >> colorFor: anObject [
	^table at: anObject ifAbsent: [outOfRangeColor]

]

{ #category : #accessing }
ColorSourceNominal >> colorsAndLabels [
	"answer a Colors -> labels association"

	"for the moment, ignore the out-of-range item"

	| colors labels |
	colors := OrderedCollection new.
	labels := OrderedCollection new.
	(labelTable isNil or: [labelTable isEmpty]) 
		ifTrue: 
			[table keysAndValuesDo: 
					[:k :v | 
					colors addLast: v.
					labels addLast: k printString]]
		ifFalse: 
			[table keysAndValuesDo: 
					[:k :v | 
					colors addLast: v.
					labels addLast: (labelTable at: k)]].
	^colors -> labels
]

{ #category : #accessing }
ColorSourceNominal >> colorsAndLabelsConcatenated [
	"answer a Colors -> labels association. When aColor occurs more than once, make it into a single item (concatenating the labels)"

	"for the moment, ignore the out-of-range item"

	| colors labels colorLabelDict |
	colors := OrderedCollection new.
	labels := OrderedCollection new.
	colorLabelDict := Dictionary new.
	(labelTable isNil or: [labelTable isEmpty]) 
		ifTrue: 
			[table keysAndValuesDo: 
					[:k :v | 
					(colorLabelDict includesKey: v) 
						ifTrue: 
							[colorLabelDict at: v put: (colorLabelDict at: v) , ' ' , k printString]
						ifFalse: [colorLabelDict at: v put: k printString]]]
		ifFalse: 
			[table keysAndValuesDo: 
					[:k :v | 
					(colorLabelDict includesKey: v) 
						ifTrue: 
							[colorLabelDict at: v put: (colorLabelDict at: v) , ', ' , (labelTable at: k)]
						ifFalse: [colorLabelDict at: v put: (labelTable at: k)]]].
	colorLabelDict keysAndValuesDo: 
			[:k :v | 
			colors addLast: k.
			labels addLast: v].
	^colors -> labels
]

{ #category : #accessing }
ColorSourceNominal >> colorsAndLabelsCondensed [
	"answer a Colors -> labels association. When aColor occurs more than once, make it into a single item (concatenating the labels).
	Remove also copies of the labels from a single item"

	"for the moment, ignore the out-of-range item"

	| colors labels colorLabelDict |
	colors := OrderedCollection new.
	labels := OrderedCollection new.
	colorLabelDict := Dictionary new.
	(labelTable isNil or: [labelTable isEmpty]) 
		ifTrue: 
			[table keysAndValuesDo: 
					[:k :v | 
					(colorLabelDict at: v ifAbsentPut: [Set new]) add: k printString]]
		ifFalse: 
			[table keysAndValuesDo: 
					[:k :v | 
					(colorLabelDict at: v ifAbsentPut: [Set new]) add: (labelTable at: k)]].
	colorLabelDict keysAndValuesDo: 
			[:k :v | 
			| stream |
			colors addLast: k.
			stream := WriteStream on: ''.
			v asArray do: [:each | stream nextPutAll: each]
				separatedBy: [stream nextPutAll: ', '].
			labels addLast: stream contents].
	^colors -> labels
]

{ #category : #accessing }
ColorSourceNominal >> mapValues: objColl colors: colorColl [ 
	"fill table with keys = objects from objColl and values = colors"
	objColl size > colorColl size
		ifTrue: [^self error: 'too few Colors provided'].
	table := Dictionary new: objColl size.
	1
		to: objColl size
		do: [:i | table
				at: (objColl at: i)
				put: (colorColl at: i)].
	outOfRangeColor := Color veryLightGray
]

{ #category : #accessing }
ColorSourceNominal >> mapValues: objColl colors: colorColl labels: labelColl [
	"fill table with keys = objects from objColl and values = colors"
	"fill labelTable with keys = objects from objColl and values = labels (Strings)"
	objColl size > colorColl size
		ifTrue: [^self error: 'too few Colors provided'].
	objColl size > labelColl size
		ifTrue: [^self error: 'too few labels provided'].
	table := Dictionary new: objColl size.
	labelTable := Dictionary new: objColl size.
	1
		to: objColl size
		do: [:i | table
				at: (objColl at: i)
				put: (colorColl at: i).
				labelTable
				at: (objColl at: i)
				put: (labelColl at: i)].
	outOfRangeColor := Color veryLightGray.
	outOfRangeLabel := 'out of range' 
]
