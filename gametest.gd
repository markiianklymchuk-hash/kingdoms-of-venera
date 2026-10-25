extends Node2D
## Простий мобільний RTS в одній Node2D (Godot 4.2+).
## Нічого більше в сцені не потрібно: камера, UI, юніти, ШІ — все створюється кодом.
##
## КЕРУВАННЯ (тачскрін):
##   Тап по своєму юніту      -> вибрати
##   Тап по землі             -> рухати вибраних
##   Тап по ворогу            -> атакувати
##   Один палець тягнути      -> рух камери
##   Затиснути і тягнути      -> рамка виділення
##   Два пальці               -> масштаб (щипок) і рух камери
 
# ---------------- Налаштування ----------------
const MAP_SIZE := Vector2(3200, 2000)
const TAP_MAX_TIME := 0.35
const LONG_PRESS_TIME := 0.45
const DRAG_THRESHOLD := 12.0
const MAX_ARMY := 40
const COSTS := {"warrior": 50, "archer": 80, "cavalry": 90}
const ZOOM_MIN := 0.4
const ZOOM_MAX := 1.6
 
 
class Entity:
	var team := 0              # 0 = гравець, 1 = ворог
	var kind := "warrior"
	var pos := Vector2.ZERO
	var hp := 100.0
	var max_hp := 100.0
	var radius := 16.0
	var speed := 110.0
	var damage := 10.0
	var attack_range := 6.0
	var cooldown := 0.8
	var cd := 0.0
	var is_building := false
	var has_dest := false
	var dest := Vector2.ZERO
	var target: Entity = null
	var selected := false
	var flash := 0.0
 
 
# ---------------- Стан гри ----------------
var units: Array[Entity] = []
var player_base: Entity
var enemy_base: Entity
var gold := 200.0
var wave_timer := 20.0
var wave_size := 3
var game_over := false
var over_time := 0.0
 
var camera: Camera2D
 
# Дотики
var touches := {}        # index -> позиція на екрані
var touch_start := {}
var touch_time := {}
var touch_moved := {}
var ui_touches := {}
var multi_gesture := false
var box_selecting := false
var box_start := Vector2.ZERO
var box_end := Vector2.ZERO
var pinch_last_dist := 0.0
var pinch_last_mid := Vector2.ZERO
 
# Візуальні маркери
var marker_pos := Vector2.ZERO
var marker_t := 0.0
var marker_color := Color.WHITE
 
# UI
var gold_label: Label
var msg_label: Label
var msg_text := ""
var msg_time := 0.0
var ui_controls: Array[Control] = []
 
 
# =====================================================================
#  Ініціалізація
# =====================================================================
func _ready() -> void:
	randomize()
 
	camera = Camera2D.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(MAP_SIZE.x)
	camera.limit_bottom = int(MAP_SIZE.y)
	camera.zoom = Vector2(0.8, 0.8)
	add_child(camera)          # (Node2D має стояти в позиції 0,0)
	camera.make_current()
 
	_build_ui()
	_setup_world()
 
 
func _setup_world() -> void:
	player_base = _make_entity("base", 0, Vector2(300, MAP_SIZE.y * 0.5))
	enemy_base = _make_entity("base", 1, Vector2(MAP_SIZE.x - 300, MAP_SIZE.y * 0.5))
	units.append(player_base)
	units.append(enemy_base)
 
	for i in 4:
		units.append(_make_entity("warrior", 0, player_base.pos + Vector2(140, -90 + i * 60)))
	for i in 2:
		units.append(_make_entity("archer", 0, player_base.pos + Vector2(200, -30 + i * 60)))
	for i in 2:
		units.append(_make_entity("warrior", 1, enemy_base.pos + Vector2(-140, -30 + i * 60)))
 
	camera.position = player_base.pos + Vector2(250, 0)
	_clamp_camera()
 
 
func _make_entity(kind: String, team: int, p: Vector2) -> Entity:
	var e := Entity.new()
	e.kind = kind
	e.team = team
	e.pos = p
	match kind:
		"warrior":
			e.max_hp = 120.0
			e.speed = 110.0
			e.damage = 12.0
			e.attack_range = 6.0
			e.cooldown = 0.7
			e.radius = 16.0
		"cavalry":
			e.max_hp = 100.0
			e.speed = 230.0
			e.damage = 15.0
			e.attack_range = 6.0
			e.cooldown = 0.7
			e.radius = 22.0
		"archer":
			e.max_hp = 70.0
			e.speed = 125.0
			e.damage = 9.0
			e.attack_range = 170.0
			e.cooldown = 1.0
			e.radius = 13.0
		"base":
			e.is_building = true
			e.max_hp = 1500.0
			e.speed = 0.0
			e.damage = 10.0
			e.attack_range = 200.0
			e.cooldown = 1.1
			e.radius = 60.0
	e.hp = e.max_hp
	return e
 
 
# =====================================================================
#  UI (створюється кодом)
# =====================================================================
func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
 
	gold_label = Label.new()
	gold_label.position = Vector2(24, 12)
	gold_label.add_theme_font_size_override("font_size", 30)
	gold_label.add_theme_color_override("font_outline_color", Color.BLACK)
	gold_label.add_theme_constant_override("outline_size", 8)
	layer.add_child(gold_label)
 
	msg_label = Label.new()
	layer.add_child(msg_label)
	msg_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	msg_label.add_theme_font_size_override("font_size", 44)
	msg_label.add_theme_color_override("font_outline_color", Color.BLACK)
	msg_label.add_theme_constant_override("outline_size", 10)
 
	var box := HBoxContainer.new()
	layer.add_child(box)
	box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_left = 12
	box.offset_right = -12
	box.offset_top = -100
	box.offset_bottom = -12
	box.add_theme_constant_override("separation", 12)
 
	_add_button(box, "Воїн (%d)" % COSTS["warrior"], func(): _buy("warrior"))
	_add_button(box, "Вершник (%d)" % COSTS["cavalry"], func(): _buy("cavalry"))
	_add_button(box, "Лучник (%d)" % COSTS["archer"], func(): _buy("archer"))
	_add_button(box, "Вибрати всіх", _select_all)
	_add_button(box, "Зняти", _clear_selection)
 
 
func _add_button(parent: Control, text: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 26)
	b.pressed.connect(cb)
	parent.add_child(b)
	ui_controls.append(b)
 
 
func _over_ui(p: Vector2) -> bool:
	for c in ui_controls:
		if c.get_global_rect().has_point(p):
			return true
	return false
 
 
func _show_msg(text: String, seconds := 1.5) -> void:
	msg_text = text
	msg_time = seconds
 
 
func _update_ui() -> void:
	var army := 0
	var foes := 0
	for u in units:
		if u.is_building:
			continue
		if u.team == 0:
			army += 1
		else:
			foes += 1
	gold_label.text = "Золото: %d     Армія: %d/%d     Вороги: %d" % [int(gold), army, MAX_ARMY, foes]
 
	if game_over:
		return
	msg_label.text = msg_text if msg_time > 0.0 else ""
 
 
# =====================================================================
#  Дії гравця
# =====================================================================
func _buy(kind: String) -> void:
	if game_over:
		return
	var cost: int = COSTS[kind]
	if gold < cost:
		_show_msg("Не вистачає золота")
		return
	var army := 0
	for u in units:
		if u.team == 0 and not u.is_building:
			army += 1
	if army >= MAX_ARMY:
		_show_msg("Досягнуто ліміт армії")
		return
	gold -= cost
	var p := player_base.pos + Vector2(randf_range(80, 120), randf_range(-100, 100))
	units.append(_make_entity(kind, 0, p))
 
 
func _select_all() -> void:
	_clear_selection()
	for u in units:
		if u.team == 0 and not u.is_building:
			u.selected = true
 
 
func _clear_selection() -> void:
	for u in units:
		u.selected = false
 
 
func _selected_units() -> Array[Entity]:
	var out: Array[Entity] = []
	for u in units:
		if u.selected and u.team == 0 and u.hp > 0:
			out.append(u)
	return out
 
 
func _entity_at(p: Vector2) -> Entity:
	var best: Entity = null
	var best_d := 1e9
	var tolerance := 20.0 / camera.zoom.x     # зручно потрапляти пальцем
	for u in units:
		var d := u.pos.distance_to(p) - u.radius
		if d <= tolerance and d < best_d:
			best_d = d
			best = u
	return best
 
 
func _on_tap(p: Vector2) -> void:
	var hit := _entity_at(p)
	if hit != null and hit.team == 0 and not hit.is_building:
		_clear_selection()
		hit.selected = true
		return
 
	var sel := _selected_units()
	if sel.is_empty():
		return
 
	if hit != null and hit.team == 1:
		for u in sel:
			u.target = hit
			u.has_dest = false
		_set_marker(hit.pos, Color(1, 0.3, 0.3))
	else:
		_order_move(sel, p)
		_set_marker(p, Color(0.4, 1, 0.4))
 
 
func _order_move(sel: Array[Entity], p: Vector2) -> void:
	var n := sel.size()
	var cols := int(ceil(sqrt(float(n))))
	var rows := int(ceil(float(n) / cols))
	var spacing := 38.0
	for i in n:
		var col := i % cols
		var row := floori(float(i) / cols)
		var off := Vector2(col - (cols - 1) * 0.5, row - (rows - 1) * 0.5) * spacing
		var u := sel[i]
		u.dest = (p + off).clamp(Vector2(20, 20), MAP_SIZE - Vector2(20, 20))
		u.has_dest = true
		u.target = null
 
 
func _set_marker(p: Vector2, c: Color) -> void:
	marker_pos = p
	marker_color = c
	marker_t = 0.6
 
 
func _finish_box_select() -> void:
	var r := Rect2(box_start, Vector2.ZERO).expand(box_end)
	_clear_selection()
	for u in units:
		if u.team == 0 and not u.is_building and r.has_point(u.pos):
			u.selected = true
	box_selecting = false
 
 
# =====================================================================
#  Ввід: дотики
# =====================================================================
func _to_world(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos
 
 
func _clamp_camera() -> void:
	camera.position = camera.position.clamp(Vector2.ZERO, MAP_SIZE)
 
 
func _input(event: InputEvent) -> void:
	if game_over:
		if over_time > 1.0 and event is InputEventScreenTouch and event.pressed:
			get_tree().reload_current_scene()
		return
 
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)
 
 
func _on_touch(e: InputEventScreenTouch) -> void:
	if e.pressed:
		if _over_ui(e.position):
			ui_touches[e.index] = true
			return
		touches[e.index] = e.position
		touch_start[e.index] = e.position
		touch_time[e.index] = 0.0
		touch_moved[e.index] = false
		if touches.size() >= 2:
			multi_gesture = true
			box_selecting = false
			_reset_pinch()
	else:
		if ui_touches.has(e.index):
			ui_touches.erase(e.index)
			return
		if not touches.has(e.index):
			return
 
		var was_tap: bool = (not touch_moved[e.index]) \
			and touch_time[e.index] < TAP_MAX_TIME \
			and (not multi_gesture) and touches.size() == 1
 
		if box_selecting:
			_finish_box_select()
		elif was_tap:
			_on_tap(_to_world(e.position))
 
		touches.erase(e.index)
		touch_start.erase(e.index)
		touch_time.erase(e.index)
		touch_moved.erase(e.index)
		if touches.is_empty():
			multi_gesture = false
			box_selecting = false
		elif touches.size() >= 2:
			_reset_pinch()
 
 
func _on_drag(e: InputEventScreenDrag) -> void:
	if ui_touches.has(e.index) or not touches.has(e.index):
		return
	touches[e.index] = e.position
	var start: Vector2 = touch_start[e.index]
	if e.position.distance_to(start) > DRAG_THRESHOLD:
		touch_moved[e.index] = true
 
	if touches.size() == 1:
		if box_selecting:
			box_end = _to_world(e.position)
		elif touch_moved[e.index]:
			camera.position -= e.relative / camera.zoom
			_clamp_camera()
	else:
		var ks: Array = touches.keys()
		var p0: Vector2 = touches[ks[0]]
		var p1: Vector2 = touches[ks[1]]
		var dist := p0.distance_to(p1)
		var mid := (p0 + p1) * 0.5
		if pinch_last_dist > 1.0:
			var z := clampf(camera.zoom.x * dist / pinch_last_dist, ZOOM_MIN, ZOOM_MAX)
			camera.zoom = Vector2(z, z)
		camera.position -= (mid - pinch_last_mid) / camera.zoom
		_clamp_camera()
		pinch_last_dist = dist
		pinch_last_mid = mid
 
 
func _reset_pinch() -> void:
	var ks: Array = touches.keys()
	if ks.size() < 2:
		pinch_last_dist = 0.0
		return
	var p0: Vector2 = touches[ks[0]]
	var p1: Vector2 = touches[ks[1]]
	pinch_last_dist = p0.distance_to(p1)
	pinch_last_mid = (p0 + p1) * 0.5
 
 
func _tick_touches(delta: float) -> void:
	for idx in touch_time.keys():
		touch_time[idx] += delta
 
	# Довге утримання одним пальцем -> рамка виділення
	if touches.size() == 1 and not multi_gesture and not box_selecting:
		var idx = touches.keys()[0]
		if not touch_moved[idx] and touch_time[idx] >= LONG_PRESS_TIME:
			box_selecting = true
			box_start = _to_world(touches[idx])
			box_end = box_start
			Input.vibrate_handheld(25)
 
 
# =====================================================================
#  Основний цикл
# =====================================================================
func _process(delta: float) -> void:
	marker_t = maxf(0.0, marker_t - delta)
	msg_time = maxf(0.0, msg_time - delta)
	_tick_touches(delta)
 
	if not game_over:
		_update_economy(delta)
		for u in units:
			_update_unit(u, delta)
		_separate_units()
		_remove_dead()
		_check_game_over()
	else:
		over_time += delta
 
	_update_ui()
	queue_redraw()
 
 
func _update_economy(delta: float) -> void:
	gold += delta * 6.0
	wave_timer -= delta
	if wave_timer <= 0.0:
		wave_timer = 25.0
		for i in wave_size:
			var kind := "archer" if i % 3 == 2 else "warrior"
			var p := enemy_base.pos + Vector2(-100, randf_range(-90, 90))
			units.append(_make_entity(kind, 1, p))
		wave_size += 1
		_show_msg("Ворожа хвиля наближається!", 2.0)
 
 
func _edge_dist(a: Entity, b: Entity) -> float:
	return a.pos.distance_to(b.pos) - a.radius - b.radius
 
 
func _find_enemy(u: Entity, max_edge: float) -> Entity:
	var best: Entity = null
	var best_d := max_edge
	for o in units:
		if o.team == u.team or o.hp <= 0.0:
			continue
		var d := _edge_dist(u, o)
		if d < best_d:
			best_d = d
			best = o
	return best
 
 
func _update_unit(u: Entity, delta: float) -> void:
	u.cd = maxf(0.0, u.cd - delta)
	u.flash = maxf(0.0, u.flash - delta)
 
	if u.target != null and u.target.hp <= 0.0:
		u.target = null
 
	# Автоматичний пошук цілі
	if u.target == null and not u.has_dest:
		var sight := 1e9                       # вороги йдуть на найближчого гравця
		if u.is_building:
			sight = u.attack_range
		elif u.team == 0:
			sight = u.attack_range + 120.0
		u.target = _find_enemy(u, sight)
 
	if u.is_building:
		if u.target != null and _edge_dist(u, u.target) > u.attack_range:
			u.target = null
		_try_attack(u)
		return
 
	if u.target != null:
		if _edge_dist(u, u.target) <= u.attack_range:
			_try_attack(u)
		else:
			_move_toward(u, u.target.pos, delta)
	elif u.has_dest:
		_move_toward(u, u.dest, delta)
		if u.pos.distance_to(u.dest) < 6.0:
			u.has_dest = false
 
 
func _try_attack(u: Entity) -> void:
	if u.target == null or u.cd > 0.0:
		return
	u.cd = u.cooldown
	u.target.hp -= u.damage
	u.flash = 0.12
 
 
func _move_toward(u: Entity, to: Vector2, delta: float) -> void:
	var dir := to - u.pos
	var dist := dir.length()
	if dist < 1.0:
		return
	u.pos += dir / dist * minf(u.speed * delta, dist)
 
 
func _separate_units() -> void:
	var n := units.size()
	for i in n:
		var a := units[i]
		for j in range(i + 1, n):
			var b := units[j]
			if a.is_building and b.is_building:
				continue
			var diff := b.pos - a.pos
			var min_d := a.radius + b.radius
			var d := diff.length()
			if d >= min_d:
				continue
			if d < 0.001:
				diff = Vector2.RIGHT.rotated(randf() * TAU)
				d = 1.0
			var push := diff / d * (min_d - d) * 0.5
			if a.is_building:
				b.pos += push * 2.0
			elif b.is_building:
				a.pos -= push * 2.0
			else:
				a.pos -= push
				b.pos += push
	for u in units:
		if not u.is_building:
			u.pos = u.pos.clamp(Vector2(20, 20), MAP_SIZE - Vector2(20, 20))
 
 
func _remove_dead() -> void:
	for i in range(units.size() - 1, -1, -1):
		if units[i].hp <= 0.0:
			units.remove_at(i)
 
 
func _check_game_over() -> void:
	if enemy_base.hp <= 0.0:
		game_over = true
		msg_label.text = "ПЕРЕМОГА!\nТоркнись, щоб почати знову"
	elif player_base.hp <= 0.0:
		game_over = true
		msg_label.text = "ПОРАЗКА\nТоркнись, щоб почати знову"
 
 
# =====================================================================
#  Малювання
# =====================================================================
func _draw() -> void:
	# Земля та сітка
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(0.16, 0.28, 0.17))
	var grid := Color(1, 1, 1, 0.05)
	for x in range(0, int(MAP_SIZE.x) + 1, 100):
		draw_line(Vector2(x, 0), Vector2(x, MAP_SIZE.y), grid, 1.0)
	for y in range(0, int(MAP_SIZE.y) + 1, 100):
		draw_line(Vector2(0, y), Vector2(MAP_SIZE.x, y), grid, 1.0)
	draw_rect(Rect2(Vector2.ZERO, MAP_SIZE), Color(1, 1, 1, 0.5), false, 6.0)
 
	# Спершу будівлі, потім юніти зверху
	for u in units:
		if u.is_building:
			_draw_entity(u)
	for u in units:
		if not u.is_building:
			_draw_entity(u)
 
	# Маркер наказу
	if marker_t > 0.0:
		var k := marker_t / 0.6
		var c := marker_color
		c.a = k
		draw_arc(marker_pos, 14.0 + (1.0 - k) * 30.0, 0.0, TAU, 24, c, 3.0)
 
	# Рамка виділення
	if box_selecting:
		var r := Rect2(box_start, Vector2.ZERO).expand(box_end)
		draw_rect(r, Color(1, 1, 1, 0.15))
		draw_rect(r, Color(1, 1, 1, 0.9), false, 2.0 / camera.zoom.x)
 
 
func _draw_entity(u: Entity) -> void:
	var col := Color(0.25, 0.55, 1.0) if u.team == 0 else Color(0.95, 0.3, 0.3)
 
	if u.is_building:
		var s := Vector2(u.radius, u.radius)
		var rect := Rect2(u.pos - s, s * 2.0)
		draw_rect(rect, col.darkened(0.35))
		draw_rect(rect, col, false, 4.0)
	else:
		draw_circle(u.pos, u.radius, col)
		if u.kind == "archer":
			draw_circle(u.pos, u.radius * 0.45, Color(1, 1, 0.6))
		else:
			draw_arc(u.pos, u.radius, 0.0, TAU, 24, Color(0, 0, 0, 0.6), 2.0)
 
	if u.selected:
		draw_arc(u.pos, u.radius + 6.0, 0.0, TAU, 32, Color(0.4, 1, 0.4), 3.0)
 
	if u.hp < u.max_hp or u.is_building or u.selected:
		var w := u.radius * 2.0
		var top := u.pos + Vector2(-u.radius, -u.radius - 14.0)
		var ratio := clampf(u.hp / u.max_hp, 0.0, 1.0)
		draw_rect(Rect2(top, Vector2(w, 5)), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(top, Vector2(w * ratio, 5)), Color(1.0 - ratio, ratio, 0.2))
 
	if u.flash > 0.0 and u.target != null:
		draw_line(u.pos, u.target.pos, Color(1, 0.9, 0.4), 2.0)
