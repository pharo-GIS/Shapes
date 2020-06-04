Class {
	#name : #BaselineOfShapes,
	#superclass : #BaselineOf,
	#category : #BaselineOfShapes
}

{ #category : #baselines }
BaselineOfShapes >> baseline: spec [

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'https://github.com/hernanmd/Shapes'.
		spec project: 'XBase' with: [
				spec
					className: #ConfigurationOfXBase;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/hernan/XBase/main/' ].
		spec 
			package: 'Shapes' 			with: [ spec requires: #('XBase' 'ColorLegend' ). ];
			package: 'ColorLegend';
			package: 'Shp-Morphic' 	with: [ spec requires: #('ColorLegend' 'Shapes' ). ]. ].

]
