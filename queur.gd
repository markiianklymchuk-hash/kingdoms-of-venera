extends Node2D

var mode
var target
var wasmode 
var wastarget
var currently_attacking = false
var selected= false
var hp 
var maxhp
var size
var what
var rally

func _process(_delta: float) -> void:
	queue_redraw()


func _draw():
	hp = get_parent().hp
	maxhp = get_parent().main.unit[get_parent().type]["health"]
	size = get_parent().main.unit[get_parent().type]["size"]
	target = get_parent().target
	wastarget = get_parent().wastarget
	currently_attacking = get_parent().currently_attacking
	mode = get_parent().mode
	wasmode = get_parent().wasmode
	selected = get_parent().selected
	rally = get_parent().rally
	what = get_parent().what
	if selected and rally != null:
		if rally is Vector2:
			draw_circle(rally - get_parent().position, 4, Color("003800ff"), false, 2)
		else:
			if is_instance_valid(rally):
				draw_circle(rally.global_position - get_parent().position, 4, Color("003800ff"), false, 2)
	if mode == "move" and selected:
		if wastarget is Vector2:
			draw_circle(wastarget - get_parent().position, 4, Color("003800ff"), false, 2)
		else:
			if is_instance_valid(wastarget):
				draw_circle(wastarget.global_position - get_parent().position, 4, Color("003800ff"), false, 2)
	if mode == "gather" and is_instance_valid(wastarget):
		if selected:
			draw_circle(wastarget.global_position - get_parent().position, 4, Color("642c04ff"), false, 2)
		if get_parent().progress > 0:
			draw_line(Vector2.ZERO, wastarget.global_position - get_parent().position, Color("642c04ff"), 2.0)
	if mode == "building" and selected:
		draw_circle(wastarget - get_parent().position, get_parent().main.unit[what]["size"], Color("8a7b6bff"), false, 4)
	if mode == "build" and is_instance_valid(wastarget):
		if selected:
			draw_circle(wastarget.global_position - get_parent().position, 4, Color("14483bff"), false, 2)
		if get_parent().progress > 0:
			draw_line(Vector2.ZERO, wastarget.global_position - get_parent().position, Color("14483bff"), 2.0)
	if mode == "attack" and selected:
		if wasmode == "attack":
			if wastarget is Vector2:
				draw_circle(wastarget - get_parent().position, 4, Color("a6002bff"), false, 2)
		if target is not Vector2:
			draw_circle(target.global_position - get_parent().position, 4, Color("a6002b99"), false, 2)
	draw_line(Vector2(size/-2, size/-1), Vector2(size/2, size/-1), Color("ff0000dd"), 2.0)
	draw_line(Vector2(size/-2, size/-1), Vector2(size/2 - size * (maxhp - hp)/maxhp, size/-1), Color("00ff00ff"), 2.0)
	if currently_attacking and target != null and target is not Vector2:
		draw_line(Vector2.ZERO, target.global_position - global_position, Color("dc003c99"), 2.0)
