extends CharacterBody3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.003

@onready var camera_pivot = $Node3D

var look_vertical: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		look_vertical = clamp(look_vertical - event.relative.y * mouse_sensitivity, -PI/2, PI/2)
		camera_pivot.rotation.x = look_vertical

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x

	if Input.is_action_pressed("move_forward"):
		input_dir += forward
	if Input.is_action_pressed("move_backward"):
		input_dir -= forward
	if Input.is_action_pressed("move_left"):
		input_dir -= right
	if Input.is_action_pressed("move_right"):
		input_dir += right

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	move_and_slide()
