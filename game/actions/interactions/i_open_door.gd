class_name OpenDoorInteraction
extends Interaction

func _interaction(interactable: Entity, interactors: Array, meta: Dictionary = {}) -> bool:
    # Make sure we're a door. 
    # play an animation to open the door
    interactable.add_component(C_PlayAnimation.new("open_door"))
    for i in interactors:
        i.remove_component(C_Interacting)
     # doors only work once
    interactable.remove_component(C_Interactable)
    return true
    