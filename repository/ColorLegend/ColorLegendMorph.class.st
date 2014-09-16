"
ColorLegendMorph onLegend: EconetLevelSpec legendLevel3a.

Instance Variables
	items:		<Object>
	labels:		<Object>
	legend:		<Object>

items
	- xxxxx

labels
	- xxxxx

legend
	- xxxxx

"
Class {
	#name : #ColorLegendMorph,
	#superclass : #Morph,
	#instVars : [
		'legend',
		'items',
		'labels'
	],
	#category : #'ColorLegend-Morphic'
}

{ #category : #examples }
ColorLegendMorph class >> examples [

	"self onLegend: EconetLevelSpec legendLevel3a"
]

{ #category : #'instance creation' }
ColorLegendMorph class >> onLegend: aColorLegend [

	^(self new legend: aColorLegend) openInWorld
]

{ #category : #initialization }
ColorLegendMorph >> buildCondensedItemList [

	| cAndL |
	cAndL := legend colorsAndLabelsCondensed.
	items := cAndL key.
	labels := cAndL value
]

{ #category : #initialization }
ColorLegendMorph >> buildItemList [

	| cAndL |
	cAndL := legend colorsAndLabels.
	items := cAndL key.
	labels := cAndL value
]

{ #category : #drawing }
ColorLegendMorph >> drawOn: aCanvas [

	| n offset offX offY sizeY bStyle inset rSize txtSize font |
	super drawOn: aCanvas.

	n := items size.
	inset := 5.	"space between rectangles; inset from bounds; etc."
	offset := self bounds origin + (inset@inset).	
	offX := offset x.
	offY := offset y.
	sizeY := 15.
	rSize := 10.
	txtSize := self longestLabelSize * 6. "50."
	"adapt the size to number & size of items!"
	self extent: (3 * inset + rSize + txtSize) @ (inset * 2 + (n * sizeY)).
	bStyle := BorderStyle default.
	font := self smallFont.
	1 to: n do: [:i | | rect rOff |
		rOff := offX @ ((i-1) * sizeY + offY).
		rect := rOff extent: rSize@rSize.
		aCanvas fillRectangle: rect
						fillStyle: (items at: i)
						borderStyle: bStyle.
		aCanvas drawString: (labels at: i) at: rOff + ((rSize + inset) @ 0) font: font color: Color black

]
	
]

{ #category : #initialization }
ColorLegendMorph >> initialize [

	super initialize.
	self borderWidth: 0.
	self color: Color white
]

{ #category : #accessing }
ColorLegendMorph >> legend: aColorLegend [
	
	legend := aColorLegend.
"	self buildItemList."
	self buildCondensedItemList
]

{ #category : #accessing }
ColorLegendMorph >> longestLabelSize [
	"the size of the longest label (String)"

	| s |
	s := 0.
	labels do: [:each | s := s max: each size].
	^s
]

{ #category : #accessing }
ColorLegendMorph >> smallFont [
	^ (TextStyle named: 'Verdana') fontOfSize: 9
"	^ (TextStyle named: 'Accujen') fontOfSize: 9"
]
