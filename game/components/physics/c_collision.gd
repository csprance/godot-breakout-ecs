## This just represents a collision that has happened
class_name C_Collision
extends Component

var collision:KinematicCollision3D

func _init(_collision: KinematicCollision3D) -> void:
    collision = _collision