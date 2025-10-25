extends Node

# Apunta al nodo AudioStreamPlayer que creaste
@onready var music_player = $MusicPlayer

# Función para poner música
func play_music():
	if not music_player.playing:
		music_player.play()

# Función para parar música
func stop_music():
	music_player.stop()
