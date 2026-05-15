extends CharacterBody2D

var SPEED = 300.0
var target_position: Vector2
var is_wandering = false
var move_time = 0.0

enum PopupIds {
	SAY_HI = 100,
	SHOW_POSITION,
	RANDOM_MOVE,
	DELETE_PLAYER,
}
var _last_mouse_position: Vector2
@onready var _pm: PopupMenu = $"../PopupMenu"

var is_selected = false
@onready var selection_circle = $SelectionCircle

func _ready():
	input_pickable = true
	
	$WanderingTimer.timeout.connect(_on_timer_timeout)
	$WanderingTimer.wait_time = randf_range(5.0, 8.0)
	$WanderingTimer.start()
	
	_pm.clear()
	_pm.add_item("打招呼 (say hi)", PopupIds.SAY_HI)
	_pm.add_item("顯示座標 (show position)", PopupIds.SHOW_POSITION)
	_pm.add_item("random move", PopupIds.RANDOM_MOVE)
	_pm.add_separator()
	_pm.add_item("刪除角色 (delete player)", PopupIds.DELETE_PLAYER)
	if not _pm.id_pressed.is_connected(_on_popup_menu_id_pressed):
		_pm.id_pressed.connect(_on_popup_menu_id_pressed)
	
	target_position = global_position

func _physics_process(delta: float) -> void:
	var directionX := Input.get_axis("ui_left", "ui_right")
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var directionY := Input.get_axis("ui_up", "ui_down")
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	# 手動輸入時中斷自動移動
	if directionX != 0 or directionY != 0:
		is_wandering = false

	# ✅ 整合後：唯一的自動移動處理區塊
	if is_wandering:
		move_time += delta
		var dir = (target_position - global_position).normalized()
		velocity = dir * SPEED
		
		var dist = global_position.distance_to(target_position)
		if dist < 10 or move_time > 1.5:
			is_wandering = false
			velocity = Vector2.ZERO
			move_time = 0.0
			print("arrived")

	move_and_slide()

func _on_timer_timeout() -> void:
	# ✅ timer 觸發：偏移式隨機移動
	var wandering_x = randf_range(-100.0, 100.0)
	var wandering_y = randf_range(-80.0, 80.0)
	var next_position = position + Vector2(wandering_x, wandering_y)
	
	_start_walking_to(Vector2(
		clamp(next_position.x, 56.0, 1104.0),
		clamp(next_position.y, 192.0, 576.0)
	))
	
	$WanderingTimer.wait_time = randf_range(5.0, 8.0)
	$WanderingTimer.start()

# ✅ 整合後：統一入口，timer 和右鍵選單都呼叫這個
func _start_walking_to(dest: Vector2) -> void:
	target_position = dest
	is_wandering = true
	move_time = 0.0
	print("walk to: ", target_position)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_last_mouse_position = get_global_mouse_position()
			_pm.position = get_viewport().get_mouse_position()
			_pm.popup()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection(true)

func _on_popup_menu_id_pressed(id: int) -> void:
	match id:
		PopupIds.SAY_HI:
			print("hi")
		PopupIds.SHOW_POSITION:
			print(_last_mouse_position)
		PopupIds.RANDOM_MOVE:
			# ✅ 右鍵選單觸發：全場景範圍隨機移動，同樣呼叫 _start_walking_to
			_start_walking_to(Vector2(
				randf_range(100, 800),
				randf_range(100, 500)
			))
		PopupIds.DELETE_PLAYER:
			print("delete player")
			queue_free()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_selection(false)

func toggle_selection(selected: bool) -> void:
	is_selected = selected
	if selection_circle:
		selection_circle.visible = selected
