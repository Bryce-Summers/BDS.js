###

Universal Input Controller.

Purpose: Interface for all user input controllers.

###

class BDS.Interface_Controller_All

    constructor: () ->
        @_active = false 

    setActive: (isActive) ->
    isActive: () ->

    mouse_down: (event) ->
    mouse_up:   (event) ->
    mouse_move: (event) ->
    time: (dt) ->
    window_resize: (event) ->