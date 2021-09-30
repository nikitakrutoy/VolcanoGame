tool
extends Position3D


signal succeed
signal failed

const Cell = preload("res://scripts/Cell.gd")
const CellScene = preload("res://scenes/Cell.tscn")

export var cell_size : int = 10
export var header_offset : float = 10
export(PackedScene) var grid_map_scene

var _columns : int
var _rows: int

var columns_types

var _cells : Dictionary = {}
var _field : Dictionary = {}
var _nfield : Array = []

var _succeed = false
var _failed = false

var _timer : Timer


const CODE2TYPE = {
	"RED":   Cell.CellType.RED,
	"GREEN": Cell.CellType.GREEN,
	"BLUE":  Cell.CellType.BLUE,
	"BLACK": Cell.CellType.BLACK,
}


func init():
	var grid_map : GridMap = null
	if (grid_map_scene != null):
		grid_map = grid_map_scene.instance() as GridMap
	if (grid_map != null):
		_process_grid_map(grid_map)
		
		for cell in _cells.values():
			cell.connect("want_to_move", self, "move_cell")
			
		grid_map.queue_free()
	
	_succeed = false
	_failed = false


func clear():
	for cell in _cells.values():
		if (cell != null):
			cell.queue_free()
	_cells = {}
	_field = {}
	_nfield = []


func reload():
	clear()
	init()


func move_cell(id, dir):
	var loc = _field[id]
	var nloc = loc + dir
	var dir3d = Vector3(dir.x, 0, dir.y)
	
	if _succeed or _failed:
		return
	
	if _cells[id].cell_type == Cell.CellType.BLACK:
		return
	
	if  not (nloc.x >= 0 and nloc.x < _columns and nloc.y >= 0 and nloc.y < _rows):
		return
		
	if _nfield[expand(nloc)] == null:
		_cells[id].move(dir3d * cell_size) 	
		
		_field[id] = nloc
		_nfield[expand(nloc)] = id
		_nfield[expand(loc)] = null
		
		if is_succeed():
			_succeed = true
			emit_signal("succeed")

func start():
	$Timer.start()


func _ready():
	init()


func expand(v: Vector2):
	return _columns * v.y + v.x


func _create_header_cell(cell_type, pos):
	var g = CellScene.instance()
	add_child(g)
	g.position = pos
	g.cell_type = cell_type
	return g


func _create_field_cell(cell_type, pos, id):
	var g = CellScene.instance()
	add_child(g)
#	g.scale(0.01)
	g.init(id, pos, cell_type)
	return g


func _process_grid_map(grid_map : GridMap):
		_columns = 0 
		_rows = 0
		for cell in grid_map.get_used_cells():
			_columns = max(_columns, cell.x)
			_rows = max(_rows, cell.z)
			
		_columns += 1
		_rows += 1
		
		columns_types =  []
		columns_types.resize(_columns)
		_cells = {}
		_field = {}
		_nfield = []
		_nfield.resize(_rows * _columns)
		
		var pos
		var loc
		var id = 0
		for cell in grid_map.get_used_cells():
			var cell_id = grid_map.get_cell_item(cell.x, cell.y, cell.z)
			var code = grid_map.mesh_library.get_item_name(cell_id)
			if cell.z < 0:
				columns_types[cell.x] = CODE2TYPE[code]
				pos = Vector3(
					cell.x * cell_size + cell_size / 2, 0, 
					-header_offset - cell_size / 2)
				_create_header_cell(CODE2TYPE[code], pos)
			else:
				pos = Vector3(
					cell.x * cell_size + cell_size / 2, 0,
					cell.z * cell_size + cell_size / 2)
				_cells[id] = _create_field_cell(CODE2TYPE[code], pos, id)
				
				loc = Vector2(cell.x, cell.z)
				_field[id] = loc
				_nfield[expand(loc)] = id
				
				id += 1
				
			
		grid_map.hide()


func is_succeed():
	var res = true
	for i in range(_columns):
		var column_type = columns_types[i]
		if column_type!= Cell.CellType.BLACK and column_type != null:
			for j in range(_rows):
				if (_nfield[_columns * j + i] != null):
					var cell_id = _nfield[_columns * j + i]
					res = res and (
						_cells[cell_id].cell_type == column_type or
						 _cells[cell_id].cell_type == Cell.CellType.BLACK
						)
				else:
					return false
	return res
