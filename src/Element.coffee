# Element is an association of Color and Sound
class Element
	constructor: ( color = new Color , sound = new Sound, bubble = 0 ) ->
		@color = color
		@sound = sound
		@bubble = bubble
		
	setBubble: ( obj ) ->
		if obj isNaN
			console.error 'set Bubble on NAN : ' + obj
			return
		@bubble = obj
		
window.Element = Element # export scope