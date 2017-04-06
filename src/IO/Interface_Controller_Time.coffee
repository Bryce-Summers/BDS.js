###

Universal Input Controller.

Purpose: Interface for all user input controllers.

###

class BDS.Interface_Controller_Time

    constructor: () ->
        @_active = true 

    setActive: (isActive) -> @_active = isActive
    isActive: () -> @_active

    time: (dt) ->