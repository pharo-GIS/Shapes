# Description

Smalltalk package to read and view GIS data in ESRI Shapefile format, [originally written](http://www.squeaksource.com/shapes.html) by Hans Baveco and forked to work with Pharo. 

# Installation

```smalltalk
Metacello new
	onWarningLog;
	repository: 'github://pharo-GIS/Shapes/repository';
	baseline: 'Shapes';
	load
```

# Usage

You can try it with your own .shp files or download a [sample data set](https://github.com/nvkelso/natural-earth-vector) from Natural Earth project using the following example:

```smalltalk
| shpE legend urlRoot urlESRIFilePrefix urlESRIFileShp urlPath response fileRef |

" Download Shapefile resources "
urlRoot := 'https://github.com/nvkelso/natural-earth-vector/blob/master/110m_cultural/'.
urlESRIFilePrefix := 'ne_110m_populated_places'.
urlESRIFileShp := urlESRIFilePrefix , '.shp'.
urlPath := urlRoot , urlESRIFilePrefix.

#('.shx' '.dbf' '.shp' '.cpg' '.prj') do: [ : ext |
  ZnClient new
   url: (urlPath , ext) asZnUrl;
   queryAt: 'raw' put: 'true';
   numberOfRetries: 2;
   enforceHttpSuccess: true;
   downloadTo: urlESRIFilePrefix , ext;
   get ].

" Load and display it in Morphic "
shpE := ShapeEnsemble fromFile: urlESRIFileShp.
" List data fields "
shpE dataFields inspect.
" List all shape records "
shpE shapeRecords inspect.
" Set the current attribute "
shpE attribute: 'NAME'.

legend := ColorLegend mapValuesToRandom: shpE valuesOfCurrentAttribute.
shpE legend: legend.

shpE displayMorphic.
```

If you already downloaded the files in your Pharo working directory:

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
