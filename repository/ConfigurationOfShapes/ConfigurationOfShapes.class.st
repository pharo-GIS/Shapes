Class {
	#name : #ConfigurationOfShapes,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfShapes
}

{ #category : #'development support' }
ConfigurationOfShapes class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfShapes class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #private }
ConfigurationOfShapes class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfShapes class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfShapes class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfShapes class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfShapes class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfShapes class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfShapes class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfShapes class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfShapes >> baseline01: spec [
	<version: '0.1-baseline'>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'http://smalltalkhub.com/mc/hernan/Shapes/main/'.
		spec project: 'XBase' with: [
				spec
					className: #ConfigurationOfXBase;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/hernan/XBase/main/' ].
		spec package: 'Shapes' with: [
				spec requires: #('XBase' ). ]. ].

]

{ #category : #baselines }
ConfigurationOfShapes >> baseline02: spec [
	<version: '0.2-baseline'>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'http://smalltalkhub.com/mc/hernan/Shapes/main/'.
		spec project: 'XBase' with: [
				spec
					className: #ConfigurationOfXBase;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/hernan/XBase/main/' ].
		spec 
			package: 'Shapes' with: [
				spec requires: #('XBase' 'ColorLegend' ). ];
			package: 'ColorLegend';
			package: 'Shp-Morphic' with: [
				spec requires: #('ColorLegend' 'Shapes' ). ]. ].

]

{ #category : #accessing }
ConfigurationOfShapes >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #'symbolic versions' }
ConfigurationOfShapes >> development: spec [
	<symbolicVersion: #'development'>

	spec for: #'common' version: '0.2-baseline'.

]

{ #category : #accessing }
ConfigurationOfShapes >> project [

	^ project ifNil: [ 
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		project := MetacelloMCProject new projectAttributes: self customProjectAttributes. 
		(Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfShapes >> stable: spec [
	<symbolicVersion: #'stable'>

	spec for: #'common' version: '1.1'.
	spec for: #'pharo4.x' version: '1.2'

]

{ #category : #versions }
ConfigurationOfShapes >> version10: spec [
	<version: '1.0' imports: #('0.1-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'stable'.
		spec description: 'version 1.0'.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '9/17/2014 00:57'.
		spec project: 'XBase' with: '1.0'.
		spec package: 'Shapes' with: 'Shapes-HernanMoralesDurand.73'. ].

]

{ #category : #versions }
ConfigurationOfShapes >> version11: spec [
	<version: '1.1' imports: #('0.2-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'stable'.
		spec description: 'version 1.1'.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '9/17/2014 01:01'.
		spec project: 'XBase' with: '1.0'.
		spec 
			package: 'Shapes' with: 'Shapes-HernanMoralesDurand.73';
			package: 'ColorLegend' with: 'ColorLegend-HernanMoralesDurand.17';
			package: 'Shp-Morphic' with: 'Shp-Morphic-HernanMoralesDurand.7'. ].

]

{ #category : #versions }
ConfigurationOfShapes >> version12: spec [
	<version: '1.2' imports: #('0.2-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'stable'.
		spec description: 'version 1.1'.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '7/6/2015 01:01'.
		spec project: 'XBase' with: '1.0'.
		spec 
			package: 'Shapes' with: 'Shapes-SergeStinckwich.74';
			package: 'ColorLegend' with: 'ColorLegend-HernanMoralesDurand.18';
			package: 'Shp-Morphic' with: 'Shp-Morphic-HernanMoralesDurand.7'. ].

]
