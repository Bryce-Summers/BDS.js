// Generated by CoffeeScript 1.11.1

/*

Grouping Controller.

This controller routes inputs to a set of sub input controllers.
It allows for sub controllers to be added, removed, etc.
It manages the active controller, such as in tool systems, where only one tool controller may be active at a time.

Factored on 4.4.17 by Bryce Summers.
 */

(function() {
  BDS.Controller_Group = (function() {
    function Controller_Group() {
      this._mouse_input_controllers = [];
      this._keyboard_input_controllers = [];
      this._time_input_controllers = [];
      this._system_controllers = [];
      this.time_on = false;
      this._active = true;
    }

    Controller_Group.prototype.setActive = function(isActive) {
      return this._active = isActive;
    };

    Controller_Group.prototype.isActive = function() {
      return this._active;
    };

    Controller_Group.prototype.add_universal_controller = function(controller) {
      this._mouse_input_controllers.push(controller);
      this._keyboard_input_controllers.push(controller);
      this._time_input_controllers.push(controller);
      return this._system_controllers.push(controller);
    };

    Controller_Group.prototype.add_mouse_input_controller = function(controller) {
      return this._mouse_input_controllers.push(controller);
    };

    Controller_Group.prototype.add_keyboard_input_controller = function(controller) {
      return this._keyboard_input_controllers.push(controller);
    };

    Controller_Group.prototype.add_time_input_controller = function(controller) {
      return this._time_input_controllers.push(controller);
    };

    Controller_Group.prototype.add_system_controller = function(controller) {
      return this._system_controllers.push(controller);
    };

    Controller_Group.prototype.mouse_down = function(event) {
      var controller, i, j, len, ref;
      len = this._mouse_input_controllers.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        controller = this._mouse_input_controllers[i];
        if (controller.isActive()) {
          controller.mouse_down(event);
        }
      }
    };

    Controller_Group.prototype.mouse_up = function(event) {
      var controller, i, j, len, ref;
      len = this._mouse_input_controllers.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        controller = this._mouse_input_controllers[i];
        if (controller.isActive()) {
          controller.mouse_up(event);
        }
      }
    };

    Controller_Group.prototype.mouse_move = function(event) {
      var controller, i, j, len, ref;
      len = this._mouse_input_controllers.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        controller = this._mouse_input_controllers[i];
        if (controller.isActive()) {
          controller.mouse_move(event);
        }
      }
    };

    Controller_Group.prototype.time = function(dt) {
      var controller, i, j, len, ref;
      len = this._time_input_controllers.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        controller = this._time_input_controllers[i];
        if (controller.isActive()) {
          controller.time(dt);
        }
      }
    };

    Controller_Group.prototype.window_resize = function(event) {
      var controller, i, j, len, ref;
      len = this._system_controllers.length;
      for (i = j = 0, ref = len; j < ref; i = j += 1) {
        controller = this._system_controllers[i];
        if (controller.isActive()) {
          controller.window_resize();
        }
      }
    };

    return Controller_Group;

  })();

}).call(this);