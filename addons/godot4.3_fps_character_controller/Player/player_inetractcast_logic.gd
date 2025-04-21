extends RayCast3D

@export var Prompt : RichTextLabel
var curr_dialogue : String

func _physics_process(delta: float) -> void:

	if is_colliding():
		var collider = get_collider()
		
		if collider is Interactable or collider is Interactable2 or collider is Interactable3 or collider is Interactable4 or collider is Interactable5:
			if collider.prompt_action == "Interact":
				# Prompt Logic
				if Prompt.text == collider.get_prompt()+ " ["+collider.get_key()+"]":
					pass
				else:
					Prompt.text = collider.get_prompt()+ " ["+collider.get_key()+"]"
				# Key Pressed Logic
				if collider._hasDialogue:
					curr_dialogue = collider.dialouge
					if Input.is_action_just_pressed(collider.prompt_action):
						collider.run_dialogue()

				elif Input.is_action_just_pressed(collider.prompt_action):
					collider.Interact(owner)
				


			else:
				Prompt.text = collider.get_prompt()
	else:
		Prompt.text = ""
		
