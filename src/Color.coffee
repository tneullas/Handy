class Color
	constructor: ( r = 0, g = 0, b = 0, a = 255 ) ->
		@r = r
		@g = g
		@b = b
		@a = a
		
	to_hex: ->
		return "#" + Color._ts( @r ) + Color._ts( @g ) + Color._ts( @b )
		
	to_rgba: ->
		return "rgba(#{@r}, #{@g}, #{@b}, #{@a})"

	to_hsv: ->
		Color.rgb_to_hsv @r, @g, @b

	get: ->
		return this
	
	equalsWithTolerance: ( colorAsArray, tolerance ) ->
		if ( ( colorAsArray[ 0 ] - tolerance ) <= @r and ( colorAsArray[ 0 ] + tolerance ) >= @r and ( colorAsArray[ 1 ] - tolerance ) <= @g and ( colorAsArray[ 1 ] + tolerance ) >= @g and ( colorAsArray[ 2 ] - tolerance ) <= @b and ( colorAsArray[ 2 ] + tolerance ) >= @b and ( colorAsArray[ 3 ] - tolerance ) <= @a and ( colorAsArray[ 2 ] + tolerance ) >= @a )
			return true
		else
			return false
	
	set: ( val )->
		if val instanceof Color
			@r = val.r
			@g = val.g
			@b = val.b
			@a = val.a
		else if typeof( val ) == 'string' and val[ 0 ] == "#"
			if val.length == 4
				@r = "0x" + val.slice( 1, 2 ) + val.slice( 1, 2 )
				@g = "0x" + val.slice( 2, 3 ) + val.slice( 2, 3 )
				@b = "0x" + val.slice( 3, 4 ) + val.slice( 3, 4 )
				@a = 255
			else if val.length == 7
				@r = "0x" + val.slice( 1, 3 )
				@g = "0x" + val.slice( 3, 5 )
				@b = "0x" + val.slice( 5, 7 )
				@a = 255
			else
				console.error "get color #{val}" 
		else
			console.error "get color #{val}" 
		

	# rbg between 0 and 255. hsv between 0 and 1
	rgb_to_hsv: ( r, g, b ) ->
		r /= 255.0
		g /= 255.0
		b /= 255.0
	
		# v
		min = Math.min r, g, b
		max = Math.max r, g, b
		del = max - min
		
		# s
		if max
			s = del / max
		else
			return [ 0, 0, 0 ]

		# h
		del += not del
		if r == max
			h = ( g - b ) / del
		else if g == max
			h = 2 + ( b - r ) / del
		else
			h = 4 + ( r - g ) / del
		
		h *= 60.0 / 360.0
		if h < 0
			h += 1
			
		[ h, s, max ]

	# taken from http://alvyray.com/Papers/CG/hsv2rgb.htm
	hsv_to_rgb: ( h, s, v ) ->
		h *= 6
		i = Math.floor h
		f = h - i
		if not ( i & 1 )
			f = 1 - f
		m = Math.round 255 * v * ( 1 - s )
		n = Math.round 255 * v * ( 1 - s * f )
		v = Math.round 255 * v
		switch i
			when 1 then [ n, v, m ]
			when 2 then [ m, v, n ]
			when 3 then [ m, n, v ]
			when 4 then [ n, m, v ]
			when 5 then [ v, m, n ]
			else		[ v, n, m ]

			
	_ts: ( v ) ->
		r = v.toString( 16 )
		if r.length == 1
			r = "0" + r
		return r
		
window.Color = Color # export scope