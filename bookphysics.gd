extends Node3D

@export var float_amplitude: float = 0.1   # Up/down bobbing height
@export var float_speed: float = 0.5       # Bobbing speed
@export var rotate_range: float = 8.0     # Max degrees left/right
@export var rotate_speed: float = 0.6      # Oscillation speed

var _original_y: float
var _original_rot_y: float
var _time_passed: float = 0.0

func _ready():
	_original_y = global_position.y
	_original_rot_y = rotation_degrees.y

func _process(delta):
	_time_passed += delta

	# Float vertically
	var bob = sin(_time_passed * float_speed) * float_amplitude
	global_position.y = _original_y + bob

	# Oscillate rotation left/right
	var rot = sin(_time_passed * rotate_speed) * rotate_range
	rotation_degrees.y = _original_rot_y + rot
