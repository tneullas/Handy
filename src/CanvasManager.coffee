class CanvasManager
	constructor: ( id ) ->
		if document.getElementById id
			@canvas3D = document.getElementById id
		else
			console.error 'cant access canvas id ' + id
			return
			
		@shaderProgram = null
		@triangleVertexPositionBuffer = null
		@squareVertexPositionBuffer = null
		@mvMatrix = mat4.create()
		@pMatrix = mat4.create()
		
		@init()

	init: ->
		@initGL()
		@initShaders()
		@initBuffers()

		@gl.clearColor(0.0, 0.0, 0.0, 1.0)
		@gl.enable(@gl.DEPTH_TEST)

		@drawScene()

		
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
			return null;
		

		return shader


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

		@shaderProgram.pMatrixUniform = @gl.getUniformLocation(@shaderProgram, "upMatrix")
		@shaderProgram.mvMatrixUniform = @gl.getUniformLocation(@shaderProgram, "umvMatrix")


	setMatrixUniforms: ->
		@gl.uniformMatrix4fv(@shaderProgram.pMatrixUniform, false, @pMatrix)
		@gl.uniformMatrix4fv(@shaderProgram.mvMatrixUniform, false, @mvMatrix)


	initBuffers: ->
		@triangleVertexPositionBuffer = @gl.createBuffer()
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @triangleVertexPositionBuffer)
		vertices = [
			 0.0, 1.0, 0.0,
			-1.0, -1.0, 0.0,
			 1.0, -1.0, 0.0
		]
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW)
		@triangleVertexPositionBuffer.itemSize = 3
		@triangleVertexPositionBuffer.numItems = 3

		# @squareVertexPositionBuffer = @gl.createBuffer()
		# @gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexPositionBuffer)
		# vertices = [
			 # 1.0, 1.0, 0.0,
			# -1.0, 1.0, 0.0,
			 # 1.0, -1.0, 0.0,
			# -1.0, -1.0, 0.0
		# ]
		# @gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW)
		# @squareVertexPositionBuffer.itemSize = 3
		# @squareVertexPositionBuffer.numItems = 4
    

	drawScene: ( video ) ->
		@gl.viewport(0, 0, @gl.viewportWidth, @gl.viewportHeight)
		@gl.clear(@gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT)

		mat4.perspective(45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, @pMatrix)

		mat4.identity(@mvMatrix)
		
		
		buffer = @gl.createBuffer()
		# vertices = [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]
		vertices = [
			1.0, 1.0, 0.0,
			-1.0, 1.0, 0.0,
			1.0, -1.0, 0.0,
			-1.0, -1.0, 0.0
		]
		# set position attribute data
		@gl.bindBuffer(@gl.ARRAY_BUFFER, buffer)
		@gl.bufferData(@gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW)
		@gl.enableVertexAttribArray(@shaderProgram.vertexPositionAttribute)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, 3, @gl.FLOAT, false, 0, 0)
		
		
		
		texture = @gl.createTexture()
		# set properties for the texture
		@gl.bindTexture(@gl.TEXTURE_2D, texture)
		# these properties let you upload textures of any size
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE)
		# these determine how interpolation is made if the image is being scaled up or down
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
		@gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST)
		@gl.bindTexture(@gl.TEXTURE_2D, null)
		
		if video?
			@gl.bindTexture(@gl.TEXTURE_2D, texture)
			@gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, video)
			@gl.drawArrays(@gl.TRIANGLES, 0, 6);
		
		mat4.translate(@mvMatrix, [-1.5, 0.0, -7.0])
		@gl.bindBuffer(@gl.ARRAY_BUFFER, @triangleVertexPositionBuffer)
		@gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0)
		# setMatrixUniforms()
		@gl.drawArrays(@gl.triangleS, 0, @triangleVertexPositionBuffer.numItems)


		# mat4.translate(@mvMatrix, [3.0, 0.0, 0.0]);
		# @gl.bindBuffer(@gl.ARRAY_BUFFER, @squareVertexPositionBuffer);
		# @gl.vertexAttribPointer(@shaderProgram.vertexPositionAttribute, @squareVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0);
		# setMatrixUniforms()
		# @gl.drawArrays(@gl.triangle_STRIP, 0, @squareVertexPositionBuffer.numItems);

window.CanvasManager = CanvasManager # export scope