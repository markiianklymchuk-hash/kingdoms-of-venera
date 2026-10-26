extends Control

var unit = {
	"warrior" = {
		"size" = 16,
		"aggro" = 300,
		"supply" = -2,
		"health" = 110,
		"speed" = 2200,
		"damage" = 10,
		"damage type" = "hack",
		"armor" = 3,
		"armor type" = "medium",
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
		"damage type" = "hack",
		"armor" = 0,
		"armor type" = "unarmoured",
		"range" = 15,
		"cooldown" = 2.0,
		"gather" = 5,
		"how much" = 10,
		"search" = 300,
		"barracks lumber" = 150,
		"barracks time" = 45,
		"command centre lumber" = 375,
		"command centre time" = 60,
		"farm lumber" = 100,
		"farm time" = 20,
		"watchtower lumber" = 125,
		"watchtower time" = 25,
		"commands" = ["move", "attack", "stop", "defend", "gather", "return", "build", "continue building"],
		"build commands" = ["build barracks", "build command centre", "build farm", "back", "build watchtower"],
	},
	"archer" = {
		"size" = 12,
		"aggro" = 400,
		"supply" = -2,
		"health" = 80,
		"speed" = 2400,
		"damage" = 10,
		"damage type" = "piercing",
		"armor" = 0,
		"armor type" = "unarmoured",
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
		"damage type" = "cut",
		"armor" = 2,
		"armor type" = "light",
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
		"damage type" = "unarmed",
		"armor" = 0,
		"armor type" = "unarmoured",
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
		"damage type" = "unarmed",
		"armor" = 5,
		"armor type" = "building",
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
		"damage type" = "unarmed",
		"armor" = 5,
		"armor type" = "building",
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
		"damage type" = "unarmed",
		"armor" = 3,
		"armor type" = "building",
		"range" = 400,
		"cooldown" = -1,
		"farm time" = 20,
		"commands" = [],
		"cancel commands" = ["cancel"],
	}, 
	"watchtower" = {
		"size" = 32,
		"aggro" = 300,
		"supply" = 0,
		"health" = 300,
		"speed" = 0,
		"damage" = 14,
		"damage type" = "piercing",
		"armor" = 3,
		"armor type" = "building",
		"range" = 240,
		"cooldown" = 2,
		"watchtower time" = 25,
		"commands" = ["attack", "stop"],
		"cancel commands" = ["cancel"],
	}, 
}
var damage_matrix = {
	"unarmoured" = {
		"hack" = 0.75,
		"piercing" = 0.5,
		"cut" = 1,
	},
	"light" = {
		"hack" = 1,
		"piercing" = 0.75,
		"cut" = 0.75,
	},
	"medium" = {
		"hack" = 0.75,
		"piercing" = 1,
		"cut" = 0.5,
	},
	"building" = {
		"hack" = 0.75,
		"piercing" = 0.25,
		"cut" = 0,
	},
}
@export var lumber = 0
var currentsupply = 0
var supply = 0
@export var supplylimit = 0

var dragin = false
var pos
var draww = {
}
var BLOCK_MASK = 0b110
var selecting = false
var selectedall = []
var first = null
var mode = "idle"
var target = null
var dragsel = 0
var pointa = null
var pointaevent = null
var pointbevent = null
var pointb = null
var lasttap 
var build = false
var oneunit = false
@export var player = "1"
var active = true
var what = null
@export var available = {
	"UI_buttons" = {
		"move" = true,
		"build" = true,
		"create warrior" = true,
		"create worker" = true,
		"create archer" = true,
		"create cavalry" = true,
		"cancel" = true,
		"continue building" = true,
		"attack" = true,
		"gather" = true,
		"return" = true,
		"stop" = true,
		"defend" = true,
		"rally" = true,
		"dropoff point" = true,
		"create" = true,
	},
	"UI_buttons_build" = {
		"build barracks" = true,
		"back" = true,
		"build command centre" = true,
		"build farm" = true,
		"build watchtower" = true,
	},
	"UI_buttons_cancel" = {
		"cancel" = true,
	}
}
func _ready() -> void:
	if get_parent().get_parent().type != player:
		active = false
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		selectedall = get_tree().get_nodes_in_group("selected")
	command()

func _to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


func _unhandled_input(event: InputEvent) -> void:
	if !active:
		return
	if event is InputEventScreenDrag:
		dragg(event)
	if event is InputEventScreenTouch:
		if event.pressed and !dragin:
			touch(event)
		if !event.pressed:
			if dragsel == 2:
				stopbox()
			await get_tree().process_frame
			await get_tree().process_frame
			if lasttap == "select" and !dragin:
				refresh()
			await get_tree().process_frame
			command()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw()
	find_supply()
	$stats/lumber.text = "lumber: " + str(lumber)
	$stats/supply.text = "supply: " + str(currentsupply) + "/" + str(supply)
	$UI_text/hp.visible = true
	$UI_text/next.visible = true
	$UI_text/indicator.visible = dragin
	var selected= get_tree().get_nodes_in_group("unit")
	for i in range(selected.size()):
		if selected[i].selected:
			selected[i].add_to_group("selected")
		else:
			selected[i].remove_from_group("selected")
	if selectedall.size() == 0:
		first = null
		$UI_text/unit.text = "no units selected"
		$UI_text/hp.visible = false
		$UI_text/next.visible = false
	elif selectedall.size() == 1:
		first = selectedall[0]
		if is_instance_valid(first):
			$UI_text/unit.text = "unit: " + first.type 
			$UI_text/hp.text = "health: " + str(int(first.hp))
			$UI_text/next.visible = false
		else:
			refresh()
		
	else:
		first = selectedall[0]
		if is_instance_valid(first):
			$UI_text/unit.text = "unit: " + first.type + " and " + str(selectedall.size() - 1) + " more"
			$UI_text/hp.text = "health: " + str(int(first.hp))
		else:
			refresh()

func refresh():
	selectedall = get_tree().get_nodes_in_group("selected")
	if selectedall.size() != 0:
		selectedall[0].is_main = true

func error(huh, how_long):
	$stats/error.text = huh
	await get_tree().create_timer(how_long).timeout
	if $stats/error.text == huh:
		$stats/error.text = ""

func find_supply():
	supply = 0
	currentsupply = 0
	for i in get_tree().get_nodes_in_group(player):
		if unit[i.type]["supply"] > 0 and i.alive:
			supply += unit[i.type]["supply"]
		elif i.alive:
			currentsupply -= unit[i.type]["supply"]
	if supply >= supplylimit:
		supply = supplylimit

func command():
	$UI_buttons.visible = false
	$UI_buttons_build.visible = false
	$UI_buttons_cancel.visible = false
	if first != null:
		if build and first.alive:
			$UI_buttons_build.visible = true
			for i in $UI_buttons_build.get_children():
				i.visible = false
			if str(first.side) != player:
				return
			for i in first.main.unit[first.type]["build commands"]:
				get_node("UI_buttons_build/" + i).visible = true
				if i.contains("build "):
					get_node("UI_buttons_build/" + i).text =  i + " \n" + str(first.main.unit[first.type][i.substr(6) + " lumber"]) +" lumber, +" + str(first.main.unit[i.substr(6)]["supply"]) + " supply"
		elif !first.alive:
			$UI_buttons_cancel.visible = true
			for i in $UI_buttons_cancel.get_children():
				i.visible = false
			if str(first.side) != player:
				return
			for i in first.main.unit[first.type]["cancel commands"]:
				get_node("UI_buttons_cancel/" + i).visible = true
		else:
			$UI_buttons.visible = true
			for i in $UI_buttons.get_children():
				i.visible = false
			if str(first.side) != player:
				return
			for i in first.main.unit[first.type]["commands"]:
				get_node("UI_buttons/" + i).visible = true
				if i.contains("create "):
					get_node("UI_buttons/" + i).text =  i + " \n" + str(first.main.unit[first.type][i.substr(7) + " lumber"]) +" lumber, " + str(first.main.unit[i.substr(7)]["supply"]) + " supply"
		for u in available.keys():
			for i in available[u].keys():
				if !available[u][i]:
					get_node(u + "/" + i).visible = false
	else:
		$UI_buttons.visible = false
		$UI_buttons_build.visible = false

func dragg(event):
	var camera = get_parent().get_parent().get_node("Camera")
	if !dragsel:
		camera.position -= event.relative / camera.zoom
		if camera.position.x <= camera.get_parent().cameralimits[0]:
			camera.position.x = camera.get_parent().cameralimits[0]
		if camera.position.x >= camera.get_parent().cameralimits[1]:
			camera.position.x = camera.get_parent().cameralimits[1]
		if camera.position.y <= camera.get_parent().cameralimits[2]:
			camera.position.y = camera.get_parent().cameralimits[2]
		if camera.position.y >= camera.get_parent().cameralimits[3]:
			camera.position.y = camera.get_parent().cameralimits[3]
		
	else:
		refresh()
		lasttap = "select"
		drawbox(event)

func drawbox(event):
	dragsel = 2
	var world_pos = _to_world(event.position)
	if pointa == null:
		pointa = world_pos
		pointaevent = event.position
	pointbevent = event.position
	pointb = world_pos

func stopbox():
	dragsel = 0
	if pointaevent != null and pointbevent != null:
		var box = Rect2(_to_world(pointaevent), Vector2.ZERO).expand(_to_world(pointbevent))
		for u in get_tree().get_nodes_in_group("unit"):
			u.selected = false
			u.is_main = false
		for u in get_tree().get_nodes_in_group(player):
			var r = unit[u.type]["size"]
			if box.grow(r).has_point(u.global_position):
				u.selected = true
	pointa = null
	pointb = null
	pointaevent = null
	pointbevent = null

func touch(event):
	if !selecting:
		lasttap = "select"
		select(event)
	else:
		lasttap = "do"
		do(event)
	command()

func do(event):
	var world_pos = _to_world(event.position)
	var best = null
	if mode == "gather":
		for i in range(get_tree().get_node_count_in_group("tree")):
			var units = get_tree().get_nodes_in_group("tree")
			var ranger = 40
			if best == null and world_pos.distance_to(units[i].global_position) <= ranger:
				best = units[i]
			elif best != null:
				if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
					best = units[i]
	elif mode == "build":
		for i in range(get_tree().get_node_count_in_group("unit")):
			var units = get_tree().get_nodes_in_group("unit")
			var ranger = units[i].main.unit[units[i].type]["size"]
			if best == null and world_pos.distance_to(units[i].global_position) <= ranger and units[i].building and !units[i].alive:
				best = units[i]
			elif best != null and units[i].building and !units[i].alive:
				if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
					best = units[i]
	elif mode == "rally":
		for i in range(get_tree().get_node_count_in_group("unit") + get_tree().get_node_count_in_group("tree")):
			var units = get_tree().get_nodes_in_group("unit")
			units.append_array(get_tree().get_nodes_in_group("tree"))
			var ranger
			if units[i].is_in_group("unit"):
				ranger = units[i].main.unit[units[i].type]["size"] + 4
			else:
				ranger = 40
			if best == null and world_pos.distance_to(units[i].global_position) <= ranger:
				best = units[i]
			else:
				if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
					best = units[i]
	else:
		for i in range(get_tree().get_node_count_in_group("unit")):
			var units = get_tree().get_nodes_in_group("unit")
			var ranger = units[i].main.unit[units[i].type]["size"] + 4
			if best == null and world_pos.distance_to(units[i].global_position) <= ranger:
				best = units[i]
			elif best != null:
				if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
					best = units[i]
	if best != null:
		target = best
	if oneunit:
		var u = first
		if mode == "building":
			if check(world_pos, first.main.unit[what]["size"]):
				u.target = world_pos
				u.mode = mode
				u.what = what
	else:
		for u in get_tree().get_nodes_in_group("selected"):
			var actualmode = modify()
			if u.is_in_group(player) and unit[u.type]["commands"].has(actualmode):
				if mode == "attack":
					u.is_atacking_from_order = true
				else:
					u.is_atacking_from_order = false
				if target != null:
					u.mode = mode
					u.target = target
					if mode == "attack":
						u.wastarget = target
				else:
					if mode == "gather":
						u.target = null
					else:
						u.mode = mode
						u.target = world_pos
	mode = "idle"
	selecting = false
	target = null
	what = null
	build = false

func check(world_pos: Vector2, sizes: float) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = sizes

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0.0, world_pos)
	params.collision_mask = BLOCK_MASK
	params.collide_with_bodies = true
	params.collide_with_areas = false

	var hits := get_world_2d().direct_space_state.intersect_shape(params, 1)
	if !hits.is_empty():
		error("can't place here", 1)
	return hits.is_empty()

func select(event):
	var world_pos = _to_world(event.position)
	var best = null
	for i in range(get_tree().get_node_count_in_group("unit")):
		var units = get_tree().get_nodes_in_group("unit")
		var ranger = units[i].main.unit[units[i].type]["size"] + 4
		units[i].selected = false
		units[i].is_main = false
		if best == null and world_pos.distance_to(units[i].global_position) <= ranger:
			best = units[i]
		elif best != null:
			if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
				best = units[i]
	if best != null:
		best.selected = true
		best.is_main = true
	build = false

func _move() -> void:
	selecting = true
	mode = "move"
	oneunit = false


func modify():
	if mode == "move":
		return "move"
	if mode == "rally":
		return "rally"
	if mode == "gather":
		return "gather"
	if mode == "attack":
		return "attack"
	if mode == "defence":
		return "defend"
	if mode == "return":
		return "return"
	if mode == "building":
		return "building"
	if mode == "creating":
		return "create"
	if mode == "cancel":
		return "cancel"
	return "stop"

func learn():
	draww["warrior"] = [[Vector2(pos[0] - 10, pos[1] - 10), Vector2(pos[0] + 10, pos[1] - 10), Vector2(pos[0] + 10, pos[1] + 10), Vector2(pos[0], pos[1] + 20), Vector2(pos[0] - 10, pos[1] + 10)], Color("9b7600ff")]
	draww["archer"] = [[Vector2(pos[0] - 10, pos[1] + 15), Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 15, pos[1] - 10)], Color("632900ff")]
	draww["barracks"] = [[Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 5, pos[1])], Color("ebdcd3ff")]
	draww["command centre"] = [[Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 5, pos[1])], Color("ebdcd3ff")]
	draww["farm"] = [[Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 5, pos[1])], Color("ebdcd3ff")]
	draww["watchtower"] = [[Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 5, pos[1])], Color("ebdcd3ff")]
	draww["civilian"] = [[Vector2(pos[0] - 5, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 5, pos[1])], Color("ebdcd3ff")]
	draww["worker"] = [[Vector2(pos[0] - 10, pos[1] + 10), Vector2(pos[0] + 5, pos[1] - 5), Vector2(pos[0], pos[1] - 7.5), Vector2(pos[0] + 10, pos[1] - 7.5), Vector2(pos[0] + 10, pos[1]), Vector2(pos[0] +5, pos[1] - 2.5), Vector2(pos[0] - 7.5, pos[1] + 10)], Color("b3a29dff")]
	draww["cavalry"] = [[Vector2(pos[0] - 10, pos[1] + 10), Vector2(pos[0] - 10, pos[1]), Vector2(pos[0], pos[1] - 5), Vector2(pos[0] + 9, pos[1] - 5), Vector2(pos[0] + 9, pos[1] - 3), Vector2(pos[0] + 4, pos[1] - 3), Vector2(pos[0] +4, pos[1] + 10), Vector2(pos[0] + 1, pos[1] + 10), Vector2(pos[0] +1, pos[1] + 3), Vector2(pos[0] -7, pos[1] + 3), Vector2(pos[0] -7, pos[1] + 10)], Color("ebdcd3ff")]


func _on_attack_pressed() -> void:
	selecting = true
	mode = "attack"
	oneunit = false


func _on_stop_pressed() -> void:
	selecting = false
	mode = "idle"
	do_but_cooler()

func do_but_cooler():
	for u in get_tree().get_nodes_in_group("selected"):
		var actualmode = modify()
		if u.is_in_group(player) and unit[u.type]["commands"].has(actualmode) or unit[u.type].has("cancel commands") and unit[u.type]["cancel commands"].has(actualmode):
			u.mode = mode
			u.target = null
			u.is_atacking_from_order = false
			u.what = what
			if mode == "return":
				u.search_for_dropoff()
	mode = "idle"
	selecting = false
	target = null
	build = false
	what = null


func _on_defend_pressed() -> void:
	selecting = false
	mode = "defence"
	do_but_cooler()


func _on_selectmult_pressed() -> void:
	if !dragin:
		dragsel = 1

func _draw():
	if pointaevent != null and pointbevent != null:
		var box = Rect2(pointaevent, Vector2.ZERO).expand(pointbevent)
		draw_rect(box, Color(0, 1, 0, 0.3))
		draw_rect(box, Color(0, 1, 0, 0.9), false, 2.0)

	if first == null or str(first.side) != player:
		return
	if first.queue.size() > 0:
		pos = Vector2(425, 475)
		learn()
		draw_line(pos + Vector2(25, 0), pos + Vector2(75,0), Color("000000ff"), 2)
		draw_line(pos + Vector2(25, 0), pos + Vector2(25 + 50 * first.progress / first.main.unit[first.type][first.queue[0] + " time"],0), Color("ffff00ff"), 2)
		draw_colored_polygon(draww[first.queue[0]][0],draww[first.queue[0]][1])
	if first.queue.size() > 1:
		pos = Vector2(475, 525)
		learn()
		draw_colored_polygon(draww[first.queue[1]][0],draww[first.queue[1]][1])
	if first.queue.size() > 2:
		pos = Vector2(425, 525)
		learn()
		draw_colored_polygon(draww[first.queue[2]][0],draww[first.queue[2]][1])
	if first.queue.size() > 3:
		pos = Vector2(475, 575)
		learn()
		draw_colored_polygon(draww[first.queue[3]][0],draww[first.queue[3]][1])
	if first.queue.size() > 4:
		pos = Vector2(425, 575)
		learn()
		draw_colored_polygon(draww[first.queue[4]][0],draww[first.queue[4]][1])
	

func _on_next_pressed() -> void:
	var unitk = selectedall[0]
	selectedall.erase(unitk)
	selectedall.append(unitk)
	for i in selectedall:
		i.is_main = false
	if selectedall.size() != 0:
		selectedall[0].is_main = true
	await get_tree().process_frame
	await get_tree().process_frame
	command()
	


func _on_create_warrior_pressed() -> void:
	selecting = false
	mode = "creating"
	what = "warrior"
	do_but_cooler()



func _on_cancel_pressed() -> void:
	selecting = false
	mode = "cancel"
	do_but_cooler()


func _on_create_archer_pressed() -> void:
	selecting = false
	mode = "creating"
	what = "archer"
	do_but_cooler()


func _on_create_cavalry_pressed() -> void:
	selecting = false
	mode = "creating"
	what = "cavalry"
	do_but_cooler()


func _on_create_worker_pressed() -> void:
	selecting = false
	mode = "creating"
	what = "worker"
	do_but_cooler()



func _on_gather_pressed() -> void:
	selecting = true
	mode = "gather"
	oneunit= false


func _on_return_pressed() -> void:
	selecting = false
	mode = "return"
	do_but_cooler()


func _on_build_pressed() -> void:
	selecting = false
	mode = "idle"
	build = true
	command()


func _on_back_pressed() -> void:
	selecting = false
	mode = "idle"
	build = false
	command()


func _on_build_barracks_pressed() -> void:
	selecting = true
	mode = "building"
	what = "barracks"
	oneunit= true


func _on_build_command_centre_pressed() -> void:
	selecting = true
	mode = "building"
	what = "command centre"
	oneunit= true


func _on_continue_building_pressed() -> void:
	selecting = true
	mode = "build"
	oneunit= false


func _on_build_farm_pressed() -> void:
	selecting = true
	mode = "building"
	what = "farm"
	oneunit= true


func _on_dragin_pressed() -> void:
	dragin = !dragin


func _on_rally_pressed() -> void:
	selecting = true
	mode = "rally"
	oneunit= false


func _on_build_watchtower_pressed() -> void:
	selecting = true
	mode = "building"
	what = "watchtower"
	oneunit= true
