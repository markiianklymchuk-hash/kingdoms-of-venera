extends CharacterBody2D


var colors = {
	"0" = Color("000000"),
	"1" = Color("ff0000"),
	"2" = Color("0000ff"),
	"3" = Color("00ff00"),
	"4" = Color("ffff00"),
	"5" = Color("ff7fffff"),
	"6" = Color("404040ff"),
}
@export var type = ""
@export var side = 0
@export var bounty = 0
@export var givesight = false
@export var starting_health = 1.0
@export var truehero = true
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
var effex = []
var possiblefx = ["regenerate", "dropoff point"]
var searchtimer = 1
var flying = false
var abilitycds = [0,0,0,0,0,0,0,0]
@onready var nav: NavigationAgent2D = $NavigationAgent2D
var configured = false

func _dir_to(point: Vector2) -> Vector2:
	if building or flying:
		return global_position.direction_to(point)
	if nav.target_position.distance_to(point) > 16.0:
		nav.target_position = point
	if nav.is_navigation_finished():
		return Vector2.ZERO
	return global_position.direction_to(nav.get_next_path_position())

func _ready() -> void:
	main = get_parent().get_node("C/" + str(side))
	scenario= get_parent()
	if scenario.type == str(side):
		givesight = true
	if main.unit[type]["speed"] == 0:
		building= true
		set_collision_layer_value(2, true)
	else:
		building= false
		set_collision_layer_value(1, true)
	queue_redraw()
	hp = main.unit[type]["health"] * starting_health
	starting_health = 1
	add_to_group("unit")
	add_to_group(str(side))
	$colider.shape = $colider.shape.duplicate()
	$colider.shape.radius = main.unit[type]["size"]
	if main.unit[type]["commands"].has("dropoff point"):
		manage_fx("add", "dropoff point", ["dropoff point"])
	if building:
		main.stats["buildings produced"] += 1
	elif main.unit[type]["commands"].has("worker"):
		main.stats["workers produced"] += 1
	else:
		main.stats["units produced"] += 1
	flying = main.unit[type]["flying"]
	main.check_for_heros()
	await get_tree().physics_frame
	if flying:
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, false)
		set_collision_layer_value(4, true)
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, false)
		set_collision_mask_value(4, true)
		z_index = 1
	else:
		set_collision_layer_value(4, false)
		set_collision_mask_value(4, false)
	main.check_tree()


func manage_fx(what_to_do, fx, description):
	if what_to_do == "add":
		if !effex.has(description) and possiblefx.has(fx):
			effex.append(description)
	if what_to_do == "dda":
		if effex.has(description):
			effex.erase(description)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if alive:
		cd -= delta
		handle_shit(delta)
	else:
		if mode == "cancel":
			queue.clear()
	if hp <= 0:
		die()
	if !alive and queue.is_empty():
		die()
	if !building:
		move_and_slide()
	if selected:
		if !givesight and !main.fog.can_see(global_position):
			selected = false

func die():
	queue_free()
	if selected:
		main.selectedall.erase(self)
	for i in get_groups():
		remove_from_group(i)
	if queue.size() >= 1:
		for i in queue:
			queue.erase(i)
			main.lumber += main.unit[type][i + " lumber"]
	main.stats["units lost(in value)"] += main.unit[type]["value"]
	main.stats["units lost"] += 1
	main.check_tree()
	main.check_for_heros()


func learn():
	main.pos = pos
	main.learn()
	draww = main.draww

func _draw() -> void:
	if is_instance_valid(main.first) and main.first is Node2D and main.first == self:
		is_main = true
	else:
		is_main = false
	draw_circle(Vector2.ZERO, main.unit[type]["size"], colors[str(side)], true)
	learn()
	draw_colored_polygon(draww[type][0], draww[type][1])
	if selected:
		if str(side) == scenario.type and !is_main:
			draw_circle(Vector2.ZERO, main.unit[type]["size"] * 5 / 4, Color("00ff00"), false, main.unit[type]["size"] / 8)
		elif str(side) == scenario.type and is_main:
			draw_circle(Vector2.ZERO, main.unit[type]["size"] * 5 / 4, Color("003b00ff"), false, main.unit[type]["size"] / 8)
		elif scenario.allies[scenario.type].has(str(side)):
			draw_circle(Vector2.ZERO, main.unit[type]["size"] * 5 / 4, Color("aea400ff"), false, main.unit[type]["size"] / 8)
		else:
			draw_circle(Vector2.ZERO, main.unit[type]["size"] * 5 / 4, Color("ff0000"), false, main.unit[type]["size"] / 8)

func attack(who, how):
	if who == null:
		search(how)
		return
	else:
		if cd <= -1:
			cd =  main.unit[type]["cooldown"]
			currently_attacking = false
		elif cd <= 0:
			cd = main.unit[type]["cooldown"]
			currently_attacking = true
			damage()
		elif cd <= main.unit[type]["cooldown"]/2:
			currently_attacking = false

func search(how):
	if searchtimer > 0:
		searchtimer -= get_process_delta_time()
		return
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
					if can_target(he):
						best = he
				else:
					if can_target(he):
						if global_position.distance_to(best.global_position) > global_position.distance_to(he.global_position):
							best = he
	if best != null:
		wasmode = mode
		target = best
		mode = "attack"
		is_atacking_from_order = false
	searchtimer = 1

func search_for_dropoff():
	var all = get_tree().get_nodes_in_group("unit")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		if he.is_in_group(str(side)) and he.effex.has(["dropoff point"]):
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
	main.command()


func search_for_resourse():
	var all = get_tree().get_nodes_in_group("tree")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		if best == null:
			if he.global_position.distance_to(global_position) <= main.unit[type]["search"] and he.gatherers < 2:
				best = he
		else:
			if (global_position.distance_to(best.global_position) > global_position.distance_to(he.global_position) and he.global_position.distance_to(global_position) <= main.unit[type]["search"] and he.gatherers <2 and wastarget != he) or is_instance_valid(wastarget) and wastarget is Node2D and wastarget == he:
				best = he
	if best != null:
		target = best
		mode = "gather"
	else:
		mode = "idle"
	main.command()
	
func damage():
	var washp = target.hp
	var full_damage = max(main.unit[type]["damage"] * main.damage_matrix[target.main.unit[target.type]["armor type"]][main.unit[type]["damage type"]], 0) 
	target.hp -= full_damage
	if target.hp <= 0:
		mode = "idle"
		currently_attacking = false
		if washp > 0:
			kill(target)
		target = null

func kill(who):
	main.stats["units killed(in value)"] += main.unit[who.type]["value"]
	main.stats["units killed"] += 1
	get_mony(who.bounty)

func apply_fx(typeis, delta):
	if typeis == "everyframe":
		for i in effex:
			if i[0] == "regenerate":
				heal(self, i[1] * delta)

func heal(who, how_much):
	who.hp += how_much
	if who.hp > main.unit[who.type]["health"]:
		who.hp = main.unit[who.type]["health"]

func handle_shit(delta):
	apply_fx("everyframe", delta)
	abilityreload(delta)
	if mode == "move":
		progress = 0
		if !main.unit[type]["commands"].has(mode):
			mode = "idle"
			return
		wasmode = mode
		currently_attacking = false
		if target == null:
			mode = "idle"
			return
		if target is Vector2:
			wastarget = target
			dir = _dir_to(wastarget)
			if global_position.distance_to(wastarget) <= 16:
				mode = "idle"
		else:
			if target == self:
				mode = "idle"
			wastarget= target
			dir = _dir_to(wastarget.global_position)
			if global_position.distance_to(wastarget.global_position) <= 1.5 * (main.unit[type]["size"] + main.unit[wastarget.type]["size"]):
				dir = Vector2.ZERO
		velocity = dir * main.unit[type]["speed"]
	if mode == "holy light":
		progress = 0
		wasmode = mode
		currently_attacking = false
		if target == null or target == self:
			mode = "idle"
			return
		if abilitycds[main.unit[type][mode + " ability slot"]] > 0:
			mode = "idle"
			main.error("ability hasn't been recharged yet!", 1.0)
			return
		if  main.unit[type].keys().has(mode + " req"):
			var s = false
			if main.unit[type][mode + " req"][0] == "herolvl" and main.unit[type][mode + " req"][1] > main.herolvl:
				s = true
			if s:
				mode = "idle"
				return
		wastarget= target
		dir = _dir_to(wastarget.global_position)
		if global_position.distance_to(wastarget.global_position) <= 1.5 * (main.unit[type]["size"] + main.unit[wastarget.type]["size"]):
			dir = Vector2.ZERO
			heal(target, main.unit[type]["holy light heal"])
			abilitycds[main.unit[type][mode + " ability slot"]] = main.unit[type][mode + " cooldown"]
			mode = "idle"
		velocity = dir * main.unit[type]["speed"]
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
		dir = _dir_to(wastarget.global_position)
		if global_position.distance_to(wastarget.global_position) <= 60 + main.unit[type]["size"]:
			dir = Vector2.ZERO
			progress += delta
			if carrying.size() >= 1:
				search_for_dropoff()
				return
			if progress >= main.unit[type]["gather"]:
				progress = 0
				target.lumber -= main.unit[type]["how much"]
				carrying.append("lumber")
				search_for_dropoff()
				return
		else:
			progress = 0
		velocity = dir * main.unit[type]["speed"]
	if mode == "building":
		wasmode = mode
		currently_attacking = false
		wastarget= target
		if wastarget == null:
			return
		dir = _dir_to(wastarget)
		if global_position.distance_to(wastarget) <= main.unit[what]["size"] + main.unit[type]["size"]:
			if main.lumber >= main.unit[type][what + " lumber"]:
				dir = Vector2.ZERO
				build(what)
				main.lumber -= main.unit[type][what + " lumber"]
				main.stats["resources spent"] += main.unit[type][what + " lumber"]
				what = null
			elif main.lumber < main.unit[type][what + " lumber"]:
				main.error("not enough lumber", 1)
				mode = "idle"
		velocity = dir * main.unit[type]["speed"]
	if mode == "build":
		wasmode = mode
		currently_attacking = false
		if target == null or !is_instance_valid(target):
			mode = "idle"
			target = null
			return
		wastarget= target
		progress = 0
		dir = _dir_to(wastarget.global_position)
		if global_position.distance_to(wastarget.global_position) <= main.unit[target.type]["size"] + main.unit[type]["size"] + 4:
			dir = Vector2.ZERO
			progress = 1
			target.progress += delta
			target.hp += main.unit[target.type]["health"] / main.unit[type][target.type + " time"] * delta
			if target.progress >= main.unit[type][target.type + " time"] or target.alive:
				target.progress = 0
				target.alive = true
				mode = "idle"
				target.queue.clear()
				target.main.check_tree()
				target.main.check_for_heros()
				main.command()
				if target.hp > main.unit[target.type]["health"]:
					target.hp = main.unit[target.type]["health"]
				return
		velocity = dir * main.unit[type]["speed"]
	if mode == "return":
		wasmode = mode
		currently_attacking = false
		if target == null:
			mode = "idle"
			return
		dir = _dir_to(target.global_position)
		if global_position.distance_to(target.global_position) <= 1.25 * (main.unit[type]["size"] + main.unit[target.type]["size"]):
			dir = Vector2.ZERO
			if carrying.has("lumber"):
				carrying.erase("lumber")
				get_mony(main.unit[type]["how much"])
				search_for_resourse()
		velocity = dir * main.unit[type]["speed"]
	if mode == "idle":
		progress = 0
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		attack(null, main.unit[type]["aggro"])
	if mode == "creating":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		if queue.size() < 5 and main.lumber >= main.unit[type][what +" lumber"]:
			queue.append(what)
			main.lumber -= main.unit[type][what + " lumber"]
			main.stats["resources spent"] += main.unit[type][what + " lumber"]
			what = null
		elif main.lumber < main.unit[type][what + " lumber"]:
			main.error("not enough lumber", 1)
		if queue.size() != 0:
			mode = "buy"
		else:
			progress= 0
			mode = "idle"
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		attack(null, main.unit[type]["aggro"])
	if mode == "summon":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		main.check_for_heros()
		if queue.size() < 5 and main.lumber >= main.unit[type][what +" lumber"] and !main.heros.has(what):
			queue.append(what)
			main.lumber -= main.unit[type][what + " lumber"]
			main.stats["resources spent"] += main.unit[type][what + " lumber"]
			what = null
		elif main.lumber < main.unit[type][what + " lumber"]:
			main.error("not enough lumber", 1)
		if queue.size() != 0:
			mode = "buy"
		else:
			progress= 0
			mode = "idle"
	if mode == "revive":
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		main.check_for_heros()
		if !main.heros[what]:
			if queue.size() < 5:
				queue.append(what)
				what = null
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
			if main.unit[type].has(queue[queue.size() - 1] + " lumber"):
				main.lumber += main.unit[type][queue[queue.size() - 1] + " lumber"]
				main.stats["resources spent"] -= main.unit[type][queue[queue.size() - 1] + " lumber"]
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
		if main.currentsupply - main.unit[queue[0]]["supply"] <= main.supply:
			progress += delta
		var first = queue[0]
		if main.unit[type].has("hero time"):
			if progress >= main.unit[type]["hero time"]:
				create_unit(first)
		else:
			if progress >= main.unit[type][first + " time"]:
				create_unit(first)
		if queue.size() == 0:
			mode = "idle"
	if mode == "defence":
		progress = 0
		wasmode = mode
		currently_attacking = false
		velocity = Vector2(0,0)
		attack(null, main.unit[type]["range"])
	if mode == "attack":
		progress = 0
		if target == null:
			mode = "idle"
			return
		if target is Vector2:
			wasmode = mode
			wastarget = target
			dir = _dir_to(wastarget)
			attack(null, main.unit[type]["aggro"])
			if global_position.distance_to(wastarget) <= 16:
				mode = "idle"
		else:
			if target.hp <= 0:
				mode = "idle"
				return
			if !can_target(target):
				mode = "idle"
				return
			if !is_atacking_from_order:
				if target.global_position.distance_to(global_position) > main.unit[type]["aggro"]:
					mode = "idle"
					return
				else:
					attack(null, main.unit[type]["aggro"])
			dir = _dir_to(target.global_position)
			if global_position.distance_to(target.global_position) <= main.unit[type]["range"] + (main.unit[type]["size"] + main.unit[target.type]["size"]):
				dir = Vector2.ZERO
				attack(target, null)
			else:
				currently_attacking = false
		velocity = dir * main.unit[type]["speed"]

func create_unit(unitt):
	var who = load("res://unit.tscn").instantiate()
	who.type = unitt
	who.side = side
	who.global_position = Vector2(global_position.x, global_position.y + main.unit[type]["size"] * 1.25)
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
				if who.main.unit[who.type]["commands"].has("gather"):
					who.mode = "gather"
				else:
					who.mode = "move"

func build(who):
	if !check(wastarget, main.unit[who]["size"]):
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
	

func check(world_pos: Vector2, size: float) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = size

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, world_pos)
	params.collision_mask = BLOCK_MASK
	params.collide_with_bodies = true
	params.collide_with_areas = false

	var hits := get_world_2d().direct_space_state.intersect_shape(params, 1)
	return hits.is_empty()

func get_mony(how_much):
	main.lumber += how_much
	main.stats["resources gathered"] += how_much

func can_target(he):
	if he.flying and main.target_matrix[main.unit[type]["target"]][0]:
		return true
	elif !he.flying and !he.building and main.target_matrix[main.unit[type]["target"]][1]:
		return true
	elif he.building and main.target_matrix[main.unit[type]["target"]][2]:
		return true
	return false

func abilityreload(delta):
	for i in abilitycds.size():
		abilitycds[i] -= delta
