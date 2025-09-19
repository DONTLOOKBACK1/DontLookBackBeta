extends Area2D

signal entered_from_left

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("entered_from_left")
