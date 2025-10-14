extends Control


func _on_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/niveles/nivel_1.tscn")
