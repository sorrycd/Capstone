class_name Player extends CharacterBody3D

@export_category("Player Settings")
@export var Move_Speed: float = 1.5
@export var Sprint_Speed: float = 10.0
@export var Jump_Velocity: float = 4.5
@export var Wall_Jump_Velocity: Vector3 = Vector3(0, 6.5, 0)
@export var PlayerInventory: Array[Dictionary] = []
@export var step_interval := 0.4 #for audio distance between steps
@export var walk_step_interval := 0.45 #for audio distance between steps
@export var sprint_step_interval := 0.25  # Faster rhythm when sprinting

@export_category("Inputs")
@export var InputDictionary: Dictionary = {
	"Forward": "ui_up",
	"Backward": "ui_down",
	"Left": "ui_left",
	"Right": "ui_right",
	"Jump": "ui_accept",
	"Escape": "ui_cancel",
	"Sprint": "ui_accept",
	"Interact": "ui_accept",
	"CloseUI": "ui_close"
}

@export_category("Mouse Settings")
@export_range(0.09, 0.1) var Mouse_Sens: float = 0.09
@export_range(1.0, 50.0) var Mouse_Smooth: float = 50.0

@export_category("Camera Settings")
@export_subgroup("Tilt Settings")
@export_range(0.0, 1.0) var TiltThreshhold: float = 0.2

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var ltilt: Marker3D = $Tilt/LTilt
@onready var rtilt: Marker3D = $Tilt/RTilt
@onready var flashlight: SpotLight3D = $Head/SpotLight3D
@onready var walk_sound := $walk

var direction: Vector3 = Vector3.ZERO
var Camera_Inp: Vector2 = Vector2()
var Rot_Vel: Vector2 = Vector2()
var _speed: float = Move_Speed
var _isMouseCaptured: bool = true
var can_wall_jump: bool = false
var flashlight_on := false
var book_ui_open := false
var is_walking := false
var step_timer := 0.0
var sprinting = Input.is_action_pressed("Sprint")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ltilt.rotation.z = TiltThreshhold
	rtilt.rotation.z = -TiltThreshhold
	flashlight.light_energy = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Camera_Inp = event.relative

	if event.is_action_pressed("toggle_flashlight"):
		flashlight_on = !flashlight_on
		flashlight.light_energy = 1.0 if flashlight_on else 0

	if event.is_action_pressed("Interact"):
		var book_ui = get_tree().get_root().find_child("BookImagePanel", true, false)
		if book_ui and book_ui.visible:
			book_ui.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			book_ui_open = false

func _process(delta: float) -> void:
	_handle_mouse_capture()
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	_handle_camera_movement(delta)
	move_and_slide()
	
	var moving := (
		Input.is_action_pressed(InputDictionary["Forward"]) or
		Input.is_action_pressed(InputDictionary["Backward"]) or
		Input.is_action_pressed(InputDictionary["Left"]) or
		Input.is_action_pressed(InputDictionary["Right"])
	)

	var sprinting := Input.is_action_pressed(InputDictionary["Sprint"])

	step_timer -= delta

	if moving and is_on_floor():
		var interval := walk_step_interval
		if sprinting:
			interval = sprint_step_interval

		if step_timer <= 0.0:
			if sprinting:
				walk_sound.pitch_scale = randf_range(1.1, 1.2)
			else:
				walk_sound.pitch_scale = randf_range(0.9, 1.1)
				
			walk_sound.play()
			step_timer = interval


func _handle_mouse_capture() -> void:
	if Input.is_action_just_pressed(InputDictionary["Escape"]):
		_isMouseCaptured = !_isMouseCaptured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _isMouseCaptured else Input.MOUSE_MODE_VISIBLE

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed(InputDictionary["Jump"]):
		if is_on_floor():
			velocity.y = Jump_Velocity
		elif is_on_wall():
			_perform_wall_jump()

func _perform_wall_jump() -> void:
	velocity.y = Wall_Jump_Velocity.y
	can_wall_jump = false

func _handle_movement(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(
		InputDictionary["Left"], InputDictionary["Right"],
		InputDictionary["Forward"], InputDictionary["Backward"]
	)
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 7.0)
	_speed = lerp(_speed, Sprint_Speed if Input.is_action_pressed(InputDictionary["Sprint"]) else Move_Speed, 0.1)

	velocity.x = direction.x * _speed if direction else move_toward(velocity.x, 0, _speed)
	velocity.z = direction.z * _speed if direction else move_toward(velocity.z, 0, _speed)

func _handle_camera_movement(delta: float) -> void:
	Rot_Vel = Rot_Vel.lerp(Camera_Inp * Mouse_Sens, delta * Mouse_Smooth)
	head.rotate_x(-deg_to_rad(Rot_Vel.y))
	rotate_y(-deg_to_rad(Rot_Vel.x))
	head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
	Camera_Inp = Vector2.ZERO
	_camera_tilt(delta)

func _camera_tilt(delta: float) -> void:
	var tilt_target = (
		ltilt.rotation.z if Input.is_action_pressed(InputDictionary["Left"]) else
		rtilt.rotation.z if Input.is_action_pressed(InputDictionary["Right"]) else 0
	)
	camera.rotation.z = lerp_angle(camera.rotation.z, tilt_target, min(delta * 5.0, 1.0))
