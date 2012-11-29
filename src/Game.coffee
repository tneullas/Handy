class Game
	constructor: ->
		@canvas = null
		@context = null
		@gl = null
		@elementNumber = 2
		@bubbleNumber = 4
		@isOnPause = false
		@configure()
		@init()
		
			
		# TODO use the more correct requestanimframe
		setInterval =>
			@update()
			40
		setInterval =>
			@draw()
			40
			
		# (@animLoop = =>
			# window.requestAnimFrame(@animLoop())
			# @draw()
		# )()
		# @levelUp()
		
	configure: ->
		@canvas = document.getElementById "myCanvas"
		@context = @canvas.getContext '2d'
		@cm = new CanvasManager "my3dCanvas"
		@initKeyboard()
		@webcam = new Webcam "video"
		@background = new Background
		@elementPicker = new ElementPicker @canvas, @context, @elementNumber, @bubbleNumber
		@elementPicker.configure()
		@cm.addVariableToShaders( "tolBG", @background.tolerance )
		@createOriginalCanvas()
		
	createOriginalCanvas: ->
		originalWebcamCanvas = document.createElement('canvas')
		originalWebcamCanvas.width = @context.canvas.width
		originalWebcamCanvas.height = @context.canvas.height
		@originalWebcamContext = originalWebcamCanvas.getContext('2d')
		# document.body.appendChild originalWebcamCanvas
		
	init: ->
		@score = 0
		@level = 1
		@indicesOfLevel = 0
		@time = Infinity
		# @visualization = undefined
		@visualization = new Visualization
	
	initKeyboard: () ->
		document.onkeypress = ( evt ) =>
			evt = evt || window.event
			keyCode = evt.which || evt.keyCode
			if keyCode == 80 or keyCode == 112 # P
				@pause()
			else if keyCode == 88 or keyCode == 120 # X
				@background.init @context
			else if keyCode == 70 or keyCode == 102 # F
					window.Helper.toggleFullScreen()
			else if keyCode == 114 or keyCode == 82 # R Configure new color, must init again after
				@elementPicker.resetOrder()
				@elementPicker.configure()
				@init()
			else if keyCode == 68 or keyCode == 100 # D FOR DEBUG ONLY
				@elementIsDetected()
			else if keyCode == 116
				# refresh (use to don't show this key on console)
			else
				console.log keyCode
				
	elementIsDetected: ->
		@elementPicker.orderOfElement[ @indicesOfLevel ].sound.play()
		@score += 10
		@indicesOfLevel++
		if @indicesOfLevel == @level
			@levelUp()
		
	colorDetect: ->
		tolerance = 75
		if @elementPicker.orderOfElement.length and @elementPicker.orderOfElement[ @indicesOfLevel ] != undefined
			col = @elementPicker.orderOfElement[ @indicesOfLevel ].color
			pos = @elementPicker.bubbles[ @elementPicker.orderOfElement[ @indicesOfLevel ].bubble ].getIndices()
			imagedata = @originalWebcamContext.getImageData 0, 0, @originalWebcamContext.canvas.width, @originalWebcamContext.canvas.height
			founded = 0
			limitFounded = 10
			for ind in pos
				if col.equalsWithTolerance( [ imagedata.data[ ind ], imagedata.data[ ind + 1 ], imagedata.data[ ind + 2 ], imagedata.data[ ind + 3 ] ], tolerance )
					founded++
					if founded >= limitFounded
						@elementIsDetected()
						return true
		return false
		
	update: ->
		@colorDetect()
		@updateTime()
		
	updateTime: ->
		if @level > 1
			currentTime = (new Date()).getTime()
			@time = ( @timeOfLevel - ( currentTime - @startingTime ) / 1000 ).toFixed(1)
		if @level > 1 and @time <= 0
			@time = 0
			@loose()
		
	draw: ->
		if (@webcam.video)?
			@cm.drawScene @webcam.video
		# TODO All draw should be pass on webgl canvas (cm)
		@clearCanvas()
		
		@context.drawImage( @webcam.video, 0, 0, @context.canvas.width, @context.canvas.height)
		@originalWebcamContext.drawImage( @webcam.video, 0, 0, @context.canvas.width, @context.canvas.height)
		
		# @context.translate @context.canvas.width,0
		# @context.scale -1,1
		@drawTime()
		@drawLevel()
		@drawScore()
		@visualization.draw @context
		@elementPicker.draw @context, @indicesOfLevel
		
	clearCanvas: ->
		@context.clearRect( 0, 0, @context.canvas.width, @context.canvas.height)
		@originalWebcamContext.clearRect( 0, 0, @originalWebcamContext.canvas.width, @originalWebcamContext.canvas.height)
		
	drawTime: ->
		@context.fillStyle = '#F0F'
		@context.font = @context.canvas.width/40 + "pt sans-serif"
		@context.textAlign = "right"
		@context.textBaseline = "top"
		if @time == Infinity
			@context.fillText "Time : " + @time, @context.canvas.width - 10, 10
		else
			@context.fillText "Time : " + @time + " s", @context.canvas.width - 10, 10
		
	drawLevel: ->
		@context.fillStyle = '#F0F'
		# @context.font = "Arial 10px Sans-Serif"
		@context.textAlign = "left"
		@context.textBaseline = "top"
		@context.fillText "Level " + @level, 10, 10
		
	drawScore: ->
		@context.fillStyle = '#F0F'
		# @context.font = "Arial 10px Sans-Serif"
		@context.textAlign = "left"
		@context.textBaseline = "top"
		@context.fillText "Score " + @score, 10, 20 + Math.round( @context.canvas.width / 30 )
		
	levelUp: ->
		console.info "Level up !"
		# level up give points (except on first level)
		if @level > 1
			@score += @time * 10
		
		@level++
		
		# set new timer and calcul new time of level
		@startingTime = (new Date()).getTime()
		@timeOfLevel = 4 * Math.log( @level ) + 5 # Give time depending current level
		@time = @timeOfLevel
		# pick a new element
		@indicesOfLevel = 0
		@elementPicker.pickElement()
		
	
	loose: ->
		console.info "You Loose :("
		console.log "Let's try again"
		@elementPicker.resetOrder()
		@elementPicker.pickElement()
		@init()
	
	pause: ->
		if @isOnPause
			console.log 'unpause'
			@isOnPause = false
		else
			console.log 'pause'
			@isOnPause = true
	

window.Game = Game # export scope