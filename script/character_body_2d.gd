extends CharacterBody2D

# --- 常數與列舉 ---
const SPEED = 300.0

enum PopupIds {
	SAY_HI = 100,
	SHOW_POSITION,
	RANDOM_MOVE,
	DELETE_PLAYER,
}

# --- 變數宣告 ---
var target_position: Vector2
var is_wandering = false
var move_time = 0.0
var is_selected = false
var _last_mouse_position: Vector2

# --- 節點引用 ---
@onready var _pm: PopupMenu = $"../PopupMenu"
@onready var selection_circle = $SelectionCircle
@onready var wandering_timer = $WanderingTimer

@onready var radial_menu: Control = $"../RadialMenu"

@onready var say_hi_button: Button = $"../RadialMenu/SayHiButton"
@onready var show_position_button: Button = $"../RadialMenu/ShowPositionButton"
@onready var random_move_button: Button = $"../RadialMenu/RandomMoveButton"
@onready var move_to_righttop_button: Button = $"../RadialMenu/MoveToRightTopButton"
@onready var move_to_lefttop_button: Button = $"../RadialMenu/MoveToLeftTopButton"
@onready var delete_button: Button = $"../RadialMenu/DeleteButton"

func _ready() -> void:
	input_pickable = true
	target_position = global_position
	radial_menu.visible = false

	# 初始化計時器
	wandering_timer.timeout.connect(_on_timer_timeout)
	wandering_timer.wait_time = randf_range(5.0, 8.0)
	wandering_timer.start()
	
	# 初始化右鍵選單
	say_hi_button.text = "Hi"
	show_position_button.text = "Pos"
	random_move_button.text = "Rnd"
	move_to_righttop_button.text = "RT"
	move_to_lefttop_button.text = "LT"
	delete_button.text = "Del"

	say_hi_button.pressed.connect(_on_say_hi_pressed)
	show_position_button.pressed.connect(_on_show_position_pressed)
	random_move_button.pressed.connect(_on_random_move_pressed)
	move_to_righttop_button.pressed.connect(_on_move_to_righttop_pressed)
	move_to_lefttop_button.pressed.connect(_on_move_to_lefttop_pressed)
	delete_button.pressed.connect(_on_delete_pressed)

	setup_radial_buttons()

func _physics_process(delta: float) -> void:
	# 鍵盤/搖桿手動輸入
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	var input_direction := Vector2(directionX, directionY)

	if input_direction != Vector2.ZERO:
		# 手動輸入時，中斷自動隨機移動
		is_wandering = false
		velocity = input_direction.normalized() * SPEED
	else:
		if is_wandering:
			# 自動隨機移動邏輯
			move_time += delta
			var direction_to_target = target_position - global_position
			var dist = direction_to_target.length()
			
			# 到達目的地或超時，停止移動
			if dist < 10 or move_time > 1.5:
				is_wandering = false
				velocity = Vector2.ZERO
				move_time = 0.0
				print("arrived")
			else:
				velocity = direction_to_target.normalized() * SPEED
		else:
			# 沒有輸入也沒有自動移動時，平滑減速至停止
			velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

# --- 統一的移動入口 ---
func _start_walking_to(dest: Vector2) -> void:
	target_position = dest
	is_wandering = true
	move_time = 0.0
	print("walk to: ", target_position)

# --- 定時器觸發（局部偏移隨機移動） ---
func _on_timer_timeout() -> void:
	var wandering_x = randf_range(-100.0, 100.0)
	var wandering_y = randf_range(-80.0, 80.0)
	var next_position = position + Vector2(wandering_x, wandering_y)
	
	# 限制移動範圍在場景內
	_start_walking_to(Vector2(
		clamp(next_position.x, 56.0, 1104.0),
		clamp(next_position.y, 192.0, 576.0)
	))
	
	# 重設下一次觸發時間
	wandering_timer.wait_time = randf_range(5.0, 8.0)
	wandering_timer.start()

# --- 滑鼠與選單事件 ---
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_last_mouse_position = get_global_mouse_position()
			show_radial_menu()

		elif event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection(true)

func show_radial_menu() -> void:
	radial_menu.visible = true

	var screen_pos := get_global_transform_with_canvas().origin
	radial_menu.global_position = screen_pos

	var radius := 90.0
	var button_size := Vector2(55, 55)

	var buttons := [
		say_hi_button,
		show_position_button,
		random_move_button,
		move_to_righttop_button,
		move_to_lefttop_button,
		delete_button
	]

	for i in range(buttons.size()):
		var angle := TAU * i / buttons.size() - PI / 2
		var offset := Vector2(cos(angle), sin(angle)) * radius

		buttons[i].size = button_size
		buttons[i].position = offset - button_size / 2

func setup_radial_buttons() -> void:
	var buttons := [
		say_hi_button,
		show_position_button,
		random_move_button,
		move_to_righttop_button,
		move_to_lefttop_button,
		delete_button
	]

	for button in buttons:
		button.custom_minimum_size = Vector2(55, 55)
		button.size = Vector2(55, 55)

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

func hide_radial_menu() -> void:
	radial_menu.visible = false


func _on_say_hi_pressed() -> void:
	print("hi")
	hide_radial_menu()


func _on_show_position_pressed() -> void:
	print(_last_mouse_position)
	hide_radial_menu()


func _on_random_move_pressed() -> void:
	target_position = Vector2(
		randf_range(100, 800),
		randf_range(100, 500)
	)
	is_wandering = true
	print("walk to: ", target_position)
	hide_radial_menu()


func _on_move_to_righttop_pressed() -> void:
	target_position = Vector2(1152, 0)
	is_wandering = true
	print("move to right top: ", target_position)
	hide_radial_menu()


func _on_move_to_lefttop_pressed() -> void:
	target_position = Vector2(0, 0)
	is_wandering = true
	print("move to left top: ", target_position)
	hide_radial_menu()


func _on_delete_pressed() -> void:
	print("delete player")
	hide_radial_menu()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_selection(false)

# --- 選取狀態切換 ---
func toggle_selection(selected: bool) -> void:
	is_selected = selected
	if selection_circle:
		selection_circle.visible = selected
