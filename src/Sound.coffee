class Sound
	constructor: ( filename = "" ) ->
		@filename = filename + ".wav"
		console.info 'creating a new sound : ' + @filename
		if filename != ""
			console.log (new Audio()).canPlayType("audio/ogg; codecs=vorbis") + " possible to play sound"
			console.log (new Audio()).canPlayType("audio/wav") + " possible to play sound"
			@htmlSound = new Audio( "sound/" + @filename ) # buffers automatically when created
		
	play: ->
		@htmlSound.play()
		
	stop: ->
		@htmlSound.pause()
		@htmlSound.currentState = 0
	
	pause: ->
		@htmlSound.pause()
	
window.Sound = Sound # export scope