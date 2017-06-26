###

Universal Input Controller.

Purpose: Interface for all user input controllers.

###

class BDS.Interface_Controller_All 

    constructor: () ->
        @_active = true 

    setActive: (isActive) -> @_active = isActive
    isActive: () -> @_active

    # Mouse Input.
    mouse_down: (event) ->
    mouse_up:   (event) ->
    mouse_move: (event) ->

    # Keyboard Input.
    key_down:(event) ->
    key_up: (event)  ->
    #key_pressed: (event) -> # I think this could be implemented better using time.

    time: (dt) ->
    window_resize: (event) ->