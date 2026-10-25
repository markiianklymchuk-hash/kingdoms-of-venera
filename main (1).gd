extends Node2D
## ============================================================
##  МІНІ-RTS ДЛЯ ТЕЛЕФОНА  |  Godot 4.x  |  ОДИН Node2D
## ============================================================
##  Жодних дочірніх нод, сцен, текстур чи шрифтів: все створюється
##  кодом і малюється через _draw().
##
##  ЯК ЗАПУСТИТИ
##  1) Нова сцена -> кореневий Node2D (єдина нода) -> прикріпи цей скрипт.
##  2) Project Settings -> Display -> Window:
##       Viewport Width/Height = 1280 x 720
##       Stretch Mode = canvas_items, Aspect = expand
##       Handheld -> Orientation = Landscape
##  3) Export -> Android / iOS.  На ПК грається мишею (дотик емулюється).
##
##  КЕРУВАННЯ (дотик)
##   • Тап по своєму юніту/будівлі  -> вибрати (подвійний тап = усі такі ж на екрані)
##   • Тап по землі                 -> рух вибраних (строєм)
##   • Тап по ворогу                -> атака
##   • Тап по шахті (робітники)     -> видобуток золота
##   • Тап по недобудові (робітник) -> добудувати
##   • Один палець тягнути          -> рух камери
##   • Два пальці                   -> зум + рух камери
##   • Кнопка "Рамка"               -> тягнути пальцем = виділення рамкою
##   • Міні-карта                   -> тап/тягнути = перейти камерою
##  ПК: колесо миші = зум, WASD/стрілки = камера.
##
##  МЕТА: знищити ворожий Штаб. Береги свій!
## ============================================================

# ───────────────────────── Налаштування ─────────────────────────
const MAP := Vector2(2400, 1600)
const MAX_UNITS := 50
const AI_INCOME := 0.65      # множник доходу ворога (складність: 1.0 = як у гравця)
const AI_FIRST_WAVE := 180.0 # секунд до першої атаки ворога
const TEAM_PLAYER := 0
const TEAM_ENEMY := 1

enum { S_IDLE, S_MOVE, S_AMOVE, S_ATTACK, S_GATHER, S_RETURN, S_BUILD }
enum { G_PLAY, G_WIN, G_LOSE }

const UNIT_DEF := {
	"worker":  {"name": "Робітник",   "hp": 40.0, "speed": 105.0, "r": 10.0, "dmg": 3.0,  "range": 14.0,  "cd": 1.0, "cost": 50,  "time": 5.0},
	"soldier": {"name": "Піхотинець", "hp": 95.0, "speed": 90.0,  "r": 11.0, "dmg": 11.0, "range": 16.0,  "cd": 0.9, "cost": 100, "time": 7.0},
	"archer":  {"name": "Лучник",     "hp": 55.0, "speed": 95.0,  "r": 10.0, "dmg": 8.0,  "range": 150.0, "cd": 1.1, "cost": 120, "time": 8.0},
}
const BUILD_DEF := {
	"base":     {"name": "Штаб",    "hp": 900.0, "r": 50.0, "cost": 0,   "time": 1.0},
	"barracks": {"name": "Казарма", "hp": 450.0, "r": 38.0, "cost": 150, "time": 14.0},
}
const TRAINS := {
	"base": ["worker"],
	"barracks": ["soldier", "archer"],
}

# ───────────────────────── Класи даних ─────────────────────────
class Unit:
	var team := 0
	var type := "worker"
	var pos := Vector2.ZERO
	var hp := 1.0
	var max_hp := 1.0
	var speed := 100.0
	var r := 10.0
	var dmg := 1.0
	var rng := 10.0
	var cd := 1.0
	var cd_t := 0.0
	var state := 0
	var target = null
	var dest := Vector2.ZERO
	var amove := false
	var selected := false
	var carry := 0
	var gather_t := 0.0
	var mine = null
	var face := Vector2.RIGHT
	var scan_t := 0.0

class Building:
	var team := 0
	var type := "base"
	var pos := Vector2.ZERO
	var hp := 1.0
	var max_hp := 1.0
	var r := 40.0
	var done := true
	var progress := 1.0
	var build_time := 1.0
	var queue: Array = []
	var prod_t := 0.0
	var selected := false

class Mine:
	var pos := Vector2.ZERO
	var r := 26.0
	var gold := 1500

class Rock:
	var pos := Vector2.ZERO
	var r := 20.0

# ───────────────────────── Стан гри ─────────────────────────
var units: Array = []
var buildings: Array = []
var mines: Array = []
var rocks: Array = []
var obstacles: Array = []
var fx: Array = []
var gold := [250, 250]
var ucount := [0, 0]
var game := G_PLAY
var time_s := 0.0

var sel_units: Array = []
var sel_building = null
var place_type := ""
var ghost_pos := Vector2.ZERO
var box_mode := false

var cam := Vector2(400, 1200)
var zoom := 0.9

var touches := {}
var pinch_mid := Vector2.ZERO
var pinch_dist := 0.0
var last_tap_ms := 0
var last_tap_hit = null

var buttons: Array = []
var mm_rect := Rect2()
var ui_s := 1.0
var msg := ""
var msg_t := 0.0

var team_col := [Color(0.3, 0.6, 1.0), Color(1.0, 0.35, 0.3)]
var ai_t := 0.0
var wave_size := 6


# ───────────────────────── Ініціалізація ─────────────────────────
func _ready() -> void:
	Input.emulate_touch_from_mouse = true   # на ПК миша = палець
	Input.emulate_mouse_from_touch = false  # без дублювання подій на телефоні
	randomize()
	_new_game()


func _new_game() -> void:
	units.clear()
	buildings.clear()
	mines.clear()
	rocks.clear()
	fx.clear()
	touches.clear()
	sel_units.clear()
	sel_building = null
	place_type = ""
	box_mode = false
	gold = [250, 250]
	game = G_PLAY
	time_s = 0.0
	ai_t = 2.0
	wave_size = 6

	var pb := _add_building(TEAM_PLAYER, "base", Vector2(380, 1200), true)
	var eb := _add_building(TEAM_ENEMY, "base", MAP - Vector2(380, 1200), true)

	var mine_spots := [
		Vector2(560, 1120), Vector2(290, 1020),
		MAP - Vector2(560, 1120), MAP - Vector2(290, 1020),
		Vector2(1050, 450), MAP - Vector2(1050, 450),
	]
	for p in mine_spots:
		var m := Mine.new()
		m.pos = p
		mines.append(m)

	var gen := RandomNumberGenerator.new()
	gen.seed = 777
	var tries := 0
	while rocks.size() < 34 and tries < 400:
		tries += 1
		var p := Vector2(gen.randf_range(80, MAP.x - 80), gen.randf_range(80, MAP.y - 80))
		var rr := gen.randf_range(16.0, 32.0)
		if p.distance_to(pb.pos) < 190.0 or p.distance_to(eb.pos) < 190.0:
			continue
		var ok := true
		for m in mines:
			if p.distance_to(m.pos) < 90.0 + rr:
				ok = false
		for o in rocks:
			if p.distance_to(o.pos) < 70.0 + rr:
				ok = false
		if ok:
			var rock := Rock.new()
			rock.pos = p
			rock.r = rr
			rocks.append(rock)

	for i in 4:
		var wp := _add_unit(TEAM_PLAYER, "worker", pb.pos + Vector2(-50 + i * 30, 70))
		_start_gather(wp)
		var we := _add_unit(TEAM_ENEMY, "worker", eb.pos + Vector2(-50 + i * 30, -70))
		_start_gather(we)
	_add_unit(TEAM_PLAYER, "soldier", pb.pos + Vector2(90, 40))
	_add_unit(TEAM_PLAYER, "soldier", pb.pos + Vector2(90, -10))

	cam = pb.pos
	zoom = maxf(0.9, _zmin())
	_rebuild_obstacles()
	_layout_ui()
	_clamp_cam()


func _add_unit(team: int, type: String, p: Vector2) -> Unit:
	var d: Dictionary = UNIT_DEF[type]
	var u := Unit.new()
	u.team = team
	u.type = type
	u.pos = p
	u.max_hp = d["hp"]
	u.hp = u.max_hp
	u.speed = d["speed"]
	u.r = d["r"]
	u.dmg = d["dmg"]
	u.rng = d["range"]
	u.cd = d["cd"]
	u.scan_t = randf() * 0.3
	units.append(u)
	return u


func _add_building(team: int, type: String, p: Vector2, done: bool) -> Building:
	var d: Dictionary = BUILD_DEF[type]
	var b := Building.new()
	b.team = team
	b.type = type
	b.pos = p
	b.r = d["r"]
	b.max_hp = d["hp"]
	b.build_time = d["time"]
	b.done = done
	b.progress = 1.0 if done else 0.0
	b.hp = b.max_hp if done else b.max_hp * 0.1
	buildings.append(b)
	return b


func _start_gather(u: Unit) -> void:
	u.mine = _nearest_mine(u.pos)
	u.state = S_GATHER if u.mine != null else S_IDLE


# ───────────────────────── Головний цикл ─────────────────────────
func _process(delta: float) -> void:
	delta = minf(delta, 0.05)
	_handle_keys(delta)
	_layout_ui()
	if game == G_PLAY:
		time_s += delta
		ucount = [0, 0]
		for u in units:
			if u.hp > 0:
				ucount[u.team] += 1
		_rebuild_obstacles()
		for u in units:
			_update_unit(u, delta)
		_separate_units()
		for b in buildings:
			_update_building(b, delta)
		_ai(delta)
		_cleanup()
		if _find_building(TEAM_PLAYER, "base") == null:
			game = G_LOSE
		elif _find_building(TEAM_ENEMY, "base") == null:
			game = G_WIN
	for f in fx:
		f["t"] -= delta
	fx = fx.filter(func(f): return f["t"] > 0.0)
	if msg_t > 0.0:
		msg_t -= delta
	queue_redraw()


func _handle_keys(delta: float) -> void:
	var v := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A): v.x -= 1.0
	if Input.is_key_pressed(KEY_D): v.x += 1.0
	if Input.is_key_pressed(KEY_W): v.y -= 1.0
	if Input.is_key_pressed(KEY_S): v.y += 1.0
	if v != Vector2.ZERO:
		cam += v.limit_length(1.0) * 700.0 * delta / zoom
		_clamp_cam()


func _rebuild_obstacles() -> void:
	obstacles.clear()
	obstacles.append_array(rocks)
	for m in mines:
		if m.gold > 0:
			obstacles.append(m)
	for b in buildings:
		if b.hp > 0:
			obstacles.append(b)


func _cleanup() -> void:
	units = units.filter(func(u): return u.hp > 0)
	buildings = buildings.filter(func(b): return b.hp > 0)
	mines = mines.filter(func(m): return m.gold > 0)
	sel_units = sel_units.filter(func(u): return u.hp > 0)
	if sel_building != null and sel_building.hp <= 0:
		sel_building = null


# ───────────────────────── Логіка юнітів ─────────────────────────
func _valid(t) -> bool:
	if t == null:
		return false
	if t is Mine:
		return t.gold > 0
	return t.hp > 0


func _edge(u: Unit, t) -> float:
	return u.pos.distance_to(t.pos) - t.r - u.r


func _update_unit(u: Unit, dt: float) -> void:
	if u.hp <= 0:
		return
	u.cd_t = maxf(0.0, u.cd_t - dt)
	u.scan_t -= dt
	match u.state:
		S_IDLE:
			if u.type != "worker" and u.scan_t <= 0.0:
				u.scan_t = 0.3
				var t = _find_enemy(u, 220.0)
				if t != null:
					u.target = t
					u.state = S_ATTACK
		S_MOVE:
			if _walk(u, u.dest, dt, 4.0):
				u.state = S_IDLE
		S_AMOVE:
			if u.scan_t <= 0.0:
				u.scan_t = 0.25
				var t = _find_enemy(u, 240.0)
				if t != null:
					u.target = t
					u.state = S_ATTACK
			if u.state == S_AMOVE and _walk(u, u.dest, dt, 8.0):
				u.state = S_IDLE
				u.amove = false
		S_ATTACK:
			var t = u.target
			if not _valid(t) or t is Mine or t.team == u.team:
				u.target = null
				u.state = S_AMOVE if u.amove else S_IDLE
				return
			# якщо б'ємо будівлю, а поруч з'явився ворожий юніт - перемикаємось
			if t is Building and u.scan_t <= 0.0:
				u.scan_t = 0.5
				var t2 = _find_enemy(u, 200.0, true)
				if t2 != null:
					u.target = t2
					t = t2
			if _edge(u, t) <= u.rng:
				u.face = (t.pos - u.pos).normalized()
				if u.cd_t <= 0.0:
					u.cd_t = u.cd
					_hit(u, t)
			else:
				_walk(u, t.pos, dt, 0.0)
		S_GATHER:
			if not _valid(u.mine):
				u.mine = _nearest_mine(u.pos)
				if u.mine == null:
					u.state = S_IDLE
					return
			var m = u.mine
			if _edge(u, m) > 8.0:
				_walk(u, m.pos, dt, 0.0)
			else:
				u.gather_t += dt
				if u.gather_t >= 2.0:
					u.gather_t = 0.0
					var amt: int = mini(10, m.gold)
					m.gold -= amt
					u.carry = amt
					u.state = S_RETURN
		S_RETURN:
			var b = _closest_building(u.team, u.pos, "base")
			if b == null:
				u.state = S_IDLE
			elif _edge(u, b) > 8.0:
				_walk(u, b.pos, dt, 0.0)
			else:
				gold[u.team] += int(round(u.carry * (AI_INCOME if u.team == TEAM_ENEMY else 1.0)))
				u.carry = 0
				u.state = S_GATHER
		S_BUILD:
			var b = u.target
			if not (b is Building) or not _valid(b) or b.done:
				u.target = null
				_start_gather(u)
			elif _edge(u, b) > 10.0:
				_walk(u, b.pos, dt, 0.0)
			else:
				b.progress += dt / b.build_time
				b.hp = minf(b.max_hp, b.hp + b.max_hp * 0.9 * dt / b.build_time)
				if b.progress >= 1.0:
					b.progress = 1.0
					b.done = true


## Рух до точки з обходом перешкод. true = прибув.
func _walk(u: Unit, p: Vector2, dt: float, stop: float) -> bool:
	var d := p - u.pos
	var l := d.length()
	if l <= stop:
		return true
	var dir := d / l
	u.face = dir
	var step := minf(u.speed * dt, l)
	var np := u.pos + dir * step
	for o in obstacles:
		var minr: float = o.r + u.r
		var dd: Vector2 = np - o.pos
		var dl := dd.length()
		if dl < minr:
			var n := dd / maxf(dl, 0.001)
			var tg := Vector2(-n.y, n.x)
			if tg.dot(dir) < 0.0:
				tg = -tg
			np = o.pos + n * minr + tg * step * 0.5
	np.x = clampf(np.x, u.r, MAP.x - u.r)
	np.y = clampf(np.y, u.r, MAP.y - u.r)
	u.pos = np
	return false


func _hit(u: Unit, t) -> void:
	t.hp -= u.dmg
	if u.rng > 40.0:
		fx.append({"k": "line", "a": u.pos, "b": t.pos, "t": 0.12, "t0": 0.12, "c": Color(1, 1, 0.6)})
	else:
		fx.append({"k": "hit", "a": t.pos, "b": t.pos, "t": 0.1, "t0": 0.1, "c": Color(1, 1, 1)})
	if t is Unit and t.state == S_IDLE and t.type != "worker":
		t.target = u
		t.state = S_ATTACK


func _find_enemy(u: Unit, radius: float, units_only := false):
	var best = null
	var bd := radius * radius
	for o in units:
		if o.team == u.team or o.hp <= 0:
			continue
		var d := u.pos.distance_squared_to(o.pos)
		if d < bd:
			bd = d
			best = o
	if best != null or units_only:
		return best
	var bd2 := radius
	for b in buildings:
		if b.team == u.team or b.hp <= 0:
			continue
		var d2: float = u.pos.distance_to(b.pos) - b.r
		if d2 < bd2:
			bd2 = d2
			best = b
	return best


func _nearest_mine(p: Vector2):
	var best = null
	var bd := INF
	for m in mines:
		if m.gold <= 0:
			continue
		var d := p.distance_squared_to(m.pos)
		if d < bd:
			bd = d
			best = m
	return best


func _closest_building(team: int, p: Vector2, type := ""):
	var best = null
	var bd := INF
	for b in buildings:
		if b.team != team or b.hp <= 0 or not b.done and type != "":
			continue
		if type != "" and b.type != type:
			continue
		var d := p.distance_squared_to(b.pos)
		if d < bd:
			bd = d
			best = b
	return best


func _find_building(team: int, type: String):
	for b in buildings:
		if b.team == team and b.type == type and b.hp > 0:
			return b
	return null


## М'яке розштовхування юнітів + виштовхування з перешкод.
func _separate_units() -> void:
	var n := units.size()
	for i in n:
		var a: Unit = units[i]
		if a.hp <= 0:
			continue
		for j in range(i + 1, n):
			var b: Unit = units[j]
			if b.hp <= 0:
				continue
			var d := b.pos - a.pos
			var minr := a.r + b.r
			if absf(d.x) > minr or absf(d.y) > minr:
				continue
			var l := d.length()
			if l < minr:
				var dir := d / l if l > 0.01 else Vector2.from_angle(randf() * TAU)
				var push := dir * (minr - l) * 0.5
				a.pos -= push
				b.pos += push
	for u in units:
		for o in obstacles:
			var minr: float = o.r + u.r
			var dd: Vector2 = u.pos - o.pos
			var dl := dd.length()
			if dl < minr:
				u.pos = o.pos + dd / maxf(dl, 0.001) * minr
		u.pos.x = clampf(u.pos.x, u.r, MAP.x - u.r)
		u.pos.y = clampf(u.pos.y, u.r, MAP.y - u.r)


# ───────────────────────── Будівлі й виробництво ─────────────────────────
func _update_building(b: Building, dt: float) -> void:
	if not b.done or b.hp <= 0 or b.queue.is_empty():
		return
	if ucount[b.team] >= MAX_UNITS:
		return
	b.prod_t += dt
	var t: String = b.queue[0]
	if b.prod_t >= UNIT_DEF[t]["time"]:
		b.prod_t = 0.0
		b.queue.pop_front()
		var p := b.pos + Vector2.from_angle(randf() * TAU) * (b.r + 22.0)
		var u := _add_unit(b.team, t, p)
		ucount[b.team] += 1
		if t == "worker":
			_start_gather(u)


func _train(team: int, b: Building, type: String, silent := false) -> bool:
	var cost: int = UNIT_DEF[type]["cost"]
	var err := ""
	if not b.done or b.hp <= 0:
		err = "Будівля ще не готова"
	elif b.queue.size() >= 5:
		err = "Черга повна"
	elif ucount[team] + b.queue.size() >= MAX_UNITS:
		err = "Ліміт війська"
	elif gold[team] < cost:
		err = "Не вистачає золота"
	if err != "":
		if not silent:
			_toast(err)
		return false
	gold[team] -= cost
	b.queue.append(type)
	return true


func _can_place(p: Vector2, r: float) -> bool:
	var m := r + 20.0
	if p.x < m or p.y < m or p.x > MAP.x - m or p.y > MAP.y - m:
		return false
	for o in obstacles:
		if p.distance_to(o.pos) < o.r + r + 10.0:
			return false
	return true


func _try_place(wp: Vector2) -> void:
	var def: Dictionary = BUILD_DEF[place_type]
	var ws := _sel_workers()
	if ws.is_empty():
		_toast("Вибери робітника")
		place_type = ""
		return
	if gold[TEAM_PLAYER] < def["cost"]:
		_toast("Не вистачає золота")
		place_type = ""
		return
	if not _can_place(wp, def["r"]):
		_toast("Тут не можна будувати")
		return
	gold[TEAM_PLAYER] -= def["cost"]
	var b := _add_building(TEAM_PLAYER, place_type, wp, false)
	_rebuild_obstacles()
	for w in ws:
		w.target = b
		w.state = S_BUILD
		w.amove = false
	place_type = ""


# ───────────────────────── Ворожий ШІ ─────────────────────────
func _ai(dt: float) -> void:
	ai_t -= dt
	if ai_t > 0.0:
		return
	ai_t = 1.0
	var T := TEAM_ENEMY
	var base = _find_building(T, "base")
	if base == null:
		return
	var workers: Array = []
	var idle_army: Array = []
	for u in units:
		if u.team != T or u.hp <= 0:
			continue
		if u.type == "worker":
			workers.append(u)
		elif u.state == S_IDLE:
			idle_army.append(u)
	var bars: Array = []
	for b in buildings:
		if b.team == T and b.hp > 0 and b.type == "barracks":
			bars.append(b)

	# економіка
	if workers.size() + base.queue.size() < 6:
		_train(T, base, "worker", true)

	# казарми
	var want := 1
	if time_s > 120.0:
		want = 2
	if time_s > 300.0:
		want = 3
	var cost: int = BUILD_DEF["barracks"]["cost"]
	if bars.size() < want and gold[T] >= cost and workers.size() >= 3:
		var spot = null
		for i in 30:
			var p: Vector2 = base.pos + Vector2.from_angle(randf() * TAU) * randf_range(130.0, 280.0)
			if _can_place(p, BUILD_DEF["barracks"]["r"]):
				spot = p
				break
		if spot != null:
			gold[T] -= cost
			var nb := _add_building(T, "barracks", spot, false)
			_rebuild_obstacles()
			var n := 0
			for w in workers:
				if w.state != S_BUILD and n < 2:
					w.target = nb
					w.state = S_BUILD
					n += 1

	# армія
	for b in bars:
		if b.done and b.queue.size() < 2:
			_train(T, b, "soldier" if randf() < 0.6 else "archer", true)

	# атака хвилями
	if time_s > AI_FIRST_WAVE and idle_army.size() >= wave_size:
		var tgt = _closest_building(TEAM_PLAYER, base.pos)
		if tgt != null:
			for u in idle_army:
				u.dest = tgt.pos
				u.amove = true
				u.state = S_AMOVE
			wave_size = mini(wave_size + 2, 25)


# ───────────────────────── Ввід (дотик) ─────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_down(event.index, event.position)
		else:
			_touch_up(event.index, event.position)
	elif event is InputEventScreenDrag:
		_touch_drag(event.index, event.position, event.relative)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, 1.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, 1.0 / 1.1)


func _touch_down(idx: int, pos: Vector2) -> void:
	if game != G_PLAY:
		if _button_at(pos) == "restart":
			_new_game()
		return
	var t := {"s": pos, "p": pos, "mode": "world", "moved": false, "btn": ""}
	if touches.size() >= 1:
		for k in touches:
			touches[k]["mode"] = "gesture"
		t["mode"] = "gesture"
		touches[idx] = t
		_pinch_reset()
		return
	var bt := _button_at(pos)
	if bt != "":
		t["mode"] = "hud"
		t["btn"] = bt
	elif mm_rect.has_point(pos):
		t["mode"] = "minimap"
		_mm_goto(pos)
	elif place_type != "":
		ghost_pos = _s2w(pos + Vector2(0, -70.0 * ui_s))
	touches[idx] = t


func _touch_drag(idx: int, pos: Vector2, rel: Vector2) -> void:
	if not touches.has(idx):
		return
	var t: Dictionary = touches[idx]
	t["p"] = pos
	if pos.distance_to(t["s"]) > 14.0:
		t["moved"] = true
	if touches.size() >= 2:
		_pinch_update()
		return
	match t["mode"]:
		"minimap":
			_mm_goto(pos)
		"world":
			if place_type != "":
				ghost_pos = _s2w(pos + Vector2(0, -70.0 * ui_s))
			elif not box_mode and t["moved"]:
				cam -= rel / zoom
				_clamp_cam()


func _touch_up(idx: int, pos: Vector2) -> void:
	if game != G_PLAY or not touches.has(idx):
		return
	var t: Dictionary = touches[idx]
	touches.erase(idx)
	match t["mode"]:
		"hud":
			if _button_at(pos) == t["btn"]:
				_press(t["btn"])
		"world":
			if place_type != "":
				ghost_pos = _s2w(pos + Vector2(0, -70.0 * ui_s))
				_try_place(ghost_pos)
			elif t["moved"]:
				if box_mode:
					_box_select(t["s"], pos)
			else:
				_tap(pos)
	if touches.size() >= 2:
		_pinch_reset()


func _pinch_state() -> Array:
	var keys := touches.keys()
	var a: Vector2 = touches[keys[0]]["p"]
	var b: Vector2 = touches[keys[1]]["p"]
	return [(a + b) * 0.5, a.distance_to(b)]


func _pinch_reset() -> void:
	if touches.size() < 2:
		return
	var st := _pinch_state()
	pinch_mid = st[0]
	pinch_dist = st[1]


func _pinch_update() -> void:
	var st := _pinch_state()
	var mid: Vector2 = st[0]
	var dist: float = st[1]
	var w_last := _s2w(pinch_mid)
	if pinch_dist > 10.0:
		zoom = clampf(zoom * dist / pinch_dist, _zmin(), 2.0)
	cam = w_last - (mid - get_viewport_rect().size * 0.5) / zoom
	_clamp_cam()
	pinch_mid = mid
	pinch_dist = dist


func _zoom_at(sp: Vector2, f: float) -> void:
	var w := _s2w(sp)
	zoom = clampf(zoom * f, _zmin(), 2.0)
	cam = w - (sp - get_viewport_rect().size * 0.5) / zoom
	_clamp_cam()


# ───────────────────────── Камера ─────────────────────────
func _zmin() -> float:
	var vp := get_viewport_rect().size
	return maxf(vp.x / MAP.x, vp.y / MAP.y)


func _clamp_cam() -> void:
	var vp := get_viewport_rect().size
	zoom = clampf(zoom, _zmin(), 2.0)
	var half := vp * 0.5 / zoom
	cam.x = clampf(cam.x, half.x, MAP.x - half.x)
	cam.y = clampf(cam.y, half.y, MAP.y - half.y)


func _s2w(sp: Vector2) -> Vector2:
	return (sp - get_viewport_rect().size * 0.5) / zoom + cam


func _view_rect() -> Rect2:
	var half := get_viewport_rect().size * 0.5 / zoom
	return Rect2(cam - half, half * 2.0)


func _mm_goto(pos: Vector2) -> void:
	cam = (pos - mm_rect.position) / (mm_rect.size / MAP)
	_clamp_cam()


# ───────────────────────── Вибір і команди ─────────────────────────
func _clear_selection() -> void:
	for u in sel_units:
		u.selected = false
	sel_units.clear()
	if sel_building != null:
		sel_building.selected = false
	sel_building = null


func _select_units(list: Array) -> void:
	_clear_selection()
	for u in list:
		u.selected = true
		sel_units.append(u)


func _sel_workers() -> Array:
	return sel_units.filter(func(u): return u.type == "worker")


func _pick(p: Vector2):
	var tol := 14.0 / zoom
	var best = null
	var bd := INF
	for u in units:
		if u.hp <= 0:
			continue
		var d: float = u.pos.distance_to(p) - u.r
		if d < tol and d < bd:
			bd = d
			best = u
	if best != null:
		return best
	for b in buildings:
		var h: float = b.r * 0.72 + 4.0
		if b.hp > 0 and absf(p.x - b.pos.x) <= h and absf(p.y - b.pos.y) <= h:
			return b
	for m in mines:
		if m.gold > 0 and p.distance_to(m.pos) <= m.r + 6.0:
			return m
	return null


func _tap(sp: Vector2) -> void:
	var wp := _s2w(sp)
	var hit = _pick(wp)
	var now := Time.get_ticks_msec()
	if hit is Unit and hit.team == TEAM_PLAYER:
		if last_tap_hit == hit and now - last_tap_ms < 350:
			var view := _view_rect()
			var tp: String = hit.type
			_select_units(units.filter(func(u): return u.team == TEAM_PLAYER and u.hp > 0 and u.type == tp and view.has_point(u.pos)))
		else:
			_select_units([hit])
		last_tap_hit = hit
		last_tap_ms = now
		return
	last_tap_hit = null
	if hit is Building:
		if hit.team == TEAM_PLAYER:
			var ws := _sel_workers()
			if not hit.done and not ws.is_empty():
				for w in ws:
					w.target = hit
					w.state = S_BUILD
					w.amove = false
				_ping(hit.pos, Color(0.4, 1, 0.4))
			else:
				_clear_selection()
				hit.selected = true
				sel_building = hit
			return
		if not sel_units.is_empty():
			_cmd_attack(hit)
			return
	elif hit is Unit:
		if not sel_units.is_empty():
			_cmd_attack(hit)
			return
	elif hit is Mine:
		if not sel_units.is_empty():
			_cmd_gather(hit)
			return
	if not sel_units.is_empty():
		_cmd_move(wp)
	else:
		_clear_selection()


func _box_select(a: Vector2, b: Vector2) -> void:
	var r := Rect2(_s2w(a), Vector2.ZERO).expand(_s2w(b))
	var list := units.filter(func(u): return u.team == TEAM_PLAYER and u.hp > 0 and r.has_point(u.pos))
	if not list.is_empty():
		_select_units(list)


func _cmd_move(wp: Vector2) -> void:
	var n := sel_units.size()
	var cols := maxi(1, int(ceil(sqrt(float(n)))))
	var rows := int(ceil(float(n) / cols))
	var i := 0
	for u in sel_units:
		var off := Vector2(i % cols - (cols - 1) * 0.5, floorf(float(i) / cols) - (rows - 1) * 0.5) * 28.0
		var d := wp + off
		u.dest = Vector2(clampf(d.x, 10, MAP.x - 10), clampf(d.y, 10, MAP.y - 10))
		u.state = S_MOVE
		u.target = null
		u.amove = false
		i += 1
	_ping(wp, Color(0.4, 1, 0.4))


func _cmd_attack(t) -> void:
	for u in sel_units:
		u.target = t
		u.state = S_ATTACK
		u.amove = false
	_ping(t.pos, Color(1, 0.3, 0.3))


func _cmd_gather(m: Mine) -> void:
	for u in sel_units:
		u.amove = false
		if u.type == "worker":
			u.mine = m
			u.state = S_GATHER
		else:
			u.dest = m.pos + Vector2(0, m.r + 40)
			u.state = S_MOVE
	_ping(m.pos, Color(1, 0.85, 0.2))


func _ping(p: Vector2, c: Color) -> void:
	fx.append({"k": "ring", "a": p, "b": p, "t": 0.45, "t0": 0.45, "c": c})


func _toast(t: String) -> void:
	msg = t
	msg_t = 2.0


# ───────────────────────── Інтерфейс (кнопки) ─────────────────────────
func _btn(id: String, r: Rect2, label: String, sub := "", enabled := true, active := false) -> void:
	buttons.append({"id": id, "rect": r, "label": label, "sub": sub, "enabled": enabled, "active": active})


func _button_at(pos: Vector2) -> String:
	for bt in buttons:
		if bt["rect"].has_point(pos):
			return bt["id"]
	return ""


func _layout_ui() -> void:
	var vp := get_viewport_rect().size
	ui_s = clampf(vp.y / 720.0, 0.7, 2.0)
	var s := ui_s
	var pad := 10.0 * s
	var bw := 140.0 * s
	var bh := 62.0 * s
	mm_rect = Rect2(pad, vp.y - 140.0 * s - pad, 210.0 * s, 140.0 * s)
	buttons.clear()
	if game != G_PLAY:
		_btn("restart", Rect2(vp.x * 0.5 - 130.0 * s, vp.y * 0.5 + 30.0 * s, 260.0 * s, 70.0 * s), "Грати знову")
		return
	var has_sel := not sel_units.is_empty() or sel_building != null
	var x := vp.x - pad - bw
	var y := vp.y - pad - bh
	_btn("cancel", Rect2(x, y, bw, bh), "Скасувати", "", has_sel or place_type != "")
	x -= bw + pad
	_btn("box", Rect2(x, y, bw, bh), "Рамка", "УВІМК" if box_mode else "вимк", true, box_mode)
	x -= bw + pad
	_btn("workers", Rect2(x, y, bw, bh), "Робітники")
	x -= bw + pad
	_btn("army", Rect2(x, y, bw, bh), "Армія")

	# контекстні кнопки
	y -= bh + pad
	x = vp.x - pad - bw
	if not _sel_workers().is_empty():
		var c: int = BUILD_DEF["barracks"]["cost"]
		_btn("build:barracks", Rect2(x, y, bw, bh), "Казарма", "%d золота" % c, gold[0] >= c, place_type == "barracks")
		x -= bw + pad
	if sel_building != null and sel_building.team == TEAM_PLAYER and sel_building.done:
		for t in TRAINS[sel_building.type]:
			var c: int = UNIT_DEF[t]["cost"]
			_btn("train:" + t, Rect2(x, y, bw, bh), UNIT_DEF[t]["name"], "%d золота" % c, gold[0] >= c)
			x -= bw + pad


func _press(id: String) -> void:
	if id.begins_with("train:"):
		if sel_building != null and sel_building.team == TEAM_PLAYER:
			_train(TEAM_PLAYER, sel_building, id.substr(6))
	elif id.begins_with("build:"):
		var type := id.substr(6)
		if gold[0] < BUILD_DEF[type]["cost"]:
			_toast("Не вистачає золота")
		else:
			place_type = type
			ghost_pos = cam
			_toast("Тягни пальцем і відпусти, щоб поставити")
	elif id == "army":
		var list := units.filter(func(u): return u.team == TEAM_PLAYER and u.hp > 0 and u.type != "worker")
		if list.is_empty():
			_toast("Війська ще немає")
		else:
			_select_units(list)
	elif id == "workers":
		var list := units.filter(func(u): return u.team == TEAM_PLAYER and u.hp > 0 and u.type == "worker")
		if list.is_empty():
			_toast("Робітників немає")
		else:
			_select_units(list)
	elif id == "box":
		box_mode = not box_mode
	elif id == "cancel":
		if place_type != "":
			place_type = ""
		else:
			_clear_selection()


# ───────────────────────── Малювання ─────────────────────────
func _draw() -> void:
	var vp := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.04, 0.06, 0.05))
	draw_set_transform(vp * 0.5 - cam * zoom, 0.0, Vector2(zoom, zoom))
	_draw_world(vp, font)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_hud(vp, font)


func _hpbar(p: Vector2, w: float, hp: float, mx: float) -> void:
	var f := clampf(hp / mx, 0.0, 1.0)
	draw_rect(Rect2(p.x - w * 0.5, p.y, w, 4.0), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(p.x - w * 0.5, p.y, w * f, 4.0), Color(1.0 - f, 0.3 + 0.7 * f, 0.15))


func _draw_world(vp: Vector2, font: Font) -> void:
	var view := _view_rect().grow(80.0)
	draw_rect(Rect2(Vector2.ZERO, MAP), Color(0.22, 0.38, 0.2))
	var g := 0.0
	while g <= MAP.x:
		draw_line(Vector2(g, 0), Vector2(g, MAP.y), Color(0, 0, 0, 0.06), 1.0)
		g += 200.0
	g = 0.0
	while g <= MAP.y:
		draw_line(Vector2(0, g), Vector2(MAP.x, g), Color(0, 0, 0, 0.06), 1.0)
		g += 200.0
	draw_rect(Rect2(Vector2.ZERO, MAP), Color(0.9, 0.9, 0.9, 0.4), false, 6.0)

	for k in rocks:
		if view.has_point(k.pos):
			draw_circle(k.pos, k.r, Color(0.36, 0.38, 0.34))
			draw_circle(k.pos + Vector2(-k.r, -k.r) * 0.2, k.r * 0.65, Color(0.5, 0.52, 0.47))

	for m in mines:
		if view.has_point(m.pos):
			draw_circle(m.pos, m.r, Color(0.5, 0.4, 0.1))
			draw_circle(m.pos, m.r * 0.7, Color(0.95, 0.8, 0.2))
			draw_circle(m.pos + Vector2(-6, -6), m.r * 0.2, Color(1, 1, 0.7))
			draw_string(font, m.pos + Vector2(-30, m.r + 16), str(m.gold), HORIZONTAL_ALIGNMENT_CENTER, 60, 14, Color(1, 0.95, 0.6))

	for b in buildings:
		if not view.has_point(b.pos):
			continue
		var h: float = b.r * 0.72
		var rc := Rect2(b.pos - Vector2(h, h), Vector2(h, h) * 2.0)
		var col: Color = team_col[b.team]
		var fill := col.darkened(0.45)
		if not b.done:
			fill.a = 0.6
		draw_rect(rc, fill)
		draw_rect(rc, col, false, 3.0)
		var nm: String = BUILD_DEF[b.type]["name"]
		draw_string(font, Vector2(b.pos.x - h, b.pos.y + 5), nm, HORIZONTAL_ALIGNMENT_CENTER, h * 2.0, 16, Color.WHITE)
		if b.selected:
			draw_rect(rc.grow(6.0), Color(0.4, 1, 0.4), false, 2.0)
		if b.hp < b.max_hp or b.selected:
			_hpbar(b.pos + Vector2(0, -h - 10), h * 2.0, b.hp, b.max_hp)
		if not b.done:
			draw_rect(Rect2(b.pos.x - h, b.pos.y + h + 4, h * 2.0 * b.progress, 4), Color(0.4, 0.8, 1))
		elif not b.queue.is_empty():
			var pr: float = b.prod_t / float(UNIT_DEF[b.queue[0]]["time"])
			draw_rect(Rect2(b.pos.x - h, b.pos.y + h + 4, h * 2.0, 4), Color(0, 0, 0, 0.6))
			draw_rect(Rect2(b.pos.x - h, b.pos.y + h + 4, h * 2.0 * pr, 4), Color(1, 0.85, 0.3))
			draw_string(font, Vector2(b.pos.x - h, b.pos.y + h + 22), "x%d" % b.queue.size(), HORIZONTAL_ALIGNMENT_CENTER, h * 2.0, 14, Color(1, 0.9, 0.5))

	for u in units:
		if u.hp <= 0 or not view.has_point(u.pos):
			continue
		var col: Color = team_col[u.team]
		draw_circle(u.pos, u.r, col)
		draw_arc(u.pos, u.r, 0.0, TAU, 20, Color(0, 0, 0, 0.7), 1.5)
		match u.type:
			"soldier":
				draw_line(u.pos, u.pos + u.face * (u.r + 7.0), Color.WHITE, 3.0)
			"archer":
				draw_arc(u.pos, u.r * 0.5, 0.0, TAU, 12, Color.WHITE, 2.0)
				draw_line(u.pos, u.pos + u.face * (u.r + 4.0), Color(1, 1, 0.7), 1.5)
			"worker":
				if u.carry > 0:
					draw_circle(u.pos, u.r * 0.5, Color(1, 0.85, 0.2))
		if u.selected:
			draw_arc(u.pos, u.r + 4.0, 0.0, TAU, 24, Color(0.4, 1, 0.4), 2.0)
		if u.hp < u.max_hp or u.selected:
			_hpbar(u.pos + Vector2(0, -u.r - 9), 22.0, u.hp, u.max_hp)

	for f in fx:
		var a: float = f["t"] / f["t0"]
		var c: Color = f["c"]
		c.a = a
		match f["k"]:
			"line":
				draw_line(f["a"], f["b"], c, 2.0)
			"hit":
				draw_circle(f["a"], 6.0 * (2.0 - a), c)
			"ring":
				draw_arc(f["a"], 8.0 + (1.0 - a) * 18.0, 0.0, TAU, 20, c, 2.0)

	if place_type != "":
		var d: Dictionary = BUILD_DEF[place_type]
		var ok := _can_place(ghost_pos, d["r"])
		var gc := Color(0.3, 1, 0.3, 0.5) if ok else Color(1, 0.3, 0.3, 0.5)
		var hh: float = d["r"] * 0.72
		draw_rect(Rect2(ghost_pos - Vector2(hh, hh), Vector2(hh, hh) * 2.0), gc)
		draw_arc(ghost_pos, d["r"], 0.0, TAU, 32, gc, 2.0)


func _btn_draw(bt: Dictionary, font: Font) -> void:
	var r: Rect2 = bt["rect"]
	var en: bool = bt["enabled"]
	var col := Color(0.14, 0.17, 0.22, 0.92)
	if not en:
		col = Color(0.12, 0.12, 0.14, 0.8)
	elif bt["active"]:
		col = Color(0.2, 0.5, 0.25, 0.95)
	draw_rect(r, col)
	draw_rect(r, Color(1, 1, 1, 0.4 if en else 0.12), false, 2.0)
	var a := 1.0 if en else 0.4
	var has_sub: bool = bt["sub"] != ""
	var ty := r.position.y + r.size.y * (0.45 if has_sub else 0.62)
	draw_string(font, Vector2(r.position.x, ty), bt["label"], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, int(20.0 * ui_s), Color(1, 1, 1, a))
	if has_sub:
		draw_string(font, Vector2(r.position.x, r.position.y + r.size.y * 0.82), bt["sub"], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, int(15.0 * ui_s), Color(1, 0.85, 0.3, a))


func _sel_text() -> String:
	if sel_building != null:
		var nm: String = BUILD_DEF[sel_building.type]["name"]
		return "%s  HP %d/%d" % [nm, int(sel_building.hp), int(sel_building.max_hp)]
	if sel_units.is_empty():
		return ""
	var cnt := {}
	for u in sel_units:
		cnt[u.type] = cnt.get(u.type, 0) + 1
	var parts: Array = []
	for k in cnt:
		parts.append("%s x%d" % [UNIT_DEF[k]["name"], cnt[k]])
	return "Вибрано: " + ", ".join(parts)


func _draw_hud(vp: Vector2, font: Font) -> void:
	var s := ui_s
	# рамка виділення
	for k in touches:
		var t: Dictionary = touches[k]
		if t["mode"] == "world" and t["moved"] and box_mode and place_type == "" and touches.size() == 1:
			var br := Rect2(t["s"], t["p"] - t["s"]).abs()
			draw_rect(br, Color(0.4, 1, 0.4, 0.15))
			draw_rect(br, Color(0.4, 1, 0.4, 0.9), false, 2.0)

	# верхня панель
	draw_rect(Rect2(0, 0, vp.x, 40.0 * s), Color(0, 0, 0, 0.55))
	var fs := int(22.0 * s)
	draw_string(font, Vector2(12.0 * s, 28.0 * s), "Золото: %d" % gold[0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 0.85, 0.25))
	draw_string(font, Vector2(190.0 * s, 28.0 * s), "Військо: %d/%d" % [ucount[0], MAX_UNITS], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	draw_string(font, Vector2(380.0 * s, 28.0 * s), _sel_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, int(18.0 * s), Color(0.7, 1, 0.7))
	var secs := int(time_s)
	draw_string(font, Vector2(vp.x - 90.0 * s, 28.0 * s), "%d:%02d" % [secs / 60, secs % 60], HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.8, 0.8, 0.8))

	if msg_t > 0.0:
		draw_string(font, Vector2(0, 80.0 * s), msg, HORIZONTAL_ALIGNMENT_CENTER, vp.x, int(24.0 * s), Color(1, 0.9, 0.5, minf(1.0, msg_t)))

	# міні-карта
	draw_rect(mm_rect, Color(0.06, 0.12, 0.06, 0.88))
	var k2 := mm_rect.size / MAP
	for m in mines:
		draw_circle(mm_rect.position + m.pos * k2, 3.0 * s, Color(0.95, 0.8, 0.2))
	for b in buildings:
		draw_rect(Rect2(mm_rect.position + b.pos * k2 - Vector2(4, 4) * s, Vector2(8, 8) * s), team_col[b.team])
	for u in units:
		if u.hp > 0:
			draw_circle(mm_rect.position + u.pos * k2, 2.0 * s, team_col[u.team])
	var vr := _view_rect()
	draw_rect(Rect2(mm_rect.position + vr.position * k2, vr.size * k2), Color(1, 1, 1, 0.9), false, 1.5)
	draw_rect(mm_rect, Color(1, 1, 1, 0.5), false, 2.0)

	for bt in buttons:
		_btn_draw(bt, font)

	if game != G_PLAY:
		draw_rect(Rect2(Vector2.ZERO, vp), Color(0, 0, 0, 0.55))
		var txt := "ПЕРЕМОГА!" if game == G_WIN else "ПОРАЗКА"
		var tc := Color(0.5, 1, 0.5) if game == G_WIN else Color(1, 0.45, 0.4)
		draw_string(font, Vector2(0, vp.y * 0.5 - 20.0 * s), txt, HORIZONTAL_ALIGNMENT_CENTER, vp.x, int(64.0 * s), tc)
		for bt in buttons:
			_btn_draw(bt, font)
