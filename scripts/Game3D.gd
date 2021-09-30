extends Node

var _pause_path = "UI/PauseScreen/CenterContainer/Pause"
var _success_path = "UI/PauseScreen/CenterContainer/Success"
var _failed_path = "UI/PauseScreen/CenterContainer/Failed"
var _endgame_path = "UI/PauseScreen/CenterContainer/EndGame"
var _title_path = "UI/TitleScreen"

var current_level = 0

var levels = [
	"Spatial/Rock1/rock1/Level1Field",
	"Spatial/Rock2/rock2/Level2Field",
	"Spatial/Rock3/rock3/Level3Field"
]

var level_cameras = [
	"Spatial/Camera001",
	"Spatial/Camera002",
	"Spatial/Camera003"
]


var b_is_on_title_screen = true;
var current_menu = null;


func hide_menu(node):
	current_menu = null
	get_node(node).hide()
	$UI/PauseScreen.hide()
	$UI.hide()
	return


func show_menu(node):
	current_menu = node
	get_node(node).show()
	$UI/PauseScreen.show()
	$UI.show()
	
	return


func load_level(level_id):
	var node_path = levels[level_id]
	get_node(node_path).reload()
	$Spatial/InterpolatedCamera.set_target(get_node(level_cameras[level_id]))


func _unhandled_input(event):	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if current_menu == _pause_path:
				hide_menu(_pause_path)
				return
				
			if current_menu == null and not b_is_on_title_screen:
				show_menu(_pause_path)
				return
			


func _on_Level1_pressed():
	b_is_on_title_screen = false
	current_level = 0
	load_level(current_level)
	$UI/TitleScreen.hide()
	$UI.hide()


func _on_Level2_pressed():
	b_is_on_title_screen = false
	current_level = 1
	load_level(current_level)
	$UI/TitleScreen.hide()
	$UI.hide()


func _on_Level3_pressed():
	b_is_on_title_screen = false
	current_level = 2
	load_level(current_level)
	$UI/TitleScreen.hide()
	$UI.hide()


func _on_Level1Field_succeed():
	show_menu(_success_path)


func _on_Menu_pressed():
	if current_menu != null:
		hide_menu(current_menu)
	
	$UI/TitleScreen.show()
	$UI.show()
	$Spatial/InterpolatedCamera.set_target($Spatial/Camera) 
	


func _on_Exit_pressed():
	get_tree().quit(0)


func _on_Restart_pressed():	
	get_node(levels[current_level]).reload()
	hide_menu(current_menu)


func _on_NextLevel_pressed():
	current_level = (current_level + 1) % len(levels)
	if current_level == 0:
		_on_Menu_pressed()
	else:
		load_level(current_level)
		hide_menu(current_menu)
