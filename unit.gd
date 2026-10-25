extends CharacterBody2D
var unit = {
	"warrior" = {
		"size" = 16,
		"aggro" = 300,
		"supply" = -2,
		"health" = 110,
		"speed" = 2200,
		"damage" = 10,
		"armor" = 4,
		"range" = 15,
		"cooldown" = 1.0,
		"commands" = ["move", "attack", "stop", "defend"],
	},
	"worker" = {
		"size" = 10,
		"aggro" = 300,
		"supply" = -1,
		"health" = 60,
		"speed" = 2600,
		"damage" = 5,
		"armor" = 0,
		"range" = 15,
		"cooldown" = 2.0,
		"gather" = 5,
		"how much" = 10,
		"search" = 300,
		"barracks lumber" = 150,
		"barracks time" = 45,
		"command centre lumber" = 450,
		"command centre time" = 60,
		"farm lumber" = 100,
		"farm time" = 20,
		"commands" = ["move", "attack", "stop", "defend", "gather", "return", "build", "continue building"],
		"build commands" = ["build barracks", "build command centre", "build farm", "back"],
	},
	"archer" = {
		"size" = 12,
		"aggro" = 400,
		"supply" = -2,
		"health" = 80,
		"speed" = 2600,
		"damage" = 20,
		"armor" = 0,
		"range" = 200,
		"cooldown" = 3.0,
		"commands" = ["move", "attack", "stop", "defend"],
	},
	"cavalry" = {
		"size" = 20,
		"aggro" = 400,
		"supply" = -3,
		"health" = 120,
		"speed" = 5200,
		"damage" = 5,
		"armor" = 2,
		"range" = 10,
		"cooldown" = 0.3,
		"commands" = ["move", "attack", "stop", "defend"],
	}, 
	"civilian" = {
		"size" = 8,
		"aggro" = 0,
		"supply" = -1,
		"health" = 40,
		"speed" = 2400,
		"damage" = 0,
		"armor" = 0,
		"range" = 200,
		"cooldown" = -1,
		"commands" = ["move", "stop", "defend"],
	},
	"barracks" = {
		"size" = 68,
		"aggro" = 0,
		"supply" = 0,
		"health" = 1400,
		"speed" = 0,
		"damage" = 0,
		"armor" = 5,
		"range" = 400,
		"cooldown" = -1,
		"barracks time" = 45,
		"warrior lumber" = 60,
		"warrior time" = 8,
		"archer lumber" = 60,
		"archer time" = 14,
		"cavalry lumber" = 85,
		"cavalry time" = 22,
		"commands" = ["create warrior", "create cavalry", "create archer", "cancel", "create", "rally"],
		"cancel commands" = ["cancel"],
	}, 
	"command centre" = {
		"size" = 80,
		"aggro" = 0,
		"supply" = 10,
		"health" = 2000,
		"speed" = 0,
		"damage" = 0,
		"armor" = 5,
		"range" = 400,
		"cooldown" = -1,
		"command centre time" = 60,
		"worker lumber" = 25,
		"worker time" = 10,
		"commands" = ["create worker", "cancel", "dropoff point",  "create", "rally"],
		"cancel commands" = ["cancel"],
	}, 
	"farm" = {
		"size" = 36,
		"aggro" = 0,
		"supply" = 8,
		"health" = 800,
		"speed" = 0,
		"damage" = 0,
		"armor" = 3,
		"range" = 400,
		"cooldown" = -1,
		"farm time" = 20,
		"commands" = [],
		"cancel commands" = ["cancel"],
	}, 
}
var colors = {
	"0" = Color("000000"),
	"1" = Color("ff0000"),
	"2" = Color("0000ff"),
	"3" = Color("00ff00")
}
@export var type = ""
@export var side = 0

var main 
var pos = Vector2(0,0)
var draww = {}
var building = false
var dir
var target = null
var mode = "idle"
var cd = 0
var selected = false
var currently_attacking = false
var hp = 0
var wastarget
var is_atacking_from_order = false
var wasmode
var is_main = false
var queue = []
var progress = 0
var carrying = []
var alive = true
var what = null
var BLOCK_MASK = 0b110
var rally = null
var scenario 

func _ready() -> void:
	main = get_parent().get_node("C/" + str(side))
	scenario= get_parent()
	if unit[type]["speed"] == 0:
		building= true
		set_collision_layer_value(2, true)
	else:
		building= false
		set_collision_layer_value(1, true)
	hp = unit[type]["health"]
	add_to_group("unit")
	add_to_group(str(side))
	$colider.shape = $colider.shape.duplicate()
	$colider.shape.radius = unit[type]["size"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	if alive:
		cd -= delta
		if is_main:
			if queue.size() == 0:
				main.get_node("UI_buttons/cancel").disabled = true
			else:
				main.get_node("UI_buttons/cancel").disabled = false
			if carrying.size() == 0:
				main.get_node("UI_buttons/return").disabled = true
				main.get_node("UI_buttons/gather").disabled = false
			else:
				main.get_node("UI_buttons/return").disabled = false
				main.get_node("UI_buttons/gather").disabled = true
		handle_shit(delta)
	else:
		if mode == "cancel":
			queue.clear()
	if hp <= 0:
		die()
	if !building:
		move_and_slide()
	if carrying.size() >= 1:
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
	else:
		set_collision_mask_value(1, true)
		set_collision_layer_value(1, true)
			

func die():
		queue_free()
		if selected:
			main.selectedall.erase(self)
		if is_main:
			main.refresh()
		for i in get_groups():
			remove_from_group(i)
		if queue.size() >= 1:
			for i in queue:
				queue.erase(i)
				main.lumber += unit[type][i + " lumber"]
			


func learn():
	main.pos = pos
	main.learn()
	draww = main.draww

func _draw() -> void:
	draw_circle(Vector2.ZERO, unit[type]["size"], colors[str(side)], true)
	learn()
	draw_colored_polygon(draww[type][0], draww[type][1])
	if selected:
		if str(side) == scenario.type and !is_main:
			draw_circle(Vector2.ZERO, unit[type]["size"] * 5 / 4, Color("00ff00"), false, unit[type]["size"] / 8)
		elif str(side) == scenario.type and is_main:
			draw_circle(Vector2.ZERO, unit[type]["size"] * 5 / 4, Color("003b00ff"), false, unit[type]["size"] / 8)
		elif scenario.allies[scenario.type].has(str(side)):
			draw_circle(Vector2.ZERO, unit[type]["size"] * 5 / 4, Color("aea400ff"), false, unit[type]["size"] / 8)
		else:
			draw_circle(Vector2.ZERO, unit[type]["size"] * 5 / 4, Color("ff0000"), false, unit[type]["size"] / 8)

func attack(who, how):
	if who == null:
		search(how)
		return
	else:
		if cd <= -1:
			cd =  unit[type]["cooldown"]
			currently_attacking = false
		elif cd <= 0:
			cd = unit[type]["cooldown"]
			currently_attacking = true
			damage()
		elif cd <= unit[type]["cooldown"]/2:
			currently_attacking = false

func search(how):
	var all = get_tree().get_nodes_in_group("unit")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		var is_friendly = false
		for u in he.get_groups():
			if scenario.allies[str(side)].has(u):
				is_friendly = true
		if global_position.distance_to(he.global_position) <= how:
			if !is_friendly:
				if best == null:
					best = he
				else:
					if global_position.distance_to(best.global_position) > global_position.distance_to(he.global_position):
						best = he
	if best != null:
		wasmode = mode
		target = best
		mode = "attack"
		is_atacking_from_order = false

func search_for_dropoff():
	var all = get_tree().get_nodes_in_group("unit")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		if he.is_in_group(str(side)) and he.unit[he.type]["commands"].has("dropoff point"):
			if best == null:
				best = he
			else:
				if global_position.distance_to(best.global_position) > global_position.distance_to(he.global_position):
					best = he
	if best != null:
		target = best
		mode = "return"
	else:
		mode = "idle"


func search_for_resourse():
	var all = get_tree().get_nodes_in_group("tree")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		if best == null:
			if he.global_position.distance_to(global_position) <= unit[type]["search"] and he.gatherers < 2:
				best = he
		else:
			if (global_position.distance_to(best.global_position) > global_position.distance_to(he.global_position) and he.global_position.distance_to(global_position) <= unit[type]["search"] and he.gatherers <2 and wastarget != he) or wastarget == he:
				best = he
	if best != null:
		target = best
		mode = "gather"
	else:
		mode = "idle"
	
func damage():
	var full_damage = max(unit[type]["damage"] - unit[target.type]["armor"], 0)
	target.hp -= full_damage
	if target.hp <= 0:
		target = null
		mode = "idle"
		currently_attacking = false

func handle_shit(delta):
	if mode == "move":
		progress = 0
		if !unit[type]["commands"].has(mode):
			mode = "idle"
			return
		wasmode = mode
		currently_attacking = false
		if target == null:
			mode = "idle"
			return
		if target is Vector2:
			wastarget = target
			dir = global_position.direction_to(wastarget)
			if global_position.distance_to(wastarget) <= 16:
				mode = "idle"
		else:
			if target == self:
				mode = "idle"
			wastarget= target
			dir = global_position.direction_to(wastarget.global_position)
			if global_position.distance_to(wastarget.global_position) <= 1.5 * (unit[type]["size"] + unit[wastarget.type]["size"]):
				dir = Vector2.ZERO
		velocity = dir * unit[type]["speed"] * delta
	if mode == "gather":
		wasmode = mode
		currently_attacking = false
		wastarget= target
		if target == null or !is_instance_valid(target) or (wastarget is Node2D and wastarget.gatherers > 2):
			mode = "idle"
			target = null
			progress= 0
			if is_instance_valid(wastarget):
				wastarget.check_for_gatherers()
			wastarget = null
			search_for_resourse()
			return
		dir = global_position.direction_to(wastarget.global_position)
		if global_position.distance_to(wastarget.global_position) <= 45 + unit[type]["size"]:
			dir = Vector2.ZERO
			progress += delta
			if carrying.size() >= 1:
				search_for_dropoff()
				return
			if progress >= unit[type]["gather"]:
				progress = 0
				target.lumber -= unit[type]["how much"]
				carrying.append("lumber")
				search_for_dropoff()
				return
		else:
			progress = 0
		velocity = dir * unit[type]["speed"] * delta
	if mode == "building":
		wasmode = mode
		currently_attacking = false
		wastarget= target
		if wastarget == null:
			return
		dir = global_position.direction_to(wastarget)
		if global_position.distance_to(wastarget) <= unit[what]["size"] + unit[type]["size"]:
			if main.lumber >= unit[type][what + " lumber"]:
				dir = Vector2.ZERO
				build(what)
				main.lumber -= unit[type][what + " lumber"]
				what = null
			elif main.lumber < unit[type][what + " lumber"]:
				main.error("not enough lumber", 1)
				mode = "idle"
		velocity = dir * unit[type]["speed"] * delta
	if mode == "build":
		wasmode = mode
		currently_attacking = false
		if target == null or !is_instance_valid(target):
			mode = "idle"
			target = null
			return
		wastarget= target
		progress = 0
		dir = global_position.direction_to(wastarget.global_position)
		if global_position.distance_to(wastarget.global_position) <= unit[target.type]["size"] + unit[type]["size"] + 4:
			dir = Vector2.ZERO
			progress = 1
			target.progress += delta
			target.hp += unit[target.type]["health"] / unit[type][target.type + " time"] * delta
			if target.queue.is_empty() and !target.alive:
				target.hp = -10000
			if target.progress >= unit[type][target.type + " time"] or target.alive:
				target.progress = 0
				target.alive = true
				mode = "idle"
				target.queue.clear()
				main.command()
				if target.hp > unit[target.type]["health"]:
					target.hp = unit[target.type]["health"]
				return
		velocity = dir * unit[type]["speed"] * delta
	if mode == "return":
		wasmode = mode
		currently_attacking = false
		if target == null:
			mode = "idle"
			return
		dir = global_position.direction_to(target.global_position)
		if global_position.distance_to(target.global_position) <= 1.25 * (unit[type]["size"] + unit[target.type]["size"]):
			dir = Vector2.ZERO
			if carrying.has("lumber"):
				carrying.erase("lumber")
				main.lumber += unit[type]["how much"]
				search_for_resourse()
		velocity = dir * unit[type]["speed"] * delta
	if mode == "idle":
		progress = 0
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		attack(null, unit[type]["aggro"])
	if mode == "creating":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		if queue.size() < 5 and main.lumber >= unit[type][what +" lumber"]:
			queue.append(what)
			main.lumber -= unit[type][what + " lumber"]
			what = null
		elif main.lumber < unit[type][what + " lumber"]:
			main.error("not enough lumber", 1)
		if queue.size() != 0:
			mode = "buy"
		else:
			progress= 0
			mode = "idle"
	if mode == "rally":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		rally = target
		if queue.size() != 0:
			mode = "buy"
		else:
			progress= 0
			mode = "idle"
	if mode == "cancel":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		if queue.size() > 0:
			main.lumber += unit[type][queue[queue.size() - 1] + " lumber"]
			queue.remove_at(queue.size() - 1)
		if queue.size() != 0:
			mode = "buy"
		else:
			progress= 0
			mode = "idle"
	if mode == "buy":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		if main.currentsupply - unit[queue[0]]["supply"] <= main.supply:
			progress += delta
		var first = queue[0]
		if progress >= unit[type][first + " time"]:
			create_unit(first)
		if queue.size() == 0:
			mode = "idle"
	if mode == "defence":
		progress = 0
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		attack(null, unit[type]["range"])
	if mode == "attack":
		progress = 0
		if target == null:
			mode = "idle"
			return
		if target is Vector2:
			wasmode = mode
			wastarget = target
			dir = global_position.direction_to(wastarget)
			attack(null, unit[type]["aggro"])
			if global_position.distance_to(wastarget) <= 16:
				mode = "idle"
		else:
			if target.hp <= 0:
				mode = "idle"
				return
			if !is_atacking_from_order:
				if target.global_position.distance_to(global_position) > unit[type]["aggro"]:
					mode = "idle"
					return
				else:
					attack(null, unit[type]["aggro"])
			dir = global_position.direction_to(target.global_position)
			if global_position.distance_to(target.global_position) <= unit[type]["range"] + (unit[type]["size"] + unit[target.type]["size"]):
				dir = Vector2.ZERO
				attack(target, null)
			else:
				currently_attacking = false
		velocity = dir * unit[type]["speed"] * delta

func create_unit(unitt):
	var who = load("res://unit.tscn").instantiate()
	who.type = unitt
	who.side = side
	who.global_position = Vector2(global_position.x, global_position.y +unit[type]["size"] * 1.25)
	get_parent().add_child(who)
	progress = 0
	queue.remove_at(0)
	if rally != null:
		who.target = rally
		if rally is Vector2:
			who.mode = "move"
		else:
			if rally.is_in_group("unit"):
				var is_friendly = false
				for u in rally.get_groups():
					if scenario.allies[str(side)].has(u):
						is_friendly = true
				if is_friendly:
					who.mode = "move"
				else:
					who.mode = "attack"
					who.is_atacking_from_order = true
			if rally.is_in_group("tree"):
				if unit[who.type]["commands"].has("gather"):
					who.mode = "gather"
				else:
					who.mode = "move"

func build(who):
	if !check(wastarget, Vector2(unit[who]["size"], unit[who]["size"])):
		return
	var whoo = load("res://unit.tscn").instantiate()
	whoo.global_position = wastarget
	whoo.type = who
	whoo.progress = 0
	whoo.alive = false
	whoo.side = side
	whoo.queue.append(who)
	get_parent().add_child(whoo)
	target = whoo
	mode = "build"
	whoo.hp = 10
	

func check(world_pos: Vector2, size: Vector2) -> bool:
	var shape := RectangleShape2D.new()
	shape.size = size - Vector2(2, 2)

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, world_pos)
	params.collision_mask = BLOCK_MASK
	params.collide_with_bodies = true
	params.collide_with_areas = false

	var hits := get_world_2d().direct_space_state.intersect_shape(params, 1)
	return hits.is_empty()
