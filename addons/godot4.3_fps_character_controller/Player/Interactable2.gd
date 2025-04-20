class_name Interactable2 extends Node

signal interacted(body)

@export_subgroup("Dialogue")
@export_file("*.json") var dialouge : String

@export_category("Prompt Settings")
@export_enum("Interact", "text") var prompt_action : String = "Interact"
@export_multiline var prompt_message : String = "Interact"
@export var prompt_key_override : bool = false
@export_multiline var override_text : String = ""

@export var _hasDialogue : bool = false

var _dialogue_parsed : Dictionary
var _dialogue_index : int = 1
var book_opened := false
var input_blocked := false

# Mesh refs
var book_closed_mesh: Node = null
var book_open_mesh: Node = null

func _ready() -> void:
	var book_root = get_parent().get_parent()
	book_closed_mesh = book_root.get_node_or_null("book_closed")
	book_open_mesh = book_root.get_node_or_null("book_open")

func get_key() -> String:
	if prompt_key_override:
		return override_text
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			return action.as_text_physical_keycode()
	return ""

func get_prompt() -> String:
	return prompt_message

func Interact(body) -> void:
	var book_ui = get_tree().get_root().find_child("BookImagePanel2", true, false)
	if not book_ui:
		printerr("Book UI not found.")
		return

	if not book_opened:
		print("📖 Opening the book...")
		if book_closed_mesh: book_closed_mesh.visible = false
		if book_open_mesh: book_open_mesh.visible = true
		book_opened = true
		book_ui.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		print("📕 Closing the book...")
		if book_closed_mesh: book_closed_mesh.visible = true
		if book_open_mesh: book_open_mesh.visible = false
		book_opened = false
		book_ui.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.book_ui_open = book_opened
