Class {
	#name : #BaselineOfShapes,
	#superclass : #BaselineOf,
	#category : #BaselineOfShapes
}

{ #category : #baselines }
BaselineOfShapes >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'https://github.com/hernanmd/Shapes'.
		spec
			baseline: 'XBase'
			with: [ spec repository: 'github://hernanmd/XBase/repository' ].
		spec 
			package: 'Shapes' 			with: [ spec requires: #('XBase' 'ColorLegend' ). ];
			package: 'ColorLegend';
			package: 'Shp-Morphic' 	with: [ spec requires: #('ColorLegend' 'Shapes' ). ]. ].

]
