extends Node2D

@onready var camera: Camera2D = $player/Camera2D

@export var zoom_step := 0.1
@export var min_zoom := 1.0
@export var max_zoom := 3.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var new_zoom := camera.zoom.x

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_zoom += zoom_step
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_zoom -= zoom_step
		else:
			return

		new_zoom = clampf(new_zoom, min_zoom, max_zoom)
		camera.zoom = Vector2(new_zoom, new_zoom)
