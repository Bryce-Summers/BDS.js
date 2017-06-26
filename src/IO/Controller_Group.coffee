###

Grouping Controller.

This controller routes inputs to a set of sub input controllers.
It allows for sub controllers to be added, removed, etc.
It manages the active controller, such as in tool systems, where only one tool controller may be active at a time.

Factored on 4.4.17 by Bryce Summers.

###

class BDS.Controller_Group #extends BDS.Interface_Controller_All

    constructor: () ->

        # FIXME: We need an order and add/remove functionality here.
        # currently first controller in is the first controller drawn.

        @_mouse_input_controllers    = []
        @_keyboard_input_controllers = []
        @_time_input_controllers     = []

        # Things like window resize.
        @_system_controllers         = []

        @time_on = false

        @_active = true

    # Note: All controllers specify whether they are active or not.
    setActive: (isActive) -> @_active = isActive
    isActive: () -> @_active

    # Adds a controller that handles all inputs.
    add_universal_controller: (controller) ->
    
        # Add this controller to all controller categories.
        @_mouse_input_controllers.push(controller)
        @_keyboard_input_controllers.push(controller)
        @_time_input_controllers.push(controller)
        @_system_controllers.push(controller)

    add_mouse_input_controller: (controller) ->
        @_mouse_input_controllers.push(controller)

    add_keyboard_input_controller: (controller) ->
        @_keyboard_input_controllers.push(controller)


    add_time_input_controller: (controller) ->
        @_time_input_controllers.push(controller)

    add_system_controller: (controller) ->
        @_system_controllers.push(controller)

    mouse_down: (event) ->

        # event.x, event.y are the coordinates for the mouse button.
        # They are originally piped in from screeen space from [0, screen_w] x [0, screen_h]
        len = @_mouse_input_controllers.length
        for i in [0...len] by 1 #(var i = 0; i < len; i++)
            controller = @_mouse_input_controllers[i]
            controller.mouse_down(event) if controller.isActive()
        return

    mouse_up: (event) ->

        len = @_mouse_input_controllers.length
        for i in [0...len] by 1 # (var i = 0; i < len; i++)
            controller = @_mouse_input_controllers[i]
            controller.mouse_up(event) if controller.isActive()
        return

    mouse_move: (event) ->

        len = @_mouse_input_controllers.length
        for i in [0...len] by 1 #(var i = 0; i < len; i++)
        
            controller = @_mouse_input_controllers[i]
            controller.mouse_move(event) if controller.isActive()
        return


    key_down:(event) ->
        len = @_keyboard_input_controllers.length
        for i in [0...len] by 1 # (var i = 0; i < len; i++)
            controller = @_keyboard_input_controllers[i]
            controller.key_down(event) if controller.isActive()
        return

    key_up: (event)  ->
        len = @_keyboard_input_controllers.length
        for i in [0...len] by 1 # (var i = 0; i < len; i++)
            controller = @_keyboard_input_controllers[i]
            controller.key_up(event) if controller.isActive()

    key_pressed: (event) ->
        len = @_keyboard_input_controllers.length
        for i in [0...len] by 1 # (var i = 0; i < len; i++)
            controller = @_keyboard_input_controllers[i]
            controller.key_pressed(event) if controller.isActive()



    # Difference in time between the previous call and this call.
    time: (dt) ->
    
        len = @_time_input_controllers.length
        for i in [0...len] by 1 # (var i = 0; i < len; i++)
            controller = @_time_input_controllers[i]
            controller.time(dt) if controller.isActive()

        return

    window_resize: (event) ->

        len = @_system_controllers.length
        for i in [0...len] by 1 #(var i = 0; i < len; i++)
        
            controller = @_system_controllers[i]
            controller.window_resize() if controller.isActive()

        return