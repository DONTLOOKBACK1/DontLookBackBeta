extends Node

@onready var music_player = $MusicPlayer
var menu_music: AudioStream

# --- ¡AÑADIDO! ---
# Esta variable guardará la música del nivel actual
var current_level_music: AudioStream = null

func _ready():
	if music_player.stream:
		menu_music = music_player.stream
	music_player.autoplay = false

# (Función del menú - Sin cambios)
func play_music():
	if music_player.stream != menu_music:
		music_player.stream = menu_music
		if music_player.stream:
			music_player.stream.loop = true
	
	if not music_player.playing and music_player.stream:
		music_player.play()

# (Función de parar - Sin cambios)
func stop_music():
	music_player.stop()
	music_player.stream = null 

# (Función de niveles - MODIFICADA)
func play_new_song(song: AudioStream):
	# --- ¡AÑADIDO! ---
	# 1. Antes de poner la canción, la guardamos
	current_level_music = song 

	# 2. Asigna la nueva canción
	music_player.stream = song
	if music_player.stream:
		music_player.stream.loop = true
	music_player.play()

# --- ¡NUEVA FUNCIÓN AÑADIDA! ---
# El "STOP_CHASE" llamará a esto.
func resume_level_music():
	# Si tenemos guardada una música de nivel...
	if current_level_music:
		# ...la reproducimos
		play_new_song(current_level_music)
	else:
		# ...si no (por si acaso), ponemos la del menú.
		play_music()
