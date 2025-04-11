extends Node3D

@export var spin_speed_degrees := 20.0

func _process(delta):
	rotate_y(deg_to_rad(spin_speed_degrees * delta))
