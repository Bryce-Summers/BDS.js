###

Universal Input Controller.

Purpose: Interface for all user input controllers.

###

class BDS.Interface_Controller_All

    constructor: () ->
        @_active = true 

    setActive: (isActive) -> @_active = isActive
    isActive: () -> @_active

    mouse_down: (event) ->
    mouse_up:   (event) ->
    mouse_move: (event) ->
    time: (dt) ->
    window_resize: (event) ->