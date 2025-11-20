extends Node2D

# --- AÑADIDO (Música) ---
# Carga el archivo de música para ESTE nivel
@export var level_music: AudioStream = preload("res://assets/music/Shadows Beneath.mp3") # <-- ¡Cambia esta ruta!

@export var level_id: int = 2
@onready var game_over_screen = $CanvasLayer/GameOverScreen

func _ready():
	# --- AÑADIDO (Pausa) ---
	# Asegura que el juego NO esté pausado al iniciar el nivel.
	get_tree().paused = false 

	game_over_screen.hide()
	
	# --- AÑADIDO (Música) ---
	# ¡Llama a la nueva función con la música del nivel!
	MusicManager.play_new_song(level_music)
	
	# Asegúrate de que la señal 'player_died' de tu jugador
	# esté conectada a la función de abajo.
	# $CharacterBody2D.player_died.connect(_on_character_body_2d_player_died)


func _on_character_body_2d_player_died():
	# --- AÑADIDO (Música) ---
	# 1. Para la música del nivel
	MusicManager.stop_music() 
	
	# 2. (Opcional) Si tienes música de "Game Over", la pones aquí:
	# MusicManager.play_new_song(preload("res://assets/sonidos/musica_gameover.ogg"))

	# --- (Tu código anterior) ---
	# 3. Le pasamos el ID
	game_over_screen.current_level_id = self.level_id
	
	# 4. Mostramos la pantalla
	game_over_screen.show()
	
	# 5. Pausamos el juego.
	get_tree().paused = true
