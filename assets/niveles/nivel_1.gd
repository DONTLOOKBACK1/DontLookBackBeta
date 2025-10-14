extends Node2D


func _on_character_body_2d_player_died():
 $CanvasLayer/GameOverScreen.show()
 get_tree().paused = true
