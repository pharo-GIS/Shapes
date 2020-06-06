# Description

Smalltalk package to read and view GIS data in ESRI Shapefile format, [originally written](http://www.squeaksource.com/shapes.html) by Hans Baveco and forked to work with Pharo. 

# Installation

```smalltalk
Metacello new
	onWarningLog;
	repository: 'github://hernanmd/Shapes/repository';
	baseline: 'Shapes';
	load
```

# Usage

You can try it with your own .shp files or downloading a [sample data set](https://github.com/nvkelso/natural-earth-vector).

```smalltalk
| urlESRIFilePrefix urlESRIFileShp shpE legend |
urlESRIFileShp := FileSystem workingDirectory / 'natural-earth-vector/10m_cultural/ne_10m_admin_0_countries.shp'.
shpE := ShapeEnsemble fromFile: urlESRIFileShp.
shpE attribute: 'CONTINENT'.
legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
shpE legend: legend.
shpE displayMorphic
```
