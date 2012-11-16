# Background ask for a couple of pictures and use those informations for extracting background and draw a new pictures
class Background
	constructor: () ->
		@sourcePictures = []
		@extractedBackground = [] # ImageElement
		@numberOfSourcePictures = 7
		@tolerance = 20 # Percent
		
	init: ( context ) ->
		console.info "initializing Background"
		@sourcePictures = []
		@extractedBackground = []
		@inter = setInterval ( => @getCurrentImageData( context )), 1000
		
	getCurrentImageData: ( context ) ->
		console.log "Getting background num" + @sourcePictures.length
		imagedata = context.getImageData 0, 0, context.canvas.width, context.canvas.height
		@sourcePictures.push imagedata.data
		# console.log imagedata.data[ 0 ], imagedata.data[ 1 ], imagedata.data[ 2 ], imagedata.data[ 3 ], imagedata.data[ 4 ], imagedata.data[ 5 ], imagedata.data[ 6 ]
		if @sourcePictures.length >= @numberOfSourcePictures
			clearInterval @inter
			@extractBackgroundFromSourcePictures()
	
	extractBackgroundFromSourcePictures: ->
		# console.log "----"
		# OPTIMIZATION median could be obtained by getting out alpha
		for i in [ 0 ... @sourcePictures[ 0 ].length ]
			median = []
			for sp, j in @sourcePictures
				median[ j ] = sp[ i ]
			median.sort()
			@extractedBackground[ i ] = median[ Math.ceil( @numberOfSourcePictures / 2 ) ]
		# console.log @extractedBackground[ 0 ], @extractedBackground[ 1 ], @extractedBackground[ 2 ], @extractedBackground[ 3 ], @extractedBackground[ 4 ], @extractedBackground[ 5 ], @extractedBackground[ 6 ]
	
	draw: ->
		# browse every pixel, if pixel very different from extractedBackground pixel at same position draw it black else white
		
			
window.Background = Background # export scope