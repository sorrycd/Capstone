extends Control

@onready var start_button := $StartButton  # Make sure StartButton is inside Control

func _ready() -> void:
	# Ensure the button is visible at startup
	start_button.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Show cursor

func _on_StartButton_pressed() -> void:
	# Lock the cursor when clicked
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	start_button.visible = false  # Hide button
