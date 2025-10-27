extends Control

# Referencias a nuestros nodos de UI
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var back_button: Button = $BackButton


func _ready():
	# 1. Conectar las señales de los sliders y el botón
	#    (También puedes hacerlo desde el editor en la pestaña "Nodo")
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# 2. Asignar el valor de volumen ACTUAL a los sliders
	#    para que muestren el volumen correcto cuando se abre el menú.
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()


# --- Funciones de Señal ---

# Esta función se llama CADA VEZ que el usuario mueve el slider de música
func _on_music_slider_value_changed(value: float):
	# Llama a nuestro Autoload global
	AudioManager.set_music_volume(value)

# Esta función se llama CADA VEZ que el usuario mueve el slider de SFX
func _on_sfx_slider_value_changed(value: float):
	# Llama a nuestro Autoload global
	AudioManager.set_sfx_volume(value)

# Esta función se llama cuando se presiona el botón "Atrás"
func _on_back_button_pressed():
	# Regresa al menú principal (aquí NO paramos la música)
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
