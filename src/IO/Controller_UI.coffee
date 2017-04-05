# Manages a bunch of UI elements and triggering their actions.
# Handles the coloring and visual display logic for UI elements.
class BDS.Controller_UI

    constructor: (@_G) ->

        # @_G is a graphics object that allows us to draw the UI to the screen.

        # The UI_Controller represents the span of all UI elements
        # within a bounding volume hiearchy.
        # Associates polylines with their functions.
        @_bvh = new BDS.BVH2D([])

        @_elements = new Set()

        # Records whether the mouse is currently in a depressed state.
        @_mouse_pressed = false

        # Stores the element that the mouse is curently on top of.
        # ASSUMPTION: UI Components should not be located on top of each other.
        #             Perhaps I can change this to allow for overlayed venn-diagram like buttons in the future.
        @_hover_element   = null

        # The last element that the user has clicked on.
        # This gets sent back to null when the user is not in the middle of a UI action.
        @_clicked_element = null

        # Hexadecimal color integers.
        # 70 is the alpha value. aarrggbb
        @_c_resting       = 0xe6dada
        @_c_hover_nopress = 0xfaf8f8
        @_c_hover_pressed = 0xa0a0a0
        @_c_nohover_press = 0xc7acac

        @_active = true


    setActive: (isActive) -> @_active = isActive
    isActive: () -> return this._active

    createButton: (polyline, click_function, img) ->
    
        ###
         * An element is an associative object of the following form:
         * {click:    () -> what happens when the user clicks on this element,
         *  fill:     The current fill color used to indicate the state of the button. 
         *  polyline: The polyline that represents the spatial extent for this UI element.
        ###

        element = {click: click_function, color: @_c_resting, polyline:polyline, image: img}
        polyline.setAssociatedData(element)
        @_bvh.add(polyline)
        @_elements.add(element)
    

    # Converts the current hover element to a clicked element.
    mouse_down: (event) ->
    
        # Only trigger once.
        if @_mouse_pressed
            return
        
        @_mouse_pressed = true
        
        # If we are hovering over an element, then we sent is to the pressed state.
        if @_hover_element != null        
            @_clicked_element = @_hover_element
            @_clicked_element.color = @_c_hover_pressed

    # Updates the current hover element.
    # Manages colorations for UI elements.
    mouse_move: (event) ->
    
        pt = new BDS.Point(event.x, event.y)

        # Note: We could have used .query_point_all() to retrieve all points at that location.
        polyline = @_bvh.query_point(pt)
        element  = null

        if polyline != null
            element = polyline.getAssociatedData()

        # First decolor the previous hovered component. We'll recolor it soon after if it is special.
        if @_hover_element != null
            @_hover_element.color = @_c_resting

        # Change the hover element.
        # It might be null.
        @_hover_element = element

        if @_hover_element != null
            @_hover_element.color   = @_c_hover_nopress

        # Now upgrade components to pressed colors.
        if @_clicked_element != null
        
            if @_clicked_element == @_hover_element
                @_clicked_element.color = @_c_hover_pressed
            else
                @_clicked_element.color = @_c_hover_nopress

    # Triggers the UI element if the hover element is still equal to the clicked on element.
    # Resets the controller to a resting state.
    mouse_up: (event) ->


        if not @_mouse_pressed
            return

        if @_clicked_element == null
            # Revert back to the resting state.
            @finish()
            return

        if @_hover_element == @_clicked_element

            @_hover_element.click()
            @_hover_element.color = @_c_hover_nopress
        

        # Revert back to the resting state.
        @finish()


    # Manages User signals such as flashes.
    # Draws all of the elements to the screen.
    # dt is the difference in time from the previous call.
    time: (dt) ->

        # ASSUMPTION: No elements are overlapping...
        #for (let element of @elements)
        self = @
        @_elements.forEach (element) =>
        
            polyline = element.polyline
            fill     = element.color

            # Top left corner.
            pt  = polyline.getFirstPoint()

            # Icon.
            img = element.image
            self._G.drawImage(img, pt.x, pt.y)

            # Interior.
            self._G.setAlpha(.2)
            self._G.fillColor(fill)
            self._G.drawPolygon(polyline)
            self._G.setAlpha(1.0)

            # Exterior.
            self._G.fillColor(0xffffff)
            self._G.drawPolyline(polyline)


    # TODO: Not yet implemented.
    window_resize: (event) ->
    
        # ??? Resize or relayout the User interface???
        # Form rows if the screen becomes too tight.

    # This function may be used to revert this controller to its resting state.
    finish: () ->

        @_mouse_pressed   = false

        # We have finished our click.
        @_clicked_element = null
