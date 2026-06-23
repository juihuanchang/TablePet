extends CharacterBody2D

var SPEED = 300.0

var _target_position: Vector2
var is_wandering := false
var _last_mouse_position: Vector2
var radial_side := 1 # 1 = 右邊，-1 = 左邊

@onready var radial_menu: Control = $"../RadialMenu"

@onready var say_hi_button: Button = $"../RadialMenu/SayHiButton"
@onready var show_position_button: Button = $"../RadialMenu/ShowPositionButton"
@onready var random_move_button: Button = $"../RadialMenu/RandomMoveButton"
@onready var move_to_righttop_button: Button = $"../RadialMenu/MoveToRightTopButton"
@onready var move_to_lefttop_button: Button = $"../RadialMenu/MoveToLeftTopButton"
@onready var delete_button: Button = $"../RadialMenu/DeleteButton"


func _ready() -> void:
	input_pickable = true

	_target_position = global_position

	radial_menu.visible = false

	say_hi_button.text = "Hi"
	show_position_button.text = "Pos"
	random_move_button.text = "Rnd"
	move_to_righttop_button.text = "RT"
	move_to_lefttop_button.text = "LT"
	delete_button.text = "Del"

	if not say_hi_button.pressed.is_connected(_on_say_hi_pressed):
		say_hi_button.pressed.connect(_on_say_hi_pressed)

	if not show_position_button.pressed.is_connected(_on_show_position_pressed):
		show_position_button.pressed.connect(_on_show_position_pressed)

	if not random_move_button.pressed.is_connected(_on_random_move_pressed):
		random_move_button.pressed.connect(_on_random_move_pressed)

	if not move_to_righttop_button.pressed.is_connected(_on_move_to_righttop_pressed):
		move_to_righttop_button.pressed.connect(_on_move_to_righttop_pressed)

	if not move_to_lefttop_button.pressed.is_connected(_on_move_to_lefttop_pressed):
		move_to_lefttop_button.pressed.connect(_on_move_to_lefttop_pressed)

	if not delete_button.pressed.is_connected(_on_delete_pressed):
		delete_button.pressed.connect(_on_delete_pressed)

	setup_radial_buttons()


func _physics_process(_delta: float) -> void:
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	var input_direction := Vector2(directionX, directionY)

	if input_direction != Vector2.ZERO:
		is_wandering = false
		velocity = input_direction.normalized() * SPEED
	else:
		if is_wandering:
			var direction_to_target := _target_position - global_position

			if direction_to_target.length() < 5:
				global_position = _target_position
				velocity = Vector2.ZERO
				is_wandering = false
				print("arrived")
			else:
				velocity = direction_to_target.normalized() * SPEED
		else:
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

	if radial_menu.visible:
		update_radial_menu_position()
		update_radial_button_positions()


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		print("右鍵點到 player")

		_last_mouse_position = get_global_mouse_position()
		show_radial_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		_target_position = get_global_mouse_position()
		is_wandering = true
		hide_radial_menu()
		print("walk to mouse: ", _target_position)


func show_radial_menu() -> void:
	radial_menu.visible = true
	update_radial_menu_position()
	update_radial_button_positions()


func update_radial_button_positions() -> void:
	var button_size := Vector2(40, 40)
	var radius := 60.0

	var buttons: Array[Button] = [
		say_hi_button,
		show_position_button,
		random_move_button,
		move_to_righttop_button,
		move_to_lefttop_button,
		delete_button
	]

	for i in range(buttons.size()):
		buttons[i].custom_minimum_size = button_size
		buttons[i].size = button_size

		var start_angle := -PI / 2.0
		var end_angle := PI / 2.0
		var t := float(i) / float(buttons.size() - 1)
		var angle := lerpf(start_angle, end_angle, t)

		var offset := Vector2(cos(angle) * radial_side, sin(angle)) * radius
		buttons[i].position = offset - button_size / 2.0


func update_radial_menu_position() -> void:
	var viewport_size := get_viewport_rect().size
	var button_area_width := 100.0

	var right_position := global_position + Vector2(40, -20)
	var left_position := global_position + Vector2(-40, -20)

	if right_position.x + button_area_width > viewport_size.x:
		radial_side = -1
		radial_menu.global_position = left_position
	else:
		radial_side = 1
		radial_menu.global_position = right_position


func setup_radial_buttons() -> void:
	var buttons: Array[Button] = [
		say_hi_button,
		show_position_button,
		random_move_button,
		move_to_righttop_button,
		move_to_lefttop_button,
		delete_button
	]

	for button in buttons:
		button.custom_minimum_size = Vector2(40, 40)
		button.size = Vector2(40, 40)

		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.15, 0.25, 0.45, 0.9)
		normal_style.border_color = Color.WHITE
		normal_style.set_border_width_all(2)
		normal_style.set_corner_radius_all(100)

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.35, 0.55, 0.95, 0.95)
		hover_style.border_color = Color.WHITE
		hover_style.set_border_width_all(2)
		hover_style.set_corner_radius_all(100)

		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", hover_style)

		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)

		button.add_theme_font_size_override("font_size", 13)


func hide_radial_menu() -> void:
	radial_menu.visible = false


func _on_say_hi_pressed() -> void:
	print("hi")
	hide_radial_menu()


func _on_show_position_pressed() -> void:
	print("player position: ", global_position)
	hide_radial_menu()


func _on_random_move_pressed() -> void:
	_target_position = Vector2(
		randf_range(100, 800),
		randf_range(100, 500)
	)
	is_wandering = true
	print("walk to random: ", _target_position)
	hide_radial_menu()


func _on_move_to_righttop_pressed() -> void:
	_target_position = Vector2(1152, 0)
	is_wandering = true
	print("move to right top: ", _target_position)
	hide_radial_menu()


func _on_move_to_lefttop_pressed() -> void:
	_target_position = Vector2(0, 0)
	is_wandering = true
	print("move to left top: ", _target_position)
	hide_radial_menu()


func _on_delete_pressed() -> void:
	print("delete player")
	hide_radial_menu()
	queue_free()