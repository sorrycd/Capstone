extends Node3D

var is_mouse_captured: bool = false

func _ready() -> void:
	# Ensure the cursor is initially visible so the player can interact
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	# If the user clicks anywhere inside the game
	if event is InputEventMouseButton and event.pressed:
		if not is_mouse_captured:
			
			# Ensure input is registered before locking
			get_viewport().set_input_as_handled()  
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			is_mouse_captured = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
