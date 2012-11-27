# Background ask for a couple of pictures and use those informations for extracting background and draw a new pictures
class Background
	constructor: () ->
		@sourcePictures = []
		@extractedBackground = [] # ImageElement
		@numberOfSourcePictures = 3
		@tolerance = 0.18 # Between 0 and 1
		
	init: ( context ) ->
		console.info "initializing Background"
		@sourcePictures = []
		@extractedBackground = []
		@inter = setInterval ( => @getCurrentImageData( context )), 200
		
	getCurrentImageData: ( context ) ->
		console.log "Getting background num" + @sourcePictures.length
		imagedata = context.getImageData 0, 0, context.canvas.width, context.canvas.height
		@sourcePictures.push imagedata.data
		# console.log imagedata.data[ 0 ], imagedata.data[ 1 ], imagedata.data[ 2 ], imagedata.data[ 3 ], imagedata.data[ 4 ], imagedata.data[ 5 ], imagedata.data[ 6 ]
		if @sourcePictures.length >= @numberOfSourcePictures
			clearInterval @inter
			@extractBackgroundFromSourcePictures context
	
	extractBackgroundFromSourcePictures: ( context ) ->
		# console.log "----"
		# OPTIMIZATION median could be obtained by getting out alpha
		for i in [ 0 ... @sourcePictures[ 0 ].length ]
			median = []
			for sp, j in @sourcePictures
				median[ j ] = sp[ i ]
			median.sort()
			@extractedBackground[ i ] = median[ Math.ceil( @numberOfSourcePictures / 2 ) ]
		
		# next we push extracted background to a canvas which is send as a texture
		# bg = document.createElement('canvas')
		# console.log context.canvas.width, context.canvas.height
		# bg.width = context.canvas.width
		# bg.height = context.canvas.height
		# document.body.appendChild bg
		# ctx = bg.getContext('2d')
		# imgData = ctx.createImageData( context.canvas.width, context.canvas.height )
		# d = imgData.data
		# for p, i in @extractedBackground
			# d[ i ] = p
		# ctx.putImageData(imgData, 0, 0)
		# window.g.cm.addTextureToShaders( "background", bg )
		
		dataTypedArray = new Uint8Array(@extractedBackground)
		window.g.cm.addTextureToShaders( "background", dataTypedArray )
		
		# console.log @extractedBackground[ 0 ], @extractedBackground[ 1 ], @extractedBackground[ 2 ], @extractedBackground[ 3 ], @extractedBackground[ 4 ], @extractedBackground[ 5 ], @extractedBackground[ 6 ]
	
window.Background = Background # export scope