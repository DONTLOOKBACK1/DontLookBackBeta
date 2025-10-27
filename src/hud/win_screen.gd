extends CanvasLayer

var completed_level_id = 1
const MAX_LEVEL = 3

@onready var next_level_button = $CenterContainer/VBoxContainer/NextLevelButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton

func _ready():
	next_level_button.pressed.connect(_on_next_level_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	if completed_level_id >= MAX_LEVEL:
		next_level_button.visible = false
		$CenterContainer/VBoxContainer/Label.text = "¡DEMO COMPLETADA!"

func _on_next_level_pressed():
	var next_level_num = completed_level_id + 1
	
	get_tree().paused = false
	queue_free()
	
	# Esta ruta a los niveles (src/niveles) ya estaba bien
	get_tree().change_scene_to_file("res://src/niveles/nivel_" + str(next_level_num) + ".tscn")
	SaveManager.is_in_game_level = true

func _on_menu_pressed():
	get_tree().paused = false
	queue_free()
	
	get_tree().change_scene_to_file("res://src/hud/level_select.tscn") # <-- RUTA CORREGIDA
	SaveManager.is_in_game_level = false
