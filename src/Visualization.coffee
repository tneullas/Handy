# Visualization manage all the Bubbles
class Visualization
	# This class is a parent of "Bubble" class
	constructor: ( ) ->
		@windowWidth = ""
		@windowHeight = ""
		@init()
		
	init: ->
		# console.info "initializing Visualization"
		
	draw: ( context ) ->
		
		# for b in @bubbles
			# b.draw context
		
		
		# context.strokeStyle = '#F0F'
		# context.lineWidth = 2
		# context.beginPath()
		
		# context.moveTo context.canvas.width / 3, 0
		# context.lineTo context.canvas.width / 3, context.canvas.height
		
		# context.moveTo context.canvas.width / 3 * 2, 0
		# context.lineTo context.canvas.width / 3 * 2, context.canvas.height
		# context.stroke()
		
		# context.moveTo 0, context.canvas.height / 3
		# context.lineTo context.canvas.width, context.canvas.height / 3
		# context.moveTo 0, context.canvas.height / 3 * 2
		# context.lineTo context.canvas.width, context.canvas.height / 3 * 2
		# context.stroke()
		
		# context.closePath()
		
		
window.Visualization = Visualization # export scope