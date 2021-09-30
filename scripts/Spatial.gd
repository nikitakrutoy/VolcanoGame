extends Spatial


func _ready():
	$InterpolatedCamera.rotation_degrees = $Camera.rotation_degrees
	$InterpolatedCamera.translation = $Camera.translation
	$InterpolatedCamera.fov = $Camera.fov

