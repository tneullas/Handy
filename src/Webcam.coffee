class Webcam
	constructor: ( id ) ->
		@video = document.getElementById id
		@checkWebcamCompatibility()
		
	checkWebcamCompatibility: ->
		# Get the stream from the camera using getUserMedia
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia
		if navigator.getUserMedia
			console.info "User media is on, let's go !"
			navigator.getUserMedia({video: true, audio: false}, @success, @error)
		else
			# video.src = 'somevideo.webm'; // fallback.
			console.info "User media is not accessible on this Browser version"
	
	error: ( error ) ->
		console.log error
		console.error 'An error on streaming: [CODE ' + error.code + ']'
			
	success: ( stream ) ->
		window.URL = window.URL || window.webkitURL || window.mozURL || window.msURL
		@stream = stream or window.URL.createObjectURL(stream)
		@video.src = @stream
		@video.play()
	

window.Webcam = Webcam # export scope