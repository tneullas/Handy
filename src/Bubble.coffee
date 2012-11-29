# Bubble represent the way element are drawn
class Bubble
	constructor: ( id, position ) ->
		@id = id
		position = position # TODO use position
		@pixelsIndices = []
	
	getIndices: ->
		return @pixelsIndices
	
	buildPixelsIndices: ( context ) ->
		context.beginPath()
		width = context.canvas.width
		height = context.canvas.height
		context.arc( Math.round( width / 3 + (2 % @id) * width / 6 ), Math.round( height / 3 + ( @id % 2 ) * height / 3 ), 30, 0, Math.PI*2, true)
		for i in [ 0 ... width ]
			for j in [ 0 ... height ]
				if context.isPointInPath(i, j)
					@pixelsIndices.push( (j * i) + i )
		context.closePath()
	
	draw: ( context, color ) ->
		context.strokeStyle = '#F0F'
		context.beginPath()
		width = context.canvas.width
		height = context.canvas.height
		context.arc( Math.round( width / 3 + (2 % @id) * width / 6 ), Math.round( height / 3 + ( @id % 2 ) * height / 3 ), 30, 0, Math.PI*2, true)
		context.closePath()
		context.stroke()
		if color != undefined
			context.fillStyle = color
			context.fill()
		
window.Bubble = Bubble # export scope