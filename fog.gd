extends ColorRect

const CELL = 32
const UPDATE_EVERY = 0.5
const SHADER = "
shader_type canvas_item;
uniform sampler2D fog_tex : filter_linear;
void fragment() {
	float v = texture(fog_tex, UV).r;
	float a = v == 0.0 ? mix(1, 0.9, v * 2.0) : mix(0.1, 0.0, v * 2.0);
	COLOR = vec4(0.0, 0.0, 0.0, a);
}
"

@onready var map_rect = Rect2(get_parent().cameralimits[0] - 576, get_parent().cameralimits[2] - 324, get_parent().cameralimits[1] - get_parent().cameralimits[0] + 1152, get_parent().cameralimits[3] - get_parent().cameralimits[2] + 648)  # межі карти у світових координатах

var cols: int
var rows: int
var explored = PackedByteArray()
var current = PackedByteArray()
var tex: ImageTexture
var scenario
var timer = 0.0
var _circles = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scenario = get_parent()
	position = map_rect.position
	size = map_rect.size
	z_index = 101
	cols = ceili(map_rect.size.x / CELL)
	rows = ceili(map_rect.size.y / CELL)
	explored.resize(cols * rows)
	explored.fill(0)
	current = explored.duplicate()
	tex = ImageTexture.create_from_image(
		Image.create_from_data(cols, rows, false, Image.FORMAT_L8, current))
	var sh := Shader.new()
	sh.code = SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("fog_tex", tex)
	material = mat


func _process(delta: float) -> void:
	timer -= delta
	if timer > 0:
		return
	timer = UPDATE_EVERY
	_update_fog()


func _update_fog() -> void:
	current = explored.duplicate()
	var units = get_tree().get_nodes_in_group("unit")
	for u in units:
		if check_for_fog(u):
			continue
		var r = roundi(u.main.unit[u.type]["vision"] / float(CELL))
		var c = _cell(u.global_position)
		for off in _offsets(r):
			var x = c.x + off.x
			var y = c.y + off.y
			if x < 0 or y < 0 or x >= cols or y >= rows:
				continue
			var i = y * cols + x
			current[i] = 255
			explored[i] = 0
	tex.update(Image.create_from_data(cols, rows, false, Image.FORMAT_L8, current))
	for u in units:
		if check_for_fog(u):
			u.visible = true
		else:
			u.visible = can_see(u.global_position)


func can_see(p: Vector2) -> bool:
	var i = _index(p)
	return i >= 0 and current[i] == 255

func _cell(p: Vector2) -> Vector2i:
	return Vector2i(((p - map_rect.position) / CELL).floor())

func _index(p: Vector2) -> int:
	var c = _cell(p)
	if c.x < 0 or c.y < 0 or c.x >= cols or c.y >= rows:
		return -1
	return c.y * cols + c.x

func _offsets(r: int) -> Array:
	if !_circles.has(r):
		var a = []
		for y in range(-r, r + 1):
			for x in range(-r, r + 1):
				if x * x + y * y <= r * r:
					a.append(Vector2i(x, y))
		_circles[r] = a
	return _circles[r]

func check_for_fog(u):
	var makefog = true
	if u.givesight:
		makefog = false
	return makefog
