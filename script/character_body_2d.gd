extends CharacterBody2D

enum PopupIds {
	SAY_HI = 100,
	SHOW_POSITION,
	RANDOM_MOVE,
	DELETE_PLAYER,
}

var SPEED = 300.0
var _target_position: Vector2
var _is_walking_to_random_position := false
var _last_mouse_position: Vector2

@onready var _pm: PopupMenu = $"../PopupMenu"


func _ready() -> void:
	input_pickable = true

	$WanderingTimer.timeout.connect(_on_timer_timeout)
	$WanderingTimer.wait_time = randf_range(5.0, 8.0)
	$WanderingTimer.start()

	_pm.clear()
	_pm.add_item("say hi", PopupIds.SAY_HI)
	_pm.add_item("show position", PopupIds.SHOW_POSITION)
	_pm.add_item("random move", PopupIds.RANDOM_MOVE)
	_pm.add_separator()
	_pm.add_item("delete player", PopupIds.DELETE_PLAYER)

	_pm.id_pressed.connect(_on_popup_menu_id_pressed)
	_target_position = global_position


func _physics_process(delta: float) -> void:
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	var input_direction := Vector2(directionX, directionY)

	if input_direction != Vector2.ZERO:
		_is_walking_to_random_position = false
		velocity = input_direction.normalized() * SPEED
	else:
		if _is_walking_to_random_position:
			var direction_to_target := _target_position - global_position

			if direction_to_target.length() < 5:
				global_position = _target_position
				velocity = Vector2.ZERO
				_is_walking_to_random_position = false
				print("arrived")
			else:
				velocity = direction_to_target.normalized() * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		print("右鍵點到 player")

		_last_mouse_position = get_global_mouse_position()
		var mouse_pos := get_viewport().get_mouse_position()

		_pm.position = mouse_pos
		_pm.popup()


func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		PopupIds.SAY_HI:
			print("hi")

		PopupIds.SHOW_POSITION:
			print(_last_mouse_position)

		PopupIds.DELETE_PLAYER:
			print("delete player")
			queue_free()
		PopupIds.RANDOM_MOVE:
			_target_position = Vector2(
				randf_range(100, 800),
				randf_range(100, 500)
			)
			_is_walking_to_random_position = true
			print("walk to: ", _target_position)


func _on_timer_timeout() -> void:
	$WanderingTimer.wait_time = randf_range(5.0, 8.0)
	$WanderingTimer.start()