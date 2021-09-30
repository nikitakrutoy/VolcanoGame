extends Node


func _on_Field_chips_aligned():
	$Control.show()
	$Field.set_process_unhandled_input(false)


func _on_Button_pressed():
	get_tree().quit()
	
