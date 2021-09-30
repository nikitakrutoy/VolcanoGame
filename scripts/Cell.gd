tool
extends MeshInstance

signal want_to_move(id, dir)

const RED_MAT = preload("res://materials/Red.tres")
const GREEN_MAT = preload("res://materials/Green.tres")
const BLUE_MAT = preload("res://materials/Blue.tres")
const BLACK_MAT = preload("res://materials/Black.tres")


enum CellType {RED, GREEN, BLUE, BLACK = -1}
const TYPE2MAT = [RED_MAT, GREEN_MAT, BLUE_MAT, BLACK_MAT]

export(CellType) var cell_type = CellType.RED setget set_cell_type

var _move_speed = 5

var _pressed = false
var _initialized = false

var _moving = false
var _dest: Transform
var _orig: Vector3
var _drag_start_position: Vector2
var _drag_end_position: Vector2
var _id: int


var position: Vector3 setget set_positon 

func set_positon(value):
	var diff = value - position 
	translate_object_local(value)
	position = get_translation()
	
func set_cell_type(value):
	cell_type = value
	set_surface_material(0, TYPE2MAT[cell_type])
	set_surface_material(1, TYPE2MAT[cell_type])
	
func init(id, pos, cell_type):
	_id = id
	set_cell_type(cell_type)
	set_positon(pos)
	_dest = transform
	_initialized = true
	

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("input_event", self, "_on_Area_input_event")


func move(delta):
	if not _initialized:
		return
	_dest = _dest.translated(delta)
	_moving = true


func _unhandled_input(event):
	if not _initialized:
		return
		
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if _pressed:
			_drag_end_position = event.position
			var drag = _drag_end_position - _drag_start_position
			var dir
			if abs(drag.x) > abs(drag.y):
				dir = Vector2.RIGHT * sign(drag.x) 
			else:
				dir = -Vector2.UP * sign(drag.y) 
				
			#_dest = _dest.translated(dir * cell_size)
			emit_signal("want_to_move", _id, dir)
		
		_pressed = false


func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if not _initialized:
		return
		
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not _pressed:
			_drag_start_position = event.position
			_pressed = true


func _physics_process(delta):
	if not _initialized:
		return
		
	if _moving:
		transform = transform.interpolate_with(_dest, _move_speed * delta)
		if (abs((_dest.origin - transform.origin).length()) < 1e-4):
			transform = _dest
			_moving = false
