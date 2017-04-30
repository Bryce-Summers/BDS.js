###
   G_Canvas.coffee
 
   Implementation of BDS.G_Interface that allowes user to draw BDS objects onto an HTML5 Canvas.
  
   Original written by Bryce Summers on Bryce Summers on 1 - 4 - 2017 for the Scribble.js demo series.
   Factored here as part of creating the IO library on 4 - 4 - 2017. 
###

class BDS.G_Canvas


    constructor: (@_canvas) ->

        @ctx = @_canvas.getContext("2d")
        # Draw white Lines.
        @ctx.strokeStyle = '#ffffff'

        # FIXME: Get the actual dimensions of the canvas.
        @w = @_canvas.width
        @h = @_canvas.height

        # Black color.
        @_background_color = 0xaaaaaa

    clearScreen: () ->
    
        @ctx = @ctx

        # Store the current transformation matrix
        @ctx.save()

        # Use the identity matrix while clearing the canvas
        @ctx.setTransform(1, 0, 0, 1, 0, 0)
        @fillColor(@_background_color)
        @ctx.clearRect(0, 0, @_canvas.width, @_canvas.height)

        # Restore the transform
        @ctx.restore()
    

    # #rrggbb (number)
    strokeColor: (color) ->
    
        str = color.toString(16);
        if str.length <= 6
            str = "000000" + str;
            str = str.substr(-6);
        else # Handle Alpha Component.
            str = "00000000" + str;
            str = str.substr(-8);

        # Create a hex color string with the full 6 characters.
        @ctx.strokeStyle = '#' + str;

    # 0xrrggbb (number)
    fillColor: (color) ->
    
        str = color.toString(16);
        if str.length <= 6
            str = "000000" + str;
            str = str.substr(-6);
        else # Handle Alpha Component.
            str = "00000000" + str;
            str = str.substr(-8);

        @ctx.fillStyle = '#' + str

    # 0.0 - 1.0
    setAlpha: (percentage) ->
        @ctx.globalAlpha = percentage

    lineWidth: (width) ->

        @ctx.lineWidth = width

    randomColor: () ->
    
        red   = Math.random()*256
        green = Math.random()*256
        blue  = Math.random()*256

        red   = Math.floor(red)
        green = Math.floor(green)
        blue  = Math.floor(blue)

        # Pack the red, green, and blue components into a hex integer color.
        red   = red   << 16
        green = green << 8

        return red + green + blue

    # [0, 255] range integer color constructor.
    newColor: (red, green, blue) ->
    
        red   = red << 16
        green = green << 8

        return red + green + blue

    # Interpolates between color 1 and color 2 in each of the red, green, and blue channels.
    # Percentage marks how what percent of color 2.
    interpolateColor: (c1, c2, percentage) ->

        p1 = 1 - percentage
        p2 = percentage

        red   = @getRed(c1)*p1   + @getRed(c2)*p2
        green = @getGreen(c1)*p1 + @getGreen(c2)*p2
        blue  = @getBlue(c1)*p1  + @getBlue(c2)*p2

        red = Math.floor(red)
        green = Math.floor(green)
        blue = Math.floor(blue)

        return @newColor(red, green, blue)


    getRed: (color) ->
        return color >> 16

    getGreen: (color) ->
        return (color >> 8) & 0xff

    getBlue: (color) ->
        return (color >> 0) & 0xff

    # Input: SCRIB.Line
    drawArrow: (line, size) ->

        @drawScribLine(line)

        p1 = line.p1
        p2 = line.p2

        len = line.offset.norm()
            
        par_x = (p1.x - p2.x)/len
        par_y = (p1.y - p2.y)/len
        
        # /2 provides slant.
        perp_x = -par_y*size/3
        perp_y =  par_x*size/3
        
        par_x *= size
        par_y *= size
                
        # Arrow head.
        @drawLine(p2.x, p2.y, p2.x + par_x + perp_x, p2.y + par_y + perp_y)
        @drawLine(p2.x, p2.y, p2.x + par_x - perp_x, p2.y + par_y - perp_y)

    # Input: SCRIB.Line
    drawScribLine: (line) ->
    
        p1 = line.p1
        p2 = line.p2

        @drawLine(p1.x, p1.y, p2.x, p2.y)

    drawLine: (x1, y1, x2, y2) ->
    
        @ctx = @ctx
        @ctx.moveTo(x1, y1)
        @ctx.lineTo(x2, y2)
        @ctx.stroke()

    drawScreenBounds: () ->

        polyline = @getScreenBoundsPolyline()
        @fillColor(0xffffff)
        @drawPolyline(polyline)

    getScreenBoundsPolyline: () ->
        pts = []
        pts.push(new BDS.Point(1,  1))
        pts.push(new BDS.Point(@w, 1))
        pts.push(new BDS.Point(@w, @h))
        pts.push(new BDS.Point(1,  @h))
        polyline = new BDS.Polyline(true, pts, false)
        return polyline

    # Draws a SCRIB.Polyline.
    drawPolyline: (polyline) ->
        @drawPolygon(polyline, true, false)

    drawPolygon: (polyline, drawStroke, drawFill) ->

        if drawFill == undefined
            drawFill = true
        
        if drawStroke == undefined
            drawStroke = true
        
        len = polyline.size()

        if len < 2
            return

        @ctx = @ctx
        @ctx.beginPath()

        p0 = polyline.getPoint(0)
        @ctx.moveTo(p0.x, p0.y)

        for i in [1...len] by 1 #(var i = 1; i < len; i++)
    
            p = polyline.getPoint(i)
            @ctx.lineTo(p.x, p.y)

        if polyline.isClosed()
            @ctx.closePath()

        if drawStroke
           @ctx.stroke()

        if drawFill
        
            @ctx.fill()

    drawPolygonsEvenOdd: (polylines) ->
    
        @ctx = @ctx
        @ctx.beginPath()

        len = polylines.length
        for i in [0...len] by 1 #(i = 0; i < len; i++)
        
            polyline = polylines[i]
            @_drawSubPath(polyline)

        @ctx.fill('evenodd')


    # Draw a path in a even-odd polygon fill.
    _drawSubPath: (polyline) ->
    
        len = polyline.size()

        if len < 2
            return

        @ctx = @ctx

        p0 = polyline.getPoint(0)
        @ctx.moveTo(p0.x, p0.y)

        for i in [1...len] by 1
        
            p = polyline.getPoint(i)
            @ctx.lineTo(p.x, p.y)

        if polyline.isClosed()
            @ctx.closePath()

    # Draws a BDS.Bezier_Curve onto the canvas.
    drawBezier: (curve) ->

        [c0, c1, c2, c3] = curve.toBezierControlPoints()

        @ctx = @ctx
        @ctx.beginPath()
        @ctx.moveTo(c0.x, c0.y)
        @ctx.bezierCurveTo(c1.x, c1.y, c2.x, c2.y, c3.x, c3.y)
        @ctx.stroke()

    drawBezierLoop: (curves, drawStroke, drawFill) ->

        if drawFill == undefined
            drawFill = true

        if drawStroke == undefined
            drawStroke = true

        @ctx = @ctx
        @ctx.beginPath()
        p0 = curves[0].position(0) # Initial position is equivalent to the initial Bezier Control Point.
        @ctx.moveTo(p0.x, p0.y)

        len = curves.length
        for i in [0...len] by 1#(var i = 0; i < len; i++)
        
            curve = curves[i]

            [c0, c1, c2, c3] = curve.toBezierControlPoints()

            @ctx.bezierCurveTo(c1.x, c1.y, c2.x, c2.y, c3.x, c3.y)

            # Note: c3 is the first control point for the following curve.
            # The curve will definatly exhibit G0 continuity.

        # Close the path at the end.
        @ctx.closePath()

        if drawStroke
           @ctx.stroke()
        

        if drawFill
            @ctx.fill()

    # Takes a BDS.Circle and draws it to the screen.
    drawCircle: (circle) ->

        position = circle.getPosition()
        cx = position.x
        cy = position.y
        radius = circle.getRadius()


        @ctx = @ctx
        @ctx.beginPath()
        @ctx.arc(cx, cy, radius, 0, 2 * Math.PI, false)
        @ctx.closePath()

        # fill in the circle if it is filled.
        if circle.isFilled()
            @ctx.fill()

        @ctx.stroke()

    drawText: (str, x, y) ->
    
        @ctx = @ctx
        @ctx.fillText(str, x, y)

    drawImage: (img, x, y) ->
        @ctx.drawImage(img, x, y)
