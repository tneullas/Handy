# Bubble represent the way element are drawn
class Bubble
	constructor: ( id ) ->
		@id = id
		
	draw: ( context, color ) ->
		context.strokeStyle = '#F0F'
		context.beginPath()
		width = context.canvas.width
		height = context.canvas.height
		context.arc( Math.round( width / 3 + (2 % @id) * width / 6 ), Math.round( height / 3 + ( @id % 2 ) * height / 3 ), 30, 0, Math.PI*2, true)
		context.stroke()
		context.closePath()
		if color != undefined
			context.fillStyle = color
			context.fill()
		
window.Bubble = Bubble # export scope