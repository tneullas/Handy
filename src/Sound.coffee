class Sound
	constructor: ( filename = "", id = "" ) ->
		@filename = filename
		@htmlElement = id
		console.log 'creating a new sound : ', filename, id
		
	play: ->
	
	stop: ->
	
	pause: ->
	
	unpause: ->
			
window.Sound = Sound # export scope