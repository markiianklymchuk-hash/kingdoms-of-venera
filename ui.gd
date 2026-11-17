extends Control

var unit = {
	"warrior" = {
		"size" = 16,
		"flying" = false,
		"aggro" = 300,
		"vision" = 350,
		"supply" = -2,
		"value" = 60,
		"health" = 110,
		"speed" = 35,
		"damage" = 10,
		"damage type" = "hack",
		"target" = 1,
		"armor type" = "medium",
		"range" = 15,
		"cooldown" = 1.0,
		"commands" = ["move", "attack", "stop", "defend"],
	},
	"worker" = {
		"size" = 10,
		"flying" = false,
		"aggro" = 300,
		"vision" = 350,
		"supply" = -1,
		"value" = 25,
		"health" = 60,
		"speed" = 45,
		"damage" = 5,
		"damage type" = "hack",
		"armor type" = "unarmoured",
		"target" = 1,
		"range" = 15,
		"cooldown" = 2.0,
		"gather" = 5,
		"how much" = 10,
		"search" = 300,
		"barracks lumber" = 150,
		"barracks time" = 60,
		"command centre lumber" = 375,
		"command centre time" = 60,
		"farm lumber" = 100,
		"farm time" = 20,
		"watchtower lumber" = 125,
		"watchtower time" = 25,
		"hero altar lumber" = 125,
		"hero altar time" = 60,
		"commands" = ["move", "attack", "stop", "defend", "gather", "return", "build", "continue building", "worker"],
		"build commands" = ["build barracks", "build command centre", "build farm", "back", "build watchtower", "build hero altar"],
	},
	"archer" = {
		"size" = 12,
		"flying" = false,
		"aggro" = 400,
		"vision" = 400,
		"supply" = -2,
		"value" = 60,
		"health" = 80,
		"speed" = 40,
		"damage" = 10,
		"damage type" = "piercing",
		"target" = 2,
		"armor type" = "unarmoured",
		"range" = 200,
		"cooldown" = 3.0,
		"commands" = ["move", "attack", "stop", "defend"],
	},
	"cavalry" = {
		"size" = 20,
		"flying" = false,
		"aggro" = 400,
		"vision" = 400,
		"supply" = -3,
		"value" = 85,
		"health" = 120,
		"speed" = 80,
		"damage" = 5,
		"damage type" = "cut",
		"target" = 1,
		"armor type" = "light",
		"range" = 10,
		"cooldown" = 0.3,
		"commands" = ["move", "attack", "stop", "defend"],
	}, 
	"civilian" = {
		"size" = 8,
		"flying" = false,
		"aggro" = 0,
		"vision" = 250,
		"supply" = -1,
		"value" = 0,
		"health" = 40,
		"speed" = 40,
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 0,
		"armor type" = "unarmoured",
		"range" = 200,
		"cooldown" = -1,
		"commands" = ["move", "stop"],
	},
	"barracks" = {
		"size" = 68,
		"flying" = false,
		"aggro" = 0,
		"vision" = 350,
		"supply" = 0,
		"value" = 150,
		"health" = 1400,
		"speed" = 0,
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 0,
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
		"flying" = false,
		"aggro" = 0,
		"vision" = 500,
		"supply" = 10,
		"value" = 375,
		"health" = 2000,
		"speed" = 0,
		"dropoff point" = ["dropoff point"],
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 0,
		"armor type" = "building",
		"range" = 400,
		"cooldown" = -1,
		"command centre time" = 60,
		"worker lumber" = 25,
		"worker time" = 10,
		"commands" = ["create worker", "cancel", "dropoff point",  "create", "rally"],
		"cancel commands" = ["cancel"],
	}, 
	"hero altar" = {
		"size" = 60,
		"flying" = false,
		"aggro" = 0,
		"vision" = 350,
		"supply" = 0,
		"value" = 125,
		"health" = 1200,
		"speed" = 0,
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 0,
		"armor type" = "building",
		"range" = 400,
		"cooldown" = -1,
		"hero altar time" = 60,
		"hero time" = 60,
		"the paladin time" = 60,
		"the paladin lumber" = 100,
		"commands" = ["revive hero 1", "revive hero 2", "revive hero 3", "cancel", "rally", "revive", "summon the paladin", "create"],
		"cancel commands" = ["cancel"],
	}, 
	"farm" = {
		"size" = 36,
		"flying" = false,
		"aggro" = 0,
		"vision" = 200,
		"supply" = 8,
		"value" = 100,
		"health" = 800,
		"speed" = 0,
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 1,
		"armor type" = "building",
		"range" = 400,
		"cooldown" = -1,
		"farm time" = 20,
		"commands" = [],
		"cancel commands" = ["cancel"],
	}, 
	"watchtower" = {
		"size" = 32,
		"flying" = false,
		"aggro" = 300,
		"vision" = 500,
		"supply" = 0,
		"value" = 125,
		"health" = 300,
		"speed" = 0,
		"damage" = 14,
		"damage type" = "piercing",
		"target" = 2,
		"armor type" = "building",
		"range" = 240,
		"cooldown" = 2.0,
		"watchtower time" = 25,
		"commands" = ["attack", "stop"],
		"cancel commands" = ["cancel"],
	}, 
	"the paladin" = {
		"size" = 20,
		"flying" = false,
		"aggro" = 300,
		"vision" = 350,
		"supply" = -2,
		"value" = 500,
		"health" = 200,
		"speed" = 40,
		"regenerate" = ["regenerate", 1],
		"regenerate req" = ["herolvl", 1, false],
		"holy light heal" = 60,
		"holy light cooldown" = 5,
		"holy light ability slot" = 5,
		"hero ability holy light req" = ["herolvl", 2, true],
		"damage" = 14,
		"damage type" = "blunt",
		"target" = 1,
		"armor type" = "heavy",
		"range" = 20,
		"cooldown" = 3.0,
		"commands" = ["move", "attack", "stop", "defend", "regenerate", "hero ability holy light", "hero"],
	}, 
	"bird" = {
		"size" = 4,
		"flying" = true,
		"aggro" = 200,
		"vision" = 200,
		"supply" = 0,
		"value" = 0,
		"health" = 20,
		"speed" = 100,
		"damage" = 0,
		"damage type" = "unarmed",
		"target" = 0,
		"armor type" = "unarmoured",
		"range" = 0,
		"cooldown" = -1.0,
		"commands" = ["move", "stop"],
	},
}
var damage_matrix = {
	"unarmoured" = {
		"hack" = 0.8,
		"piercing" = 0.6,
		"cut" = 1,
		"blunt" = 0.4,
	},
	"light" = {
		"hack" = 1,
		"piercing" = 0.8,
		"cut" = 0.8,
		"blunt" = 0.5,
	},
	"medium" = {
		"hack" = 0.7,
		"piercing" = 1,
		"cut" = 0.6,
		"blunt" = 0.75,
	},
	"heavy" = {
		"hack" = 0.5,
		"piercing" = 0.8,
		"cut" = 0.3,
		"blunt" = 1,
	},
	"building" = {
		"hack" = 0.6,
		"piercing" = 0.1,
		"cut" = 0,
		"blunt" = 1,
	},
}
var heros = {}
var herolvl = 1
var techtree = {
	"command centre" = [false, "build barracks", "build farm"],
	"barracks" = [false, "build watchtower", "build hero altar"],
	"farm" = [false, "create cavalry"],
	"hero altar" = [false, "herolvl 2"],
}
var target_matrix = [[false, false, false], [false, true, true], [true, true, true]]
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
		"build hero altar" = true,
	},
	"UI_buttons_cancel" = {
		"cancel" = true,
	},
	"UI_text" = {
		"next" = true,
		"dragin" = true,
	},
	"selectmult" = {
		"selectmult" = true,
	}
}
var stats = {
	"resources gathered" = 0,
	"resources spent" = 0,
	"units lost(in value)" = 0,
	"units killed(in value)" = 0,
	"units produced" = 0,
	"units lost" = 0,
	"units killed" = 0,
	"workers produced" = 0,
	"buildings produced" = 0
}
@onready var fog = get_parent().get_parent().get_node("fog")

func check_for_heros():
	herolvl = 1
	for i in techtree.keys():
		if techtree[i].has("herolvl 2") and herolvl < 2 and techtree[i][0]:
			herolvl = 2
		if techtree[i].has("herolvl 3") and herolvl < 3 and techtree[i][0]:
			herolvl = 3
	for i in get_tree().get_nodes_in_group(player):
		if unit[i.type]["commands"].has("hero") and i.truehero:
			if !heros.has(i.type):
				heros[i.type] = true
		for u in i.queue:
			if unit[u]["commands"].has("hero"):
				heros[i.type] = true
		if unit[i.type]["commands"].has("hero"):
			for u in unit[i.type]["commands"]:
				if unit[i.type].has(u + " req"):
					if unit[i.type][u + " req"][0] == "herolvl" and !unit[i.type][u + " req"][2]:
						if herolvl >= unit[i.type][u + " req"][1]:
							i.manage_fx("add", u, unit[i.type][u])
						else:
							i.manage_fx("dda", u, unit[i.type][u])
	for i in heros.keys():
		var is_it = false
		for u in get_tree().get_nodes_in_group(player):
			if u.type == i or u.queue.has(i):
				is_it = true
		heros[i] = is_it
		if !is_it and !selectedall.is_empty() and unit[selectedall[0].type]["commands"].has("revive"):
			command()

func _ready() -> void:
	if get_parent().get_parent().type != player:
		active = false
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		selectedall = get_tree().get_nodes_in_group("selected")
	stats["resources gathered"] += lumber
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

func check_tree():
	for i in techtree.keys():
		techtree[i][0] = false
	for i in get_tree().get_nodes_in_group(player):
		if techtree.keys().has(i.type) and i.alive:
			techtree[i.type][0] = true
		

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
		if first.queue.size() == 0:
			get_node("UI_buttons/cancel").disabled = true
		else:
			get_node("UI_buttons/cancel").disabled = false
		if first.carrying.size() == 0:
			get_node("UI_buttons/return").disabled = true
			get_node("UI_buttons/gather").disabled = false
		else:
			get_node("UI_buttons/return").disabled = false
			get_node("UI_buttons/gather").disabled = true
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
			for i in techtree.keys():
				var disabler = false
				for u in techtree[i]:
					if u is bool:
						disabler = !u
					else:
						if u.contains("build "):
							get_node("UI_buttons_build/"+u).disabled = disabler
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
				if i.contains("revive "):
					if heros.keys().size() >= int(i.erase(0,12)) and heros[heros.keys()[int(i.erase(0,12)) - 1]] == false:
						get_node("UI_buttons/" + i).disabled = false
						get_node("UI_buttons/" + i).text = "revive " + heros.keys()[int(i.erase(0, 12)) - 1] + ": " + str(first.main.unit[heros.keys()[int(i.erase(0, 12)) - 1]]["supply"]) + " supply"
					else:
						get_node("UI_buttons/" + i).disabled = true
						get_node("UI_buttons/" + i).text = "no one to revive"
				if i.contains("create "):
					get_node("UI_buttons/" + i).text =  i + " \n" + str(first.main.unit[first.type][i.substr(7) + " lumber"]) +" lumber, " + str(first.main.unit[i.substr(7)]["supply"]) + " supply"
				if i.contains("summon "):
					get_node("UI_buttons/" + i).text =  i + " \n" + str(first.main.unit[first.type][i.substr(7) + " lumber"]) +" lumber, " + str(first.main.unit[i.substr(7)]["supply"]) + " supply"
					get_node("UI_buttons/" + i).visible = true
					for u in heros.keys():
						if i.contains(u):
							get_node("UI_buttons/" + i).visible = false
				if i.contains("hero ability "):
					if unit[first.type][i + " req"][0] == "herolvl":
						if herolvl >= unit[first.type][i + " req"][1]:
							get_node("UI_buttons/" + i).disabled = false
						else:
							get_node("UI_buttons/" + i).disabled = true
			for i in techtree.keys():
				var disabler = false
				for u in techtree[i]:
					if u is bool:
						disabler = !u
					else:
						if u.contains("create "):
							get_node("UI_buttons/"+u).disabled = disabler
	else:
		$UI_buttons.visible = false
		$UI_buttons_build.visible = false
	$selectmult/selectmult.visible = true
	$UI_text/dragin.visible = true
	$UI_text/next.visible = true
	for u in available.keys():
		for i in available[u].keys():
			if !available[u][i]:
				get_node(u + "/" + i).visible = false

func dragg(event):
	var camera = get_parent().get_parent().get_node("Camera")
	if !dragsel or dragin:
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
			u.queue_redraw()
		var firstmade = false
		for u in get_tree().get_nodes_in_group(player):
			var r = unit[u.type]["size"]
			if box.grow(r).has_point(u.global_position):
				u.selected = true
				u.queue_redraw()
				if !firstmade:
					firstmade = true
					first = u
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
					u.searchtimer = 0
				else:
					u.is_atacking_from_order = false
				if target != null:
					u.mode = mode
					u.target = target
					if mode == "attack":
						u.wastarget = target
				else:
					if mode == "gather" or mode == "holy light":
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
		units[i].queue_redraw()
		if best == null and world_pos.distance_to(units[i].global_position) <= ranger:
			best = units[i]
		elif best != null:
			if world_pos.distance_to(units[i].global_position) <= ranger and world_pos.distance_to(units[i].global_position) < world_pos.distance_to(best.global_position):
				best = units[i]
	if best != null:
		best.selected = true
		first = best
		best.queue_redraw()
	build = false

func _move() -> void:
	selecting = true
	mode = "move"
	oneunit = false


func modify():
	if mode == "idle":
		return "stop"
	if mode == "defence":
		return "defend"
	if mode == "creating":
		return "create"
	if mode == "holy light":
		return "hero ability holy light"
	if mode == "summon":
		return "create"
	return mode

func learn():
	for i in unit.keys():
		draww[i] = [Polygons.get_node(str(i)).polygon, Polygons.get_node(str(i)).color]
	for i in draww.keys():
		for u in range(draww[i][0].size()):
			draww[i][0][u] += pos

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
		if unit[first.type].has("hero time"):
			draw_line(pos + Vector2(25, 0), pos + Vector2(25 + 50 * first.progress / unit[first.type]["hero time"],0), Color("ffff00ff"), 2)
		else:
			draw_line(pos + Vector2(25, 0), pos + Vector2(25 + 50 * first.progress / unit[first.type][first.queue[0] + " time"],0), Color("ffff00ff"), 2)
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
	first = selectedall[0]
	for u in selectedall:
		u.queue_redraw()
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


func _on_holy_light_pressed() -> void:
	selecting = true
	mode = "holy light"
	oneunit= false


func _on_build_hero_altar_pressed() -> void:
	selecting = true
	mode = "building"
	what = "hero altar"
	oneunit= true


func _on_revive_hero_1_pressed() -> void:
	selecting = false
	mode = "revive"
	what = heros.keys()[0]
	do_but_cooler()


func _on_summon_the_paladin_pressed() -> void:
	selecting = false
	mode = "summon"
	what = "the paladin"
	do_but_cooler()
