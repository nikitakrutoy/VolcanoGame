tool
extends Sprite

class_name Chip

var _dest: Vector2
var _do_move = false

enum ChipType {RED, GREEN, BLUE, BLACK = -1}
var chip_color = [Color(1, 0, 0), Color(0, 1, 0), Color(0, 0, 1), Color(0, 0, 0)]

export var moveSpeed: float = 4
export(ChipType) var chip_type = ChipType.RED setget set_chip_type


func set_chip_type(new_type):
	chip_type = new_type
	modulate = chip_color[chip_type]
	
func get_position():
	return _dest if _do_move else position


func move(dest: Vector2):
	_do_move = true
	_dest = dest


func _ready():
	modulate = chip_color[chip_type]
	set_process_input(true)


func _physics_process(delta):
	if _do_move:
		position = position.linear_interpolate(_dest, delta * moveSpeed)
		
		if (abs((position - _dest).length()) < 1e-4):
			position = _dest
			_do_move = false
