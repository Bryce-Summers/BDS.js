// Generated by CoffeeScript 1.11.1

/*
   G_Canvas.coffee
 
   Implementation of BDS.G_Interface that allowes user to draw BDS objects onto an HTML5 Canvas.
  
   Original written by Bryce Summers on Bryce Summers on 1 - 4 - 2017 for the Scribble.js demo series.
   Factored here as part of creating the IO library on 4 - 4 - 2017.
 */

(function() {
  BDS.G_Canvas = (function() {
    function G_Canvas(_canvas) {
      this._canvas = _canvas;
      this.ctx = this._canvas.getContext("2d");
      this.ctx.strokeStyle = '#ffffff';
      this.w = this._canvas.width;
      this.h = this._canvas.height;
      this._background_color = 0xaaaaaa;
    }

    G_Canvas.prototype.clearScreen = function() {
      this.ctx = this.ctx;
      this.ctx.save();
      this.ctx.setTransform(1, 0, 0, 1, 0, 0);
      this.fillColor(this._background_color);
      this.ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);
      return this.ctx.restore();
    };

    G_Canvas.prototype.backgroundColor = function(color) {
      return this._background_color = color;
    };

    G_Canvas.prototype.strokeColor = function(color) {
      var str;
      str = color.toString(16);
      if (str.length <= 6) {
        str = "000000" + str;
        str = str.substr(-6);
      } else {
        str = "00000000" + str;
        str = str.substr(-8);
      }
      return this.ctx.strokeStyle = '#' + str;
    };

    G_Canvas.prototype.fillColor = function(color) {
      var str;
      str = color.toString(16);
      if (str.length <= 6) {
        str = "000000" + str;
        str = str.substr(-6);
      } else {
        str = "00000000" + str;
        str = str.substr(-8);
      }
      return this.ctx.fillStyle = '#' + str;
    };

    G_Canvas.prototype.setAlpha = function(percentage) {
      return this.ctx.globalAlpha = percentage;
    };

    G_Canvas.prototype.lineWidth = function(width) {
      return this.ctx.lineWidth = width;
    };

    G_Canvas.prototype.randomColor = function() {
      var blue, green, red;
      red = Math.random() * 256;
      green = Math.random() * 256;
      blue = Math.random() * 256;
      red = Math.floor(red);
      green = Math.floor(green);
      blue = Math.floor(blue);
      red = red << 16;
      green = green << 8;
      return red + green + blue;
    };

    G_Canvas.prototype.newColor = function(red, green, blue) {
      red = red << 16;
      green = green << 8;
      return red + green + blue;
    };

    G_Canvas.prototype.interpolateColor = function(c1, c2, percentage) {
      var blue, green, p1, p2, red;
      p1 = 1 - percentage;
      p2 = percentage;
      red = this.getRed(c1) * p1 + this.getRed(c2) * p2;
      green = this.getGreen(c1) * p1 + this.getGreen(c2) * p2;
      blue = this.getBlue(c1) * p1 + this.getBlue(c2) * p2;
      red = Math.floor(red);
      green = Math.floor(green);
      blue = Math.floor(blue);
      return this.newColor(red, green, blue);
    };

    G_Canvas.prototype.getRed = function(color) {
      return color >> 16;
    };

    G_Canvas.prototype.getGreen = function(color) {
      return (color >> 8) & 0xff;
    };

    G_Canvas.prototype.getBlue = function(color) {
      return (color >> 0) & 0xff;
    };

    G_Canvas.prototype.drawArrow = function(line, size) {
      var len, p1, p2, par_x, par_y, perp_x, perp_y;
      this.drawScribLine(line);
      p1 = line.p1;
      p2 = line.p2;
      len = line.offset.norm();
      par_x = (p1.x - p2.x) / len;
      par_y = (p1.y - p2.y) / len;
      perp_x = -par_y * size / 3;
      perp_y = par_x * size / 3;
      par_x *= size;
      par_y *= size;
      this.drawLine(p2.x, p2.y, p2.x + par_x + perp_x, p2.y + par_y + perp_y);
      return this.drawLine(p2.x, p2.y, p2.x + par_x - perp_x, p2.y + par_y - perp_y);
    };

    G_Canvas.prototype.drawScribLine = function(line) {
      var p1, p2;
      p1 = line.p1;
      p2 = line.p2;
      return this.drawLine(p1.x, p1.y, p2.x, p2.y);
    };

    G_Canvas.prototype.drawLine = function(x1, y1, x2, y2) {
      this.ctx = this.ctx;
      this.ctx.moveTo(x1, y1);
      this.ctx.lineTo(x2, y2);
      return this.ctx.stroke();
    };

    G_Canvas.prototype.drawScreenBounds = function() {
      var polyline;
      polyline = this.getScreenBoundsPolyline();
      this.fillColor(0xffffff);
      this.drawPolyline(polyline);
    };

    G_Canvas.prototype.fillScreen = function() {
      this.ctx.fillRect(0, 0, this.w, this.h);
    };

    G_Canvas.prototype.getScreenBoundsPolyline = function() {
      var polyline, pts;
      pts = [];
      pts.push(new BDS.Point(1, 1));
      pts.push(new BDS.Point(this.w, 1));
      pts.push(new BDS.Point(this.w, this.h));
      pts.push(new BDS.Point(1, this.h));
      polyline = new BDS.Polyline(true, pts, false);
      return polyline;
    };

    G_Canvas.prototype.drawPolyline = function(polyline) {
      return this.drawPolygon(polyline, true, false);
    };

    G_Canvas.prototype.drawPolygon = function(polyline, drawStroke, drawFill) {
      var i, j, len, p, p0, ref;
      if (drawFill === void 0) {
        drawFill = true;
      }
      if (drawStroke === void 0) {
        drawStroke = true;
      }
      len = polyline.size();
      if (len < 2) {
        return;
      }
      this.ctx = this.ctx;
      this.ctx.beginPath();
      p0 = polyline.getPoint(0);
      this.ctx.moveTo(p0.x, p0.y);
      for (i = j = 1, ref = len; j < ref; i = j += 1) {
        p = polyline.getPoint(i);
        this.ctx.lineTo(p.x, p.y);
      }
      if (polyline.isClosed()) {
        this.ctx.closePath();
      }
      if (drawStroke) {
        this.ctx.stroke();
      }
      if (drawFill) {
        return this.ctx.fill();
      }
    };

    G_Canvas.prototype.drawPolygonsEvenOdd = function(polylines) {
      var i, j, len, polyline, ref;
      this.ctx = this.ctx;
      this.ctx.beginPath();
      len = polylines.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        polyline = polylines[i];
        this._drawSubPath(polyline);
      }
      return this.ctx.fill('evenodd');
    };

    G_Canvas.prototype._drawSubPath = function(polyline) {
      var i, j, len, p, p0, ref;
      len = polyline.size();
      if (len < 2) {
        return;
      }
      this.ctx = this.ctx;
      p0 = polyline.getPoint(0);
      this.ctx.moveTo(p0.x, p0.y);
      for (i = j = 1, ref = len; j < ref; i = j += 1) {
        p = polyline.getPoint(i);
        this.ctx.lineTo(p.x, p.y);
      }
      if (polyline.isClosed()) {
        return this.ctx.closePath();
      }
    };

    G_Canvas.prototype.drawBezier = function(curve) {
      var c0, c1, c2, c3, ref;
      ref = curve.toBezierControlPoints(), c0 = ref[0], c1 = ref[1], c2 = ref[2], c3 = ref[3];
      this.ctx = this.ctx;
      this.ctx.beginPath();
      this.ctx.moveTo(c0.x, c0.y);
      this.ctx.bezierCurveTo(c1.x, c1.y, c2.x, c2.y, c3.x, c3.y);
      return this.ctx.stroke();
    };

    G_Canvas.prototype.drawBezierLoop = function(curves, drawStroke, drawFill) {
      var c0, c1, c2, c3, curve, i, j, len, p0, ref, ref1;
      if (drawFill === void 0) {
        drawFill = true;
      }
      if (drawStroke === void 0) {
        drawStroke = true;
      }
      this.ctx = this.ctx;
      this.ctx.beginPath();
      p0 = curves[0].position(0);
      this.ctx.moveTo(p0.x, p0.y);
      len = curves.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        curve = curves[i];
        ref1 = curve.toBezierControlPoints(), c0 = ref1[0], c1 = ref1[1], c2 = ref1[2], c3 = ref1[3];
        this.ctx.bezierCurveTo(c1.x, c1.y, c2.x, c2.y, c3.x, c3.y);
      }
      this.ctx.closePath();
      if (drawStroke) {
        this.ctx.stroke();
      }
      if (drawFill) {
        return this.ctx.fill();
      }
    };

    G_Canvas.prototype.drawCircle = function(circle) {
      var cx, cy, position, radius;
      position = circle.getPosition();
      cx = position.x;
      cy = position.y;
      radius = circle.getRadius();
      this.ctx = this.ctx;
      this.ctx.beginPath();
      this.ctx.arc(cx, cy, radius, 0, 2 * Math.PI, false);
      this.ctx.closePath();
      if (circle.isFilled()) {
        this.ctx.fill();
      }
      this.ctx.stroke();
    };

    G_Canvas.prototype.centerAlignFont = function() {
      this.ctx.textAlign = "center";
    };

    G_Canvas.prototype.leftAlignFont = function() {
      this.ctx.textAlign = "left";
    };

    G_Canvas.prototype.rightAlignFont = function() {
      this.ctx.textAlign = "right";
    };

    G_Canvas.prototype.setFont = function(font_name, size) {
      this.ctx.font = size + "pt " + font_name;
    };

    G_Canvas.prototype.drawText = function(str, x, y) {
      this.ctx.fillText(str, x, y);
    };

    G_Canvas.prototype.drawImage = function(img, x, y) {
      this.ctx.drawImage(img, x, y);
    };

    return G_Canvas;

  })();

}).call(this);
