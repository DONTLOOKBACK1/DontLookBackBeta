extends Control

@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var back_button: Button = $BackButton

func _ready():
	print("--- OptionsMenu: _ready() ---")
	
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	var music_val = AudioManager.get_music_volume()
	var sfx_val = AudioManager.get_sfx_volume()
	
	print("OptionsMenu: Obteniendo valor Music de AudioManager: ", music_val)
	print("OptionsMenu: Obteniendo valor SFX de AudioManager: ", sfx_val)
	
	music_slider.value = music_val
	sfx_slider.value = sfx_val
	
	print("OptionsMenu: Sliders actualizados.")


# --- Funciones de Señal ---

func _on_music_slider_value_changed(value: float):
	print("--- OptionsMenu: Slider de MÚSICA movido a: ", value)
	AudioManager.set_music_volume(value)

func _on_sfx_slider_value_changed(value: float):
	print("--- OptionsMenu: Slider de SFX movido a: ", value)
	AudioManager.set_sfx_volume(value)

func _on_back_button_pressed():
	print("--- OptionsMenu: Volviendo al menú principal ---")
	get_tree().change_scene_to_file("res://src/hud/main_menu.tscn")
