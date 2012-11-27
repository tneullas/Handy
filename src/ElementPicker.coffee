class ElementPicker
	constructor: ( canvas, context, elementNumber = 2, nbBubbles = 4  ) ->
		@bubbles = [] # length = nbBubbles
		@nbBubbles = nbBubbles
		@canvas = canvas
		@context = context
		@elementNumber = elementNumber
		@elementList = [] # contain every element available
		@orderOfElement = [] # contain all element in the order they have been picked (could contain only indices for performance)
		
	
	addColorRecursively: () ->
		document.getElementById("infos").innerHTML = "Pick a new color by clicking on picture"
		@canvas.onmousedown  = ( evt ) =>
			coords = @canvas.relMouseCoords evt # evt.offsetX, evt.offsetY is not cross browser and give sometimes bad result
			pos = ( coords.x + coords.y ) * 4
			imagedata = @context.getImageData evt.offsetX, evt.offsetY, 1, 1
			color = new Color imagedata.data[ 0 ], imagedata.data[ 1 ], imagedata.data[ 2 ], 255
			sound = new Sound @elementList.length
			element = new Element color, sound
			@elementList.push element
			@canvas.onmousedown = undefined
			if @elementList.length >= @elementNumber
				@pickElement()
				document.getElementById("infos").innerHTML = ""
				for el, i in @elementList
					col = el.color.getAsArray()
					for j in [0 ... col.length]
						col[ j ] /= 255
					window.g.cm.addVectorToShaders( "col" + i, col )
			else
				@addColorRecursively()
	
	
	configure: ( )->
		console.info "initializing Element Picker"
		@elementList = []
		
		@bubbles.length = 0
		for i in [ 1 .. @nbBubbles ]
			@bubbles.push new Bubble i
		
		@addColorRecursively()
	
	
	resetOrder: ->
		@orderOfElement.length = 0
	
	# randomize in elementList(sound and color) and position (bubble number)
	# push the result in the end of orderOfElement
	pickElement: ->
		randElementList = Math.floor( Math.random() * @elementNumber )
		randBubble = Math.floor( Math.random() * @nbBubbles )
		# elementToAdd = window.Helper.clone( @elementList[ randElementList ] ) # Not working because of unknown audio error on constructor
		# elementToAdd.setBubble randBubble
		color = @elementList[ randElementList ].color
		sound = @elementList[ randElementList ].sound
		elementToAdd = new Element color, sound, randBubble
		@orderOfElement.push elementToAdd
	
	draw: ( context, video, indicesOfLevel )->
		# Draw bubble shape
		for b in @bubbles
			b.draw context
		
		# Fill next bubble to be checked of the next color to found
		if @orderOfElement.length and @orderOfElement[ 0 ] != undefined
			nextElement = @orderOfElement[ indicesOfLevel ]
			indNextPickedBubble = nextElement.bubble
			@bubbles[ indNextPickedBubble ].draw context, nextElement.color.to_rgba()
		
		# Draw number of bubble to found on this level and where the player is currently
		if @orderOfElement.length and @orderOfElement[ 0 ] != undefined
			yPadding = 30
			context.lineWidth = 1.7
			context.strokeStyle = "black"
			for i in [ 0 ... @orderOfElement.length ]	
				context.strokeRect 10 + i * 30, context.canvas.height - yPadding, 10, 10
			for i in [ 0 ... indicesOfLevel ]
				context.fillStyle = @orderOfElement[ i ].color.to_rgba()
				context.fillRect 10 + i * 30, context.canvas.height - yPadding, 10, 10
		
		
window.ElementPicker = ElementPicker # export scope