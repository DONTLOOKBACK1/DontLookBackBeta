extends Control

# --- MODIFICADO ---
# 1. Define las rutas a TODOS tus botones.
# ¡¡IMPORTANTE!! Tienes que ajustar estas rutas para que coincidan
# con los nombres de tus 3 HBoxContainers.
# Yo usaré 'HBoxContainer1', 'HBoxContainer2', 'HBoxContainer3' como ejemplos.

# Ejemplo: Asumiendo que los niveles 1-3 están en 'HBoxContainer'
@onready var level_1_button = $VBoxContainer/VBoxContainer/HBoxContainer/Level1Button
@onready var level_2_button = $VBoxContainer/VBoxContainer/HBoxContainer/Level2Button
@onready var level_3_button = $VBoxContainer/VBoxContainer/HBoxContainer/Level3Button
# Ejemplo: Asumiendo que los niveles 4-6 están en 'HBoxContainer2'
@onready var level_4_button = $VBoxContainer/VBoxContainer/HBoxContainer2/Level4Button
@onready var level_5_button = $VBoxContainer/VBoxContainer/HBoxContainer2/Level5Button
@onready var level_6_button = $VBoxContainer/VBoxContainer/HBoxContainer2/Level6Button
# Ejemplo: Asumiendo que los niveles 7-8 están en 'HBoxContainer3'
@onready var level_7_button = $VBoxContainer/VBoxContainer/HBoxContainer3/Level7Button
@onready var level_8_button = $VBoxContainer/VBoxContainer/HBoxContainer3/Level8Button

@onready var back_button = $BackButton

# --- NUEVO ---
# Un array para guardar todos los botones de nivel, sin importar dónde estén
var level_buttons = []

func _ready():
	MusicManager.play_music() 

	# --- MODIFICADO ---
	# 2. Llenamos el array con todos los botones que acabamos de definir
	level_buttons = [
		level_1_button, level_2_button, level_3_button, level_4_button,
		level_5_button, level_6_button, level_7_button, level_8_button
	]

	# 3. Ahora usamos un bucle sobre ese array
	# 'i' será el índice del array (0, 1, 2, 3...)
	for i in level_buttons.size():
		var button = level_buttons[i]
		var level_number = i + 1 # El índice 0 es nivel 1, índice 1 es nivel 2, etc.
		
		if button:
			# Conectamos la señal 'pressed' y le pasamos el número de nivel
			button.pressed.connect(_on_level_pressed.bind(level_number))
		else:
			print("Error: El botón para el nivel " + str(level_number) + " no se encontró o es nulo.")

	back_button.pressed.connect(_on_back_pressed)
	actualizar_botones()

func actualizar_botones():
	var max_nivel_desbloqueado = SaveManager.unlocked_level

	# --- MODIFICADO ---
	# Usamos el mismo bucle sobre el array para habilitar/deshabilitar
	# 'i' será el índice (0, 1, 2, 3...)
	for i in level_buttons.size():
		var button = level_buttons[i]
		var level_number = i + 1 # El índice 0 es nivel 1

		if button:
			# El nivel 1 siempre está habilitado
			if level_number == 1:
				button.disabled = false
			else:
				# Para los niveles 2 al 8, comprobamos el progreso
				button.disabled = (max_nivel_desbloqueado < level_number)

# --- SIN CAMBIOS ---
# Esta lógica sigue funcionando perfectamente
func _on_level_pressed(numero_de_nivel):
	MusicManager.stop_music()
	get_tree().change_scene_to_file("res://src/niveles/nivel_" + str(numero_de_nivel) + ".tscn")
	SaveManager.is_in_game_level = true

# --- SIN CAMBIOS ---
func _on_back_pressed():
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
