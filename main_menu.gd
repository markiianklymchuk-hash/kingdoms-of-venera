extends Node2D

var allies = {
	"0" = ["0"],
}
var birdpathes = [Vector2(200, 500), Vector2(50, 75), Vector2(600, 120), Vector2(820, 140), Vector2(950, 400), Vector2(800, 600)]
var period = 0
var cameralimits = [576, 576, 324, 324]
@onready var playerUI = $"C/0"
var type = "0"

func _on_tutorial_pressed() -> void:
	var game = load("res://briefing.tscn")
	game = game.instantiate()
	get_parent().add_child(game)
	queue_free()

func _process(delta: float) -> void:
	period -= delta
	if period <= 0:
		period = 5
		for i in get_tree().get_nodes_in_group("bird"):
			i.mode = "move"
			i.target = birdpathes.pick_random()


func _on_back_pressed() -> void:
	$Control/tutorial.visible = false
	$Control/main.visible = true


func _on_play_pressed() -> void:
	$Control/main.visible = false
	$Control/tutorial.visible = true
