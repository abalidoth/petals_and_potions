extends Node2D

func _input(event):
	if event is InputEventMouseButton or event is InputEventKey:
		get_tree().change_scene_to_file("res://main_menu.tscn")
