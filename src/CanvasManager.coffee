class CanvasManager
	constructor: ( id ) ->
		if document.getElementById id
			@canvas3D = document.getElementById id
		else
			console.error "can't access canvas id " + id
			return
			
		@shaderProgram = null
		@squareVertexPositionBuffer = null
		@squareVertexTextureCoordBuffer = null
		@squareVertexIndexBuffer = null
		# @mvMatrix = mat4.create()
		# @pMatrix = mat4.create()
		
		@init()

	init: ->
		@initGL()
		@initShaders()
		@initBuffers()
		
	initGL: ->
		try
			@gl = @canvas3D.getContext("experimental-webgl")
			@gl.viewportWidth = @canvas3D.width
			@gl.viewportHeight = @canvas3D.height
		catch e
			console.log 'catched : ' + e
		
		if not @gl
			alert "Could not initialise WebGL, sorry :-("
			
	getShader: ( gl, id) ->
		shaderScript = document.getElementById(id)
		if (!shaderScript)
			return null

		str = ""
		k = shaderScript.firstChild
		while (k)
			if (k.nodeType == 3)
				str += k.textContent
			
			k = k.nextSibling
		
		if (shaderScript.type == "x-shader/x-fragment")
			shader = gl.createShader(gl.FRAGMENT_SHADER)
		else if (shaderScript.type == "x-shader/x-vertex")
			shader = gl.createShader(gl.VERTEX_SHADER)
		else
			return null
		

		gl.shaderSource(shader, str)
		gl.compileShader(shader)

		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS))
			alert "getShader : " + gl.getShaderInfoLog(shader)
			return null
		
		return shader

	addVariableToShaders: ( name, data ) ->		
		variableIndex = @gl.getUniformLocation(@shaderProgram, name)
		@gl.uniform1f(variableIndex, data)
		
	addVectorToShaders: ( name, data ) ->
		variableIndex = @gl.getUniformLocation( @shaderProgram, name )
		@gl.uniform4fv(variableIndex, data)
		
	# data must be an imageElement a canvasElement or a videoElement or an Uint8Array
	addTextureToShaders: ( name, data ) ->
		@gl.bindTexture(@gl.TEXTURE_2D, null)
		texture = @gl.createTexture()
		@gl.activeTexture(@gl.TEXTURE1)
		@gl.bindTexture(@gl.TEXTURE_2D, texture)
		# these properties let you upload textures of any size
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
		# these determine how interpolation is made if the image is being scaled up or down
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
		@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, 1, 1, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, data)
		@gl.uniform1i( @gl.getUniformLocation( @shaderProgram, name ) , 1 )
		
	initShaders: ->
		fragmentShader = @getShader(@gl, "shader-fs")
		vertexShader = @getShader(@gl, "shader-vs")

		@shaderProgram = @gl.createProgram()
		@gl.attachShader(@shaderProgram, vertexShader)
		@gl.attachShader(@shaderProgram, fragmentShader)
		@gl.linkProgram(@shaderProgram)

		if (!@gl.getProgramParameter(@shaderProgram, @gl.LINK_STATUS))
			alert("Could not initialise shaders")
		
		@gl.useProgram(@shaderProgram)
		
		@shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(@shaderProgram, "aVertexPosition")
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)
		
		@shaderProgram.textureCoordAttribute = @gl.getAttribLocation(@shaderProgram, "aTextureCoord")
		@gl.enableVertexAttribArray(@shaderProgram.textureCoordAttribute)

		@shaderProgram.pMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uPMatrix")
		@shaderProgram.mvMatrixUniform = @gl.getUniformLocation(@shaderProgram, "uMVMatrix")
		

	# setMatrixUniforms: ->
		# @gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		# @gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)

	initBuffers: ->
		@squareVertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexPositionBuffer)
		vertices = [
			 1.0, 1.0,
			-1.0, 1.0,
			-1.0, -1.0,
			 1.0, -1.0,
		]
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW)
		@squareVertexPositionBuffer.itemSize = 2
		@squareVertexPositionBuffer.numItems = 4
		
		@squareVertexTextureCoordBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexTextureCoordBuffer)
		textureCoords = [
		  0.0, 0.0,
		  1.0, 0.0,
		  1.0, 1.0,
		  0.0, 1.0,
		]
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(textureCoords), @gl.STATIC_DRAW)
		@squareVertexTextureCoordBuffer.itemSize = 2
		@squareVertexTextureCoordBuffer.numItems = 4
		
		@squareVertexIndexBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @squareVertexIndexBuffer)
		squareVertexIndices = [ 0, 1, 2, 0, 2, 3 ]
		@gl.bufferData(@gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(squareVertexIndices), @gl.STATIC_DRAW)
		@squareVertexIndexBuffer.itemSize = 1
		@squareVertexIndexBuffer.numItems = 6
		
		
	drawScene: ( video, background ) ->
		@gl.clearColor(0.0, 0.0, 0.0, 1.0)
		@gl.enable(@gl.DEPTH_TEST)
		
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

		# mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix)
		
		# mat4.identity(@mvMatrix)
		
		# mat4.translate(@mvMatrix, [0.0, 0.0, -2.5])
		
		if video?
			texture = @gl.createTexture()
			@gl.bindTexture(@gl.TEXTURE_2D, texture)
			@gl.activeTexture(@gl.TEXTURE0)
			# these properties let you upload textures of any size
			@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
			@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
			# these determine how interpolation is made if the image is being scaled up or down
			@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
			@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
			@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, video)
			@gl.uniform1i(@shaderProgram.webcam, 0)
			
			# TODO background extraction is not really working
			# if background?
				# @addTextureToShaders "background", background
			
			@gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexPositionBuffer)
			@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @squareVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)

			@gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexTextureCoordBuffer)
			@gl.vertexAttribPointer(@shaderProgram.textureCoordAttribute, @squareVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0)
			
			# @setMatrixUniforms()
			
			@gl.bindBuffer(@gl.ELEMENT_ARRAY_BUFFER, @squareVertexIndexBuffer)
			@gl.drawElements(@gl.TRIANGLES, @squareVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0)
			

window.CanvasManager = CanvasManager # export scope