extends Node2D

var allies = {
	"0" = ["0", "1"],
	"1" = ["0", "1"],
	"2" = ["2"]
}
var defcords = [Vector2(-520, -360), Vector2(-500, -120), Vector2(-850, 50), Vector2(-360, 80), Vector2(-660, -300), Vector2(-970, -250), Vector2(-880, 20), Vector2(-460, 800)]
var objectives = {
	"main" = ["destroy the enemy base"],
	"bonus" = ["protect the civilians: ", "build a barracks", "build an army: "],
	"objectives progress" = [[5,5], true, [0,30, true], true]
}
var voicelines = [["Civilian: m'lord! Our enemy wants to kill us all! Please protect us!", true], ["warrior: thanks for rescuing us! we are with you!"], ["scout: enemies incoming!"], ["tip: you can press rally, to tell units where to go when they spawn(also allows automatic gathering)"]]
var tutorial_phase = 0
var defence_force = {
	"time" = 0,
	"warrior" = 4,
	"archer" = 3,
	"cavalry" = 1
}
var type = "1"
var units = ["warrior", "archer", "cavalry"]
var attack_timer = 0
var attacks = 1
var attacks_are = {
	"1" = {
		"time" = 0,
		"warrior" = 1,
		"archer" = 0,
		"cavalry" = 0
	},
	"2" = {
		"time" = 90,
		"warrior" = 1,
		"archer" = 0,
		"cavalry" = 0
	},
	"3" = {
		"time" = 120,
		"warrior" = 2,
		"archer" = 1,
		"cavalry" = 0
	},
	"4" = {
		"time" = 120,
		"warrior" = 0,
		"archer" = 0,
		"cavalry" = 3
	},
	"5" = {
		"time" = 30,
		"warrior" = 1,
		"archer" = 2,
		"cavalry" = 0
	},
	"6" = {
		"time" = 150,
		"warrior" = 2,
		"archer" = 2,
		"cavalry" = 2
	},
	"7" = {
		"time" = 90,
		"warrior" = 3,
		"archer" = 2,
		"cavalry" = 2
	},
	"8" = {
		"time" = 90,
		"warrior" = 4,
		"archer" = 0,
		"cavalry" = 4
	},
	"9" = {
		"time" = 75,
		"warrior" = 10,
		"archer" = 0,
		"cavalry" = 0
	},
	"10" = {
		"time" = 100,
		"warrior" = 5,
		"archer" = 5,
		"cavalry" = 5
	},
}
var currentlyattacking = {
	"warrior" = 0,
	"archer" = 0,
	"cavalry" = 0
}
var cameralimits = [-850, 1200, -650, 1000]
@onready var playerUI = $"C/1"

func _process(delta: float) -> void:
	if get_tree().get_node_count_in_group("1") == 0:
		var main_menu = load("res://main_menu.tscn")
		main_menu = main_menu.instantiate()
		get_parent().add_child(main_menu)
		queue_free()
	if get_tree().get_node_count_in_group("buildings") == 0:
		var main_menu = load("res://main_menu.tscn")
		main_menu = main_menu.instantiate()
		get_parent().add_child(main_menu)
		queue_free()
	$mission/mission.queue_redraw()
	attack_timer += delta
	for u in get_tree().get_nodes_in_group("2"):
		if u.type == "barracks":
			u.add_to_group("barracks")
			u.add_to_group("buildings")
		if u.type == "worker":
			u.add_to_group("gatherer")
		if u.type == "command centre":
			u.add_to_group("maker")
			u.add_to_group("buildings")
		if u.type == "warrior" and !u.get_groups().has("guardian"):
			u.add_to_group("army")
			u.add_to_group("warrior")
		if u.type == "archer" and !u.get_groups().has("guardian"):
			u.add_to_group("army")
			u.add_to_group("archer")
		if u.type == "cavalry" and !u.get_groups().has("guardian"):
			u.add_to_group("army")
			u.add_to_group("cavalry")
	for i in get_tree().get_nodes_in_group("barracks"):
		production(i)
	for i in get_tree().get_nodes_in_group("maker"):
		if i.queue.size() == 0 and get_tree().get_node_count_in_group("gatherer") < 4:
			i.what = "worker"
			i.mode = "creating"
	for i in get_tree().get_nodes_in_group("gatherer"):
		if i.mode == "idle":
			i.search_for_resourse()
	handle_attacking()
	handle_defence()
	for i in get_tree().get_nodes_in_group("attacking"):
		i.mode = "attack"
		i.target = find_closest(i)
		i.is_atacking_from_order = true
	

func find_closest(e):
	var all = get_tree().get_nodes_in_group("unit")
	var best = null
	for i in range(all.size()):
		var he = all[i]
		var is_friendly = false
		for u in he.get_groups():
			if allies["2"].has(u):
				is_friendly = true
		if !is_friendly:
			if best == null:
				best = he
			else:
				if e.global_position.distance_to(best.global_position) > e.global_position.distance_to(he.global_position):
					best = he
	if best != null:
		return best

func handle_defence():
	for i in get_tree().get_nodes_in_group("army"):
		if !i.is_in_group("guardian") and !i.is_in_group("attacking") and !i.is_in_group("ungardable"):
			if i.is_in_group("warrior"):
				if get_tree().get_node_count_in_group("guard1") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard1")
					i.remove_from_group("army")
				elif get_tree().get_node_count_in_group("guard2") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard2")
					i.remove_from_group("army")
				elif get_tree().get_node_count_in_group("guard3") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard3")
					i.remove_from_group("army")
				elif get_tree().get_node_count_in_group("guard4") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard4")
					i.remove_from_group("army")
			if i.is_in_group("archer"):
				if get_tree().get_node_count_in_group("guard5") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard5")
					i.remove_from_group("army")
				elif get_tree().get_node_count_in_group("guard6") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard6")
					i.remove_from_group("army")
				elif get_tree().get_node_count_in_group("guard7") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard7")
					i.remove_from_group("army")
			if i.is_in_group("cavalry"):
				if get_tree().get_node_count_in_group("guard8") == 0:
					i.add_to_group("guardian")
					i.add_to_group("guard8")
					i.remove_from_group("army")
	for i in get_tree().get_nodes_in_group("guardian"):
		if i.mode == "idle" and is_instance_valid(i):
			for u in range(8):
				if i.is_in_group("guard" + str(u+1)) and i.global_position.distance_to(defcords[u]) > 16:
					i.mode = "attack"
					i.target = defcords[u]
					i.is_atacking_from_order = true
		
func production(i):
	if i.queue.size() == 0:
		for u in attacks_are[str(attacks)].keys():
			if get_tree().get_node_count_in_group(u) < attacks_are[str(attacks)][u] + defence_force[u] and u != "time":
				i.mode = "creating"
				i.what = u
				return

func handle_attacking():
	if tutorial_phase < 10 and tutorial_phase != 5:
		tutorial()
		return
	elif tutorial_phase == 5 or tutorial_phase == 10:
		tutorial()
	if attack_timer >= attacks_are[str(attacks)]["time"]:
		attack_timer = 0
		if attacks != 1:
			playerUI.error(voicelines[2][0], 1)
		for i in attacks_are[str(attacks)].keys():
			if i != "time":
				for u in get_tree().get_nodes_in_group(i):
					if attacks_are[str(attacks)][i] > currentlyattacking[i] and !u.is_in_group("guardian"):
						u.add_to_group("attacking")
						currentlyattacking[i] += 1
			currentlyattacking[i] = 0
		attacks += 1
		if attacks == 11:
			attacks = 10

func tutorial():
	if tutorial_phase == 0:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut1").selected:
			tutorial_phase = 1
	elif tutorial_phase > 0:
		playerUI.available["UI_buttons"]["gather"] = true
		playerUI.available["UI_buttons"]["return"] = true
	if tutorial_phase == 1:
		$Camera.position = Vector2(530, 20)
		if playerUI.mode == "gather":
			tutorial_phase = 2
	if tutorial_phase == 2:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut1").mode == "gather":
			tutorial_phase = 3
	if tutorial_phase == 3:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut2").selected:
			tutorial_phase = 4
	elif tutorial_phase > 3:
		playerUI.available["UI_buttons"]["create worker"] = true
		playerUI.available["UI_buttons"]["cancel"] = true
	if tutorial_phase == 4:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut2").mode == "buy":
			tutorial_phase = 5
			return
	if tutorial_phase == 5:
		tutorial_phase = 6
		get_tree().get_first_node_in_group("tut2").selected = false
		get_tree().get_first_node_in_group("tut2").is_main = false
		get_tree().get_first_node_in_group("tut2").remove_from_group("selected")
		playerUI.refresh()
		await get_tree().process_frame
		playerUI.command()
	elif tutorial_phase > 5:
		playerUI.available["UI_buttons"]["attack"] = true
		playerUI.available["UI_buttons"]["move"] = true
		playerUI.available["UI_buttons"]["stop"] = true
		playerUI.available["UI_buttons"]["defend"] = true
	if tutorial_phase == 6:
		$Camera.position = Vector2(80, 530)
		if !is_instance_valid(get_tree().get_first_node_in_group("tut3")):
			tutorial_phase = 7
	if tutorial_phase == 7:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut4").selected:
			tutorial_phase = 8
	elif tutorial_phase > 7:
		playerUI.available["UI_buttons"]["build"] = true
	if tutorial_phase == 8:
		$Camera.position = Vector2(530, 20)
		if playerUI.build:
			tutorial_phase = 9
			await get_tree().process_frame
			await get_tree().process_frame
			playerUI.command()
	elif tutorial_phase > 8:
		playerUI.available["UI_buttons_build"]["build farm"] = true
	if tutorial_phase == 9:
		$Camera.position = Vector2(530, 20)
		if get_tree().get_first_node_in_group("tut4").mode == "building":
			tutorial_phase = 10
	if tutorial_phase == 10:
		objectify()
		if voicelines[0][1]:
			voicelines[0][1] = false
			playerUI.error(voicelines[0][0], 4)
		playerUI.available["UI_buttons"]["create warrior"] = true
		playerUI.available["UI_buttons"]["create archer"] = true
		playerUI.available["UI_buttons"]["create cavalry"] = true
		playerUI.available["UI_buttons"]["continue building"] = true
		playerUI.available["UI_buttons"]["rally"] = true
		playerUI.available["UI_buttons_build"]["build barracks"] = true
		playerUI.available["UI_buttons_build"]["build command centre"] = true
		playerUI.available["UI_buttons_build"]["build watchtower"] = true
	else:
		attack_timer = 0

func objectify():
	$mission/mission/skip.text = "close"
	var ob = $mission/mission/objective
	var o = objectives["objectives progress"]
	o[0][0] = get_tree().get_node_count_in_group("civilian")
	if o[1]:
		for i in get_tree().get_nodes_in_group("1"):
			if i.type == "barracks":
				o[1] = false
				playerUI.error(voicelines[3][0], 3)
	o[2][0] = playerUI.currentsupply
	if o[0][0] == 0 and !o[1] and !o[2][2]:
		o[3] = false
	ob.visible = true
	ob.text = "main objective:\n" + objectives["main"][0] 
	if o[2][0] >= o[2][1]:
		o[2][2] = false
	if o[3]:
		ob.text += "\nbonus objectives:"
		if o[0][0] > 0:
			ob.text += "\n" + objectives["bonus"][0] + str(o[0][0]) + "/" + str(o[0][1]) 
		if o[1]:
			ob.text += "\n" + objectives["bonus"][1]
		else:
			if o[2][0] < o[2][1] and o[2][2]:
				ob.text += "\n" + objectives["bonus"][2] + str(o[2][0]) + "/" + str(o[2][1]) 
				


func _on_skip_pressed() -> void:
	tutorial_phase = 10
	$mission/mission/skip.visible = false
	$mission/mission/tuttext.visible = false
	await get_tree().process_frame
	await get_tree().process_frame
	playerUI.command()


func _on_reinforcements_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("1"):
		$reinforcements.queue_free()
		for i in get_tree().get_nodes_in_group("reinforced"):
			i.side = 1
			i._ready()
		playerUI.error(voicelines[1][0], 2)
