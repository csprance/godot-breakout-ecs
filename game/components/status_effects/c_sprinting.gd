class_name C_Sprinting
extends Component

# The speed multiplier during sprinting
@export var speed_mult: float = 1.5
# The duration of the sprinting
@export var duration: float = 0.5
# The cooldown after sprinting
@export var cooldown: float = 1.0
# The timer for the sprint
var timer: float = 0.0
var original_speed := 0.0

func _init(_speed_mult = speed_mult, _duration = duration, _cooldown = cooldown) -> void:
    speed_mult = _speed_mult
    duration = _duration
    cooldown = _cooldown
