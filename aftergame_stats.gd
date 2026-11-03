extends Control

var player = 0
var allplayers = 0
var victory = true
var playernames = []
var stats = {}

func end():
	if victory:
		get_node("victorycon").text = "victory"
	else:
		get_node("victorycon").text = "defeat"
	get_node("faction").text = playernames[player]
	for i in stats[str(player)].keys():
		get_node(str(i)).text = str(i) + ": " + str(stats[str(player)][i])

func _on_main_menu_pressed() -> void:
	var main_menu = load("res://main_menu.tscn")
	main_menu = main_menu.instantiate()
	get_parent().get_parent().get_parent().add_child(main_menu)
	get_parent().get_parent().queue_free()
	get_tree().paused = false


func _on_next_pressed() -> void:
	player += 1
	if player > allplayers:
		player = 0
	end()
