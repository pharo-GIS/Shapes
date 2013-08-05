"
ColorSource is an abstract class. Subclasses should know how to translate a value into a Color
"
Class {
	#name : #ColorSource,
	#superclass : #Object,
	#category : #ColorLegend
}

{ #category : #'color schemes' }
ColorSource class >> colorSchemeDark: aColor shades: anInteger [ 
	"answer an array of anInteger colors from black to aColor."

	"Color showColors: (self colorSchemeDark: Color green shades: 16)"
	"Color showColors: (self colorSchemeDark: Color blue shades: 32)" 

	^ aColor darkShades: anInteger
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeDarkToLight: aColor shades: anInteger [ 
	"answer an array of size (2 * anInteger - 1) colors from black to aColor
	to white."
	"Color showColors: (self colorSchemeDarkToLight: Color green shades: 16)"
	"Color showColors: (self colorSchemeDarkToLight: Color blue shades: 32)"

	| dark |
	dark := (aColor darkShades: anInteger) asOrderedCollection.
	dark removeLast.
	^ dark asArray , (aColor lightShades: anInteger) reversed
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeHue: aNumber grades: anInteger [ 
	"answer a collection of Colors with hue aNumber, with anInteger saturation values"

	"Color showColors: (self colorSchemeHue: Color green hue grades: 16)"
	"Color showColors: (self colorSchemeHue: Color blue hue grades: 32)" 

	| c brightness sats cubeColors |
	cubeColors := OrderedCollection new.
	brightness := 1.0.
	sats := anInteger * brightness.
	1 to: sats asInteger
		do: 
			[:s | 
			| saturation |
			saturation := s asFloat / sats.
			(Array with: aNumber) do: 
					[:h | 
					| hue |
					hue := h "asFloat / 360.0 -> that's VW".
					c := Color h: hue
								s: saturation
								v: brightness.
					cubeColors add: c]].
	^cubeColors
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeHues: aCollection grades: anInteger [ 
	"answer a collection of ColorValues with hues from aCollection, each with anInteger saturation values"

	"Color showColors: (self colorSchemeHues: #(120 60) grades: 16) "
	"Color showColors: (self colorSchemeHues: {Color orange hue. Color green hue. Color red hue. Color blue hue} grades: 16) "

	| c brightness sats cubeColors |
	cubeColors := OrderedCollection new.
	brightness := 1.0.
	sats := anInteger * brightness.
	1 to: sats asInteger
		do: 
			[:s | 
			| saturation |
			saturation := s asFloat / sats.
			aCollection do: 
					[:h | 
					| hue |
					hue := h "asFloat / 360.0 -> that's VW".
					c := Color 
								h: hue
								s: saturation
								v: brightness.
					cubeColors add: c]].
	^cubeColors
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeLight: aColor shades: anInteger [ 
	"answer an array of anInteger colors from white to aColor."

	"Color showColors: (self colorSchemeLight: Color green shades: 16)"
	"Color showColors: (self colorSchemeLight: Color blue shades: 32)" 

	^ aColor lightShades: anInteger
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeLightToDark: aColor shades: anInteger [ 
	"answer an array of size (2 * anInteger - 1) colors from white to aColor
	to black."
	"Color showColors: (self colorSchemeLightToDark: Color green shades: 16)"
	"Color showColors: (self colorSchemeLightToDark: Color blue shades: 32)"

	| light |
	light := (aColor lightShades: anInteger) asOrderedCollection.
	light removeLast.
	^ light asArray , (aColor darkShades: anInteger) reversed
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeMix: color1 with: color2 shades: anInteger [ 
	"answer a collection of Colors mixing color1 and color2"

	"Color showColors: (self colorSchemeMix: Color red with: Color blue shades: 20 )" 
	"Color showColors: (self colorSchemeMix: Color lightRed with: Color lightBlue shades: 20 )" 

	^color1 mix: color2 shades: anInteger
]

{ #category : #'color schemes' }
ColorSource class >> colorSchemeMixAll: colors shadesPerCombi: anInteger [ 
	"answer a collection of Colors mixing all Colors in colors (in given order) with for each pair anInteger intervals"
	"the duplicate colors at end/begin of series are removed. To compensate take anInteger+1 shades for all but the last series"
	"Color showColors: (self colorSchemeMixAll: { Color red. Color green. Color blue. Color yellow. Color red} shades: 10 )"
	"Color showColors: (self colorSchemeMixAll: { Color lightRed. Color green. Color lightBlue. Color lightYellow. Color lightRed} shades: 5 )"
	| result lastIndex |
	colors size < 2
		ifTrue: [^ #()].
	result := OrderedCollection new: anInteger * (colors size - 1).
	lastIndex := colors size - 1.
	1
		to: lastIndex
		do: [:i | 
			| series | 
			i = lastIndex
				ifTrue: [series := (colors at: i)
								mix: (colors at: i + 1)
								shades: anInteger]
				ifFalse: [series := ((colors at: i)
								mix: (colors at: i + 1)
								shades: anInteger + 1) asOrderedCollection.
					series removeLast].
			result addAll: series].
	^ result
]

{ #category : #'color schemes' }
ColorSource class >> colorWheelFor: color shades: anInteger [ 
	"An array of anInteger colors around the color wheel starting at color and ending all the way around the hue space just before color.  Array is of length thisMany. Brightness and saturation are kept constant"

	"Color showColors: (self colorWheelFor: Color red shades: 20 )" 
	"Color showColors: (self colorWheelFor: Color lightRed shades: 20 )" 

	^color wheel: anInteger
]

{ #category : #'instance creation' }
ColorSource class >> mapValues: aCollection colors: colorColl [ 
	"self mapValues: {'een'. 'twee'. 'drie'} colors: {Color red. Color green. Color blue} "

	^ ColorSourceNominal new
		mapValues: aCollection
		colors: colorColl
]

{ #category : #'instance creation' }
ColorSource class >> mapValues: aCollection colors: colorColl labels: labelColl [
	"ColorLegendMorph onLegend: 
	(self mapValues: {'een'. 'twee'. 'drie'} colors: {Color red. Color green. Color blue} labels: #('eerste' 'tweede' 'derde') )"

	^ ColorSourceNominal new
		mapValues: aCollection
		colors: colorColl
		labels: labelColl
]

{ #category : #'instance creation' }
ColorSource class >> mappedFrom: min step: binWidth n: anInteger colors: aCollection [
	"self mappedFrom: 0 step: 100 n: 10 lightShadesFor: 240"
	^ ColorSourceInterval new
		mappedFrom: min
		step: binWidth
		n: anInteger
		colors: aCollection
]

{ #category : #translation }
ColorSource >> colorFor: anObject [
	^self subclassResponsibility
]

{ #category : #translation }
ColorSource >> colorForAll: aCollection [
	^aCollection collect: [:each | self colorFor: each]
]
