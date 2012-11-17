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
	

	init: ->
		@score = 0
		@level = 1
		@indicesOfLevel = 0
		@time = Infinity
		# @visualization = undefined
		@visualization = new Visualization
	
	initKeyboard: () ->
		document.onkeypress = ( evt ) =>
			if evt.keyCode == 80 or evt.keyCode == 112 # P
				@pause()
			else if evt.keyCode == 88 or evt.keyCode == 120 # X
				@background.init @context
			else if evt.keyCode == 70 or evt.keyCode == 102 # F
					window.Helper.toggleFullScreen()
			else if evt.keyCode == 114 or evt.keyCode == 82 # R Configure new color, must init again after
				@elementPicker.resetOrder()
				@elementPicker.configure()
				@init()
			else if evt.keyCode == 68 or evt.keyCode == 100 # D FOR DEBUG ONLY
				@elementIsDetected()
			else if evt.keyCode == 116
				# refresh (use to don't show this key on console)
			else
				console.log evt.keyCode
				
	elementIsDetected: ->
		@elementPicker.orderOfElement[ @indicesOfLevel ].sound.play()
		@score += 10
		@indicesOfLevel++
		if @indicesOfLevel == @level
			@levelUp()
		
	
	colorDetect: ->
		imagedata = @context.getImageData 0, 0, @context.canvas.width, @context.canvas.height
		for i in imagedata.data by 4
			# colorAsArray = [ imagedata.data[ i ], imagedata.data[ i + 1 ], imagedata.data[ i + 2 ], imagedata.data[ i + 3 ] ]
			# console.log @color.to_rgba()
			# console.log colorAsArray[ 0 ] - 70, colorAsArray[ 0 ] + 70, colorAsArray[ 1 ] - 70, colorAsArray[ 1 ] + 70, colorAsArray[ 2 ] - 70, colorAsArray[ 2 ] + 70, colorAsArray[ 3 ] - 70, colorAsArray[ 3 ] + 70
			for elem in @elementPicker.elementList when elem != undefined
				col = elem.color
				if col.equalsWithTolerance( [ imagedata.data[ i ], imagedata.data[ i + 1 ], imagedata.data[ i + 2 ], imagedata.data[ i + 3 ] ], 100 )
					console.log "color founded on pos ", i, col
					# @context.fillStyle = col.to_rgba()
					# @context.fillRect( Math.floor(i / @context.canvas.width), i % @context.canvas.width, 1, 1 )
	
	update: ->
		# @colorDetect()
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
	
		@clearCanvas()
		@background.draw @context, @webcam.video
		
		@context.drawImage( @webcam.video, 0, 0, @context.canvas.width, @context.canvas.height)
		# @context.translate @context.canvas.width,0
		# @context.scale -1,1
		@drawTime()
		@drawLevel()
		@drawScore()
		@visualization.draw @context
		@elementPicker.draw @context, @webcam.video, @indicesOfLevel
		
	clearCanvas: ->
		@context.clearRect( 0, 0, @context.canvas.width, @context.canvas.height)
		
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
			@score += @time * 10;
		
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