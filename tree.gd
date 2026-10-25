extends Node2D

@export var lumber = 0.0
@export var alllumber = 0.0
var gatherers = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lumber == 0:
		lumber = alllumber
	add_to_group("tree")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if lumber <= 0:
		queue_free()
	else:
		queue_redraw()
		check_for_gatherers()

func check_for_gatherers():
		gatherers = 0
		for i in get_tree().get_nodes_in_group("unit"):
			if i.mode == "gather" and i.target == self:
				gatherers+= 1
			

func _draw():
	draw_line(Vector2(-15, -25), Vector2(15, -25), Color("432415ff"), 2)
	draw_line(Vector2(-15, -25), Vector2(-15 + 30 * lumber / alllumber, -25), Color("28df00ff"), 2)
