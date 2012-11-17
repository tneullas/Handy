// Generated by CoffeeScript 1.3.3
(function() {
  var Bubble;

  Bubble = (function() {

    function Bubble(id) {
      this.id = id;
    }

    Bubble.prototype.draw = function(context, color) {
      var height, width;
      context.strokeStyle = '#F0F';
      context.beginPath();
      width = context.canvas.width;
      height = context.canvas.height;
      context.arc(Math.round(width / 3 + (2 % this.id) * width / 6), Math.round(height / 3 + (this.id % 2) * height / 3), 30, 0, Math.PI * 2, true);
      context.stroke();
      context.closePath();
      if (color !== void 0) {
        context.fillStyle = color;
        return context.fill();
      }
    };

    return Bubble;

  })();

  window.Bubble = Bubble;

}).call(this);