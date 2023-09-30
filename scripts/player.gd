extends Human
class_name Player



func _physics_process(_delta):
    
    # if any GUI is focused, ignore move inputs
    if get_viewport().gui_get_focus_owner(): return

    var moveX := Input.get_axis("move_left", "move_right")
    var moveY := Input.get_axis("move_up", "move_down")
    var moveInput := Vector2(moveX, moveY).normalized()
    
    if moveInput.length_squared() > 0:
        $"interaction-area".position = Vector2(0, -2.0) + moveInput * Vector2(5.0, 4.0)
    
    velocity = moveInput * walkSpeed
    move_and_slide()

func _process(_delta):
    
    if Input.is_action_just_pressed("interact"):
        interact()
        

func sortingFunction(a, b):
    # prefer interacting with containers first
    if b is ItemContainer: return false
    if a is ItemContainer: return true
    
    # sort by distance
    return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)


func interact():
    
    var overlappingBodies := $"interaction-area".get_overlapping_bodies() as Array[Node2D]
    var overlappingAreas := $"interaction-area".get_overlapping_areas() as Array[Area2D]
    
    overlappingBodies.append_array(overlappingAreas)
    overlappingBodies.sort_custom(sortingFunction)
    
    # interact with the first interactible overlapping body
    for body in overlappingBodies:
        
        if body.is_in_group('door'):
            (body as Door).toggle()
            return
        if body.is_in_group('door-area'):
            (body.get_parent() as Door).toggle()
            return
        
        if body is ItemContainer:
            var container := body as ItemContainer
            
            if isCarryingAnything():
                if container.canStoreItem():
                    var item := dropItem()
                    if item:
                        container.storeItem(item)
                        return
            elif container.hasAnyItems():
                if container.capacity > 1:
                    container.focusUI()
                    return
                else:
                    var item := container.retrieveItem()
                    if item:
                        pickItem(item)
                        return
        
        if body.is_in_group('pickable') and not isCarryingAnything():
            pickItem(body)
            return
            
    
    # if nothing can be interacted with, the player can drop the item they are carrying
    if isCarryingAnything():
        dropItem()
