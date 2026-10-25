extends Control



func _on_tutorial_pressed() -> void:
	var game = load("res://tutorial.tscn")
	game = game.instantiate()
	get_parent().add_child(game)
	queue_free()
