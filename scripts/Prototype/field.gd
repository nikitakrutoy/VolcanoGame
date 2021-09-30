tool
extends Node2D

const Utils = preload("res://scripts/Prototype/utils.gd")
const ChipClass = preload("res://scripts/Prototype/chip.gd")
const ChipScene = preload("res://scenes/Prototype/Chip.tscn")

export var cell_size = 100
export var header_offset = 20
export(String, FILE) var field_file_path
export(PackedScene) var tile_map_scene

signal chips_aligned

var columns_types = []

var _columns
var _rows

var _current_chip

var _drag_start_input_col
var _drag_start_input_row
var _drag_start_position

var _chips = []

const CODE2TYPE = {
	"R": Chip.ChipType.RED,
	"G":Chip.ChipType.GREEN,
	"B":Chip.ChipType.BLUE,
	"X":Chip.ChipType.BLACK,
}


func get_tile_map():
	for child in get_children():
		if child is TileMap:
			return child
	return null


func _process_text(data):
	var node_type
	var code
	
	_columns = len(data[0])
	_rows = len(data) - 1
	
	for j in range(_columns):
		code = data[0][j]
		columns_types.append(CODE2TYPE[code])
		if CODE2TYPE[code] != Chip.ChipType.BLACK:
			var pos =Vector2(
				j * cell_size + cell_size / 2, 
				-header_offset - cell_size / 2)
			_create_chip(code, pos)
		
	data.remove(0)
	
	var row
	var col
	
	for i in range(_columns):
		row = data[i]
		for j in range(_rows):
			code = row[j]
			if code != " ":
				var pos = Vector2(
					j * cell_size + cell_size / 2, 
					i * cell_size + cell_size / 2)
				var g = _create_chip(code, pos)
				_chips.append(g)
			else:
				_chips.append(null)


func _create_chip(code, pos):
	var g = ChipScene.instance()
	add_child(g)
	g.position = pos
	g.scale = cell_size * Vector2.ONE / g.texture.get_size()
	g.chip_type = CODE2TYPE[code]
	return g


func _process_tile_map(tile_map : TileMap):
		_columns = 0 
		_rows = 0
		for cell in tile_map.get_used_cells():
			_columns = max(_columns, cell.x)
			_rows = max(_rows, cell.y)
			
		_columns += 1
		_rows += 1
		
		columns_types =  []
		columns_types.resize(_columns)
		_chips = []
		_chips.resize(_rows * _columns)
		
		for cell in tile_map.get_used_cells():
			var cell_id = tile_map.get_cell(cell.x, cell.y)
			var code = tile_map.tile_set.tile_get_name(cell_id)
			if cell.y < 0 :
				columns_types[cell.x] = CODE2TYPE[code]
				var pos =Vector2(
					cell.x * cell_size + cell_size / 2, 
					-header_offset - cell_size / 2)
				_create_chip(code, pos)
			else:
				var pos = Vector2(
					cell.x * cell_size + cell_size / 2, 
					cell.y * cell_size + cell_size / 2)
				var g = _create_chip(code, pos)
				_chips[_columns * cell.y + cell.x] = g
			
		tile_map.hide()


func initialize():
	var tile_map : TileMap = null
	if (tile_map_scene != null):
		tile_map = tile_map_scene.instance() as TileMap
	if (tile_map != null):
		_process_tile_map(tile_map)
		tile_map.queue_free()
	else:
		var data = Utils.load_text_file(field_file_path).split("\n")
		_process_text(data)	


func clear():
	for chip in _chips:
		if (chip != null):
			chip.queue_free()
	_chips = []

	
func reload():
	clear()
	initialize()


func _ready():
	initialize()


func _unhandled_input(ev):
	if ev is InputEventMouseButton and \
			not ev.is_echo() and ev.button_index == BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position() - position;
		var input_col = int(floor(mouse_pos.x / cell_size))
		var input_row = int(floor(mouse_pos.y / cell_size))
		
		if ev.pressed:
			if (input_col < 0 or input_col >= _columns or 
					input_row < 0 or input_row >= _rows):
				_current_chip = null
				return
				
			_current_chip = _chips[_columns * input_row + input_col]
			
			if _current_chip == null: return
			
			if _current_chip.chip_type == Chip.ChipType.BLACK:
				_current_chip = null
				return
				
			_drag_start_position = get_global_mouse_position()
			_drag_start_input_col = input_col
			_drag_start_input_row = input_row
		else:
			if _current_chip != null:
				var drag_vector: Vector2 = _drag_start_position - get_global_mouse_position()
				var current_position: Vector2 = _current_chip.get_position()
				
				var move_vector: Vector2
				var drag_position: Vector2
				
				if abs(drag_vector.x) > abs(drag_vector.y):
					move_vector = -Vector2.RIGHT * sign(drag_vector.x) 
					drag_position = current_position + move_vector * cell_size
				else:
					move_vector = Vector2.UP * sign(drag_vector.y) 
					drag_position = current_position + move_vector * cell_size
				
				var field_pos = Vector2(
					_drag_start_input_col, _drag_start_input_row)
				var new_field_pos = move_vector + field_pos
				var ncol = new_field_pos.x
				var nrow = new_field_pos.y
				
				if ncol < 0 or ncol >= _columns or nrow < 0 or nrow >= _rows:
					return
				
				if _chips[_columns * nrow + ncol] != null:
					return
				else: 
					_chips[_columns * nrow + ncol] = \
						_chips[_columns * field_pos.y + field_pos.x]
					_chips[_columns * field_pos.y + field_pos.x] = null
					if are_chips_aligned_correctly():
						emit_signal("chips_aligned")
					
					_current_chip.move(drag_position)


func are_chips_aligned_correctly():
	var res = true
	for i in range(_columns):
		if columns_types[i] != Chip.ChipType.BLACK and columns_types[i] != null:
			for j in range(_rows):
				if (_chips[_columns * j + i] != null):
					res = res and (_chips[_columns * j + i].chip_type == columns_types[i])
				else:
					return false
	return res
