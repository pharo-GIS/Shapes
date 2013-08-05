"
ColorLegend translates Objects into Colors. It contains a ColorSource that translates a value into a Color, and an optional Block that defines how the Object is translated into a value. So it may be a two-step process, Object->value->Color. Without a Block, it's just value->Color.

Structure:
 source		<ColorSource>	-- translates a value into a Color
 block 		<BlockContext|nil>	-- translates an object into a value
"
Class {
	#name : #ColorLegend,
	#superclass : #Object,
	#instVars : [
		'source',
		'block'
	],
	#category : #ColorLegend
}

{ #category : #applications }
ColorLegend class >> corineLandUseLegend [
	"read a file with RGB (byte) values in format e.g. '230-000-077' and create a ColorLegend with these values"
	"self corineLandUseLegend"
	"self corineLandUseLegend storeOnFile"

	" needs work "

	| data gridCodeIndex rgbIndex colors values check |
"	data := CSVFileReader contentsOfFile: 'corine.csv' ."
	gridCodeIndex := 1.
	rgbIndex := 9.
	colors := OrderedCollection new.
	values := OrderedCollection new.
	check := OrderedCollection new.
	2 to: data size do: [:i | | rgb r g b |
		values addLast: ((data at: i) at: gridCodeIndex) asNumber.
		rgb := ((data at: i) at: rgbIndex) readStream.
		r:= (rgb upTo: $-) asNumber.
		g := (rgb upTo: $-) asNumber.
		b := (rgb next: 3) asNumber.
		check addLast: (Array with: r with: g with: b).
		colors addLast: (Color r: r g: g b: b range: 255)].
	^self mapValues: values colors: colors
	
]

{ #category : #examples }
ColorLegend class >> example [
	"self example"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 hue: (Color red hue).
	colors := (5 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors
]

{ #category : #examples }
ColorLegend class >> exampleDark [
	"self exampleDark"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 darkShadesFor: (Color lightRed).
	colors := (5 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleDarkLight [
	"self exampleDarkLight"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 darkLightShadesFor: (Color red).
	colors := (-105 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleExpressionHue [
	"self exampleExpressionHue"
	| legend colors |
	legend := self expression: '((x max: 0.1) ln max: 0.0)' mappedFrom: 0 step: 1 n: 100 hue: (Color lightCyan hue).
	colors := (-5 to: 111 by: 2) collect: [:each | legend colorFor: each exp].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleHue [
	"self exampleHue"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 hue: (Color red hue).
	colors := (5 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleLight [
	"self exampleLight"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 lightShadesFor: (Color lightRed).
	colors := (5 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleLightDark [
	"self exampleLightDark"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 lightDarkShadesFor: (Color red).
	colors := (5 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleMixing [
	"self exampleMixing"
	| legend colors |
	legend := self mappedFrom: 0 step: 10 n: 100 mixing: {Color red. Color yellow. Color blue}.
	colors := (-115 to: 1115 by: 50) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalDark [
	"self exampleNominalDark"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl darkShadesFor: (Color paleBlue).
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalDarkLight [
	"self exampleNominalDarkLight"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl darkLightShadesFor: (Color paleBlue).
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalHue [
	"self exampleNominalHue"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl hue: (Color red hue).
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalLight [
	"self exampleNominalLight"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl lightShadesFor: (Color paleBlue).
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalLightDark [
	"self exampleNominalLightDark"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl lightDarkShadesFor: (Color paleBlue).
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalMixing [
	"self exampleNominalMixing"
	| legend colors objColl |
	objColl := {'aap'. 'noot'. 'mies'}.
	legend := self mapValues: objColl mixing: {Color red. Color yellow. Color blue}.
	colors := (objColl, {'zus'} , objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #examples }
ColorLegend class >> exampleNominalMixingBinary [
	"self exampleNominalMixingBinary"
	" | dict |
	dict := Dictionary new.
	dict at: true put: Color green.
	dict at: false put: Color red.
	^dict "

	| legend colors objColl |
	objColl := {true. false}.
	legend := self mapValues: objColl mixing: {Color green. Color red}.
	colors := (objColl, objColl , objColl) collect: [:each | legend colorFor: each].
	Color showColors: colors.
	^legend
]

{ #category : #'instance creation' }
ColorLegend class >> expression: aString mappedFrom: min step: width n: anInteger hue: degrees [ 
	"self expression: '((x immigrants max: 0.0001) ln max: 0.0)' mappedFrom: 0 step: 1000 n: 100 hue: 240" 
	"self expression: '((x max: 0.0001) ln max: 0.0)' mappedFrom: 0 step: 1 n: 100 hue: 240" 

	| instance |
	instance := self new expression: aString.
	instance source: (ColorSource
				mappedFrom: min
				step: width
				n: anInteger
				colors: (ColorSource colorSchemeHue: degrees grades: anInteger)).
	^ instance
]

{ #category : #loading }
ColorLegend class >> fromFile: aString [ 
	"load"
	"self fromFile: 'corineLU.colorLegend' "

	| fname refStream instance |
	fname := aString.
	fname isEmptyOrNil
		ifTrue: [^ self new].
	(fname asLowercase endsWith: '.colorlegend')
		ifFalse: [fname := fname , '.colorLegend'].
	refStream := ReferenceStream fileNamed: fname.
	refStream atEnd
		ifTrue: [instance := self new]
		ifFalse: [instance := refStream next].
	refStream close.
	^ instance
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl colors: colorColl [ 
	"answer a ColorLegend mapping Objects to the given Colors "

	^self new source: (ColorSource mapValues: objColl colors: colorColl)
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl colors: colorColl labels: labelColl [
	"answer a ColorLegend mapping Objects to the given Colors. The Strings in labelColl will be used when displaying the legend "

	^self new source: (ColorSource mapValues: objColl colors: colorColl labels: labelColl)
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl darkLightShadesFor: aColor [ 
	"answer a ColorLegend mapping Objects to Colors in the dark-light series for aColor"
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeDarkToLight: aColor shades: objColl size))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl darkShadesFor: aColor [ 
	"answer a ColorLegend mapping Objects to Colors in the dark series for aColor"
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeDark: aColor shades: objColl size))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl hue: degrees [ 
	"answer a ColorLegend mapping Objects to Colors with the given hue (0-360)"
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeHue: degrees grades: objColl size))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl lightDarkShadesFor: aColor [ 
	"answer a ColorLegend mapping Objects to Colors in the light-dark series for aColor"

	" 11.5 // 4 2 11.5 \\ 4 3.5" 
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeLightToDark: aColor shades: (1 + (objColl size // 2))))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl lightShadesFor: aColor [ 
	"answer a ColorLegend mapping Objects to Colors in the light series for aColor"
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeLight: aColor shades: objColl size))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValues: objColl mixing: aCollection [  
	"answer a ColorLegend mapping Objects to Colors"
	^ self new
		source: (ColorSource
				mapValues: objColl
				colors: (ColorSource colorSchemeMixAll: aCollection shadesPerCombi: (objColl size / (aCollection size -1)) rounded))
]

{ #category : #'instance creation' }
ColorLegend class >> mapValuesToRandom: objColl [ 
	"answer a ColorLegend mapping Objects to random Colors "

	^self new source: (ColorSource mapValues: objColl
				colors: (objColl collect: [:each | Color random]))
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: step n: anInteger darkLightShadesFor: aColor [ 
	"answer a ColorLegend mapping Numbers to Colors "
	"Numbers between min and (n * width + min) get a Color with a mix of
	white and aColor & aColor and black; outside this range a default color is returned"

	^ self new
		source: (ColorSource
				mappedFrom: min
				step: step
				n: anInteger
				colors: (ColorSource colorSchemeDarkToLight: aColor shades: anInteger // 2 + 1))
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: step n: anInteger darkShadesFor: aColor [ 
	"answer a ColorLegend with a ColorSourceInterval that maps Numbers to Colors "
	"Numbers between min and (n * width + min) get a Color with a mix of black and aColor;
	outside this range a default color is returned"
	"self mappedFrom: 0 step: 1000 n: 100 darkShadesFor: (Color blue)"
	^ self new
		source: (ColorSource
				mappedFrom: min
				step: step
				n: anInteger
				colors: (ColorSource colorSchemeDark: aColor shades: anInteger))
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: width n: anInteger hue: degrees [ 
	"answer a ColorLegend with a ColorSourceInterval that maps Numbers to Colors "
	"Numbers between min and (n * width + min) get a Color with the given
	hue; outside this range a default color is returned"
	"self mappedFrom: 0 step: 1000 n: 100 hue: 240"
	^ self new
		source: (ColorSource
				mappedFrom: min
				step: width
				n: anInteger
				colors: (ColorSource colorSchemeHue: degrees grades: anInteger))
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: step n: anInteger lightDarkShadesFor: aColor [ 
	"answer a ColorLegend mapping Numbers to Colors"
	"Numbers between min and (n * width + min) get a Color with a mix of white and aColor & aColor and black;
	 outside this range a default color is returned"
	"make sure to have sufficient colors for all bins, AND covering the right color range"

	"self mappedFrom: 0 step: 1000 n: 100 lightDarkShadesFor: (Color blue)" 

	^ self new
		source: (ColorSource
				mappedFrom: min
				step: step
				n: anInteger 
				colors: (ColorSource colorSchemeLightToDark: aColor shades: anInteger // 2 + 1)) 
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: step n: anInteger lightShadesFor: aColor [ 
	"answer a ColorLegend with a ColorSourceInterval that maps Numbers to Colors"
	"Numbers between min and (n * width + min) get a Color with a mix of white and aColor;
	 outside this range a default color is returned"

	"self mappedFrom: 0 step: 1000 n: 100 lightShadesFor: (Color blue)" 

	^ self new
		source: (ColorSource
				mappedFrom: min
				step: step
				n: anInteger
				colors: (ColorSource colorSchemeLight: aColor shades: anInteger))
]

{ #category : #'instance creation' }
ColorLegend class >> mappedFrom: min step: width n: anInteger mixing: aCollection [ 
	"answer a ColorLegend with a ColorSourceInterval that maps Numbers to Colors "
	"Numbers between min and (n * width + min) get a Color with the given
	hue; outside this range a default color is returned"
	"self mappedFrom: 0 step: 1000 n: 100 mixing: {Color red. Color blue}"
	^ self new
		source: (ColorSource
				mappedFrom: min
				step: width
				n: anInteger
				colors: (ColorSource colorSchemeMixAll: aCollection shadesPerCombi: (anInteger / (aCollection size -1)) rounded))
]

{ #category : #loading }
ColorLegend class >> openColorLegend [
	"ColorLegend openColorLegend" 
	| fname result |
	result := FileList modalFileSelectorForSuffixes: #('colorlegend' ).
	result
		ifNil: [^ self].
	fname := result fullName.
	result close.
	^self fromFile: fname
]

{ #category : #'instance creation' }
ColorLegend class >> reasonableLegendForValues: aCollection [ 
	"try to define a ColorLegend that fits well with the values in aCollection"

	| min max range perc10 |
	aCollection isEmpty 
		ifTrue: 
			[^ColorLegend 
				mappedFrom: 0
				step: 1
				n: 1
				hue: 240].	"no data"
	aCollection first isNumber 
		ifFalse: [^ColorLegend mapValuesToRandom: aCollection asSet asArray].
	aCollection first isFloat 
		ifFalse: 
			[aCollection asSet size < (aCollection size / 10) 
				ifTrue: [^ColorLegend mapValuesToRandom: aCollection asSet asArray]].
	min := aCollection min.
	max := aCollection max.
	range := (max - min) abs.
	range isZero ifTrue: [range := 10.0].	"a map with a single value should have an arbitrary range > 0"
	perc10 := range / 10.0.
	^ColorLegend 
		mappedFrom: min - perc10
		step: (range + perc10 + perc10) / 32.0
		n: 32
		hue: 240
]

{ #category : #'color editing' }
ColorLegend >> allColorsAlpha: aFloat [
	"replace all colors in the ColorSource by colors with transparency aFloat"

	source allColorsAlpha: aFloat
]

{ #category : #accessing }
ColorLegend >> block [
	^block
]

{ #category : #accessing }
ColorLegend >> block: aBlock [
	"install a code block. This block should define how to ask the ColorSource for a Color"
	"example: [:obj :src | src colorFor: obj]; result is exactly the same as when there is no block"
	"example: [:obj :src | src colorFor: obj size] "

	block := aBlock
]

{ #category : #translation }
ColorLegend >> colorFor: anObject [ 
	"delegate to source; when block is defined, do this via the block (with
	anObject as first argument and source as second)"
	block isNil
		ifTrue: [^ source colorFor: anObject]
		ifFalse: [^ block value: anObject value: source]
]

{ #category : #translation }
ColorLegend >> colorForAll: aCollection [ 
	"delegate to source; when block is defined, do this via the block (with
	anObject as first argument and source as second)"
	"For the latter situation I am not sure how to do this for multiple objects in aCollection; 
	it works (?) now by taking again one value at a time..."

	block isNil
		ifTrue: [^ source colorForAll: aCollection]
		ifFalse: [^ aCollection collect: [:each | block value: each value: source] ]
]

{ #category : #accessing }
ColorLegend >> colorsAndLabels [
	"delegate to the ColorSource"

	^source colorsAndLabels
]

{ #category : #accessing }
ColorLegend >> colorsAndLabelsCondensed [
	"delegate to the ColorSource"

	^source colorsAndLabelsCondensed
]

{ #category : #installation }
ColorLegend >> expression: aString [
	"install a code-block that will lookup the color in the source, using expression aString to obtain the value that is send to the color source"
	"aString is something like: 'x areaHa', or: '((x max: 0.0001) log) "

	self block: (Compiler evaluate: '[:x :src | src colorFor: ' , aString , ']')

]

{ #category : #accessing }
ColorLegend >> source [
	^source
]

{ #category : #accessing }
ColorLegend >> source: aColorSource [
	source := aColorSource
]

{ #category : #storage }
ColorLegend >> storeOnFile [
	"Save the instance in a file. Ask the user for a file name"

	| fname refStream |
	block isNil ifFalse: [^self error: 'can''t store a BlockContext in a ReferenceStream'].
	fname := UIManager default request: 'Name for ColorLegend?'.
	fname isEmptyOrNil
		ifTrue: [^ self].
	(fname asLowercase endsWith: '.colorlegend')
		ifFalse: [fname := fname , '.colorLegend'].
	refStream := ReferenceStream fileNamed: fname.
	refStream nextPut: self.
	refStream close
]
