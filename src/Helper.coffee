class Helper
			
	clone: (obj) ->
		if not obj? or typeof obj isnt 'object'
			return obj

		if obj instanceof Date
			return new Date(obj.getTime()) 

		if obj instanceof RegExp
			flags = ''
			flags += 'g' if obj.global?
			flags += 'i' if obj.ignoreCase?
			flags += 'm' if obj.multiline?
			flags += 'y' if obj.sticky?
			return new RegExp(obj.source, flags) 

		newInstance = new obj.constructor()

		for key of obj
			newInstance[key] = @clone obj[key]

		return newInstance

	toggleFullScreen: ->
		if ((document.fullScreenElement && document.fullScreenElement != null) or (!document.mozFullScreenElement && !document.webkitFullScreenElement))
			if (document.documentElement.requestFullScreen)
				console.log "norm"
				document.documentElement.requestFullScreen()
			else if (document.documentElement.mozRequestFullScreen)
				console.log "moz"
				document.documentElement.mozRequestFullScreen()
			else if (document.documentElement.webkitRequestFullScreen)
				console.log "webkit"
				document.documentElement.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)
		else
			console.log "else"
			if (document.cancelFullScreen)
				document.cancelFullScreen()
			else if (document.mozCancelFullScreen)
				document.mozCancelFullScreen()
			else if (document.webkitCancelFullScreen)
				document.webkitCancelFullScreen()
				
# window.requestAnimFrame = ( ->
  # return  window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or ( callback ) ->
  # window.setTimeout(callback, 1000 / 60)
# )()

window.Helper = Helper # export scope