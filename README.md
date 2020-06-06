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

# Sample outputs

Follows some example outputs using different attributes for the NaturalEarth data set:

## CONTINENT

![an ImageMorph(55801344)](https://user-images.githubusercontent.com/4825959/83931348-95d38880-a772-11ea-9ffe-1549abc50857.png)

## SUBREGION

![an ImageMorph(705029120)](https://user-images.githubusercontent.com/4825959/83931353-9835e280-a772-11ea-9a62-f5fdefbb5a6a.png)

## REGION_UN

![an ImageMorph(911508224)](https://user-images.githubusercontent.com/4825959/83931355-98ce7900-a772-11ea-8560-7f75d628cb69.png)

## NAME_LONG

![an ImageMorph(1002761984)](https://user-images.githubusercontent.com/4825959/83931358-99ffa600-a772-11ea-80b3-2dae633ec0ba.png)
