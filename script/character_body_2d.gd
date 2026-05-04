extends CharacterBody2D

var SPEED = 300.0
#const JUMP_VELOCITY = -400.0

var target_position: Vector2
var is_wandering = false

enum PopupIds {
	SAY_HI = 100,
	SHOW_POSITION,
	DELETE_PLAYER,
}
var _last_mouse_position: Vector2
@onready var _pm: PopupMenu = $"../PopupMenu"

var move_time = 0.0	

func _ready():
	input_pickable = true
	$WanderingTimer.timeout.connect(_on_timer_timeout)
	$WanderingTimer.wait_time = randf_range(5.0,8.0)
	$WanderingTimer.start()
	_pm.clear()
	_pm.add_item("say hi", PopupIds.SAY_HI)
	_pm.add_item("show position", PopupIds.SHOW_POSITION)
	_pm.add_separator()
	_pm.add_item("delete player", PopupIds.DELETE_PLAYER)
	_pm.id_pressed.connect(_on_popup_menu_id_pressed)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
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
		
	if directionX != 0 or directionY != 0:
		is_wandering = false 
		
	if is_wandering:
		move_time += delta
		var dir = (target_position - position).normalized()
		velocity = dir * SPEED
		
		var dist = position.distance_to(target_position)
		
		if dist < 10 or move_time > 1.5:
			is_wandering = false
			velocity = Vector2.ZERO
			move_time = 0.0

	move_and_slide()

func _on_timer_timeout() -> void:
	wandering()
	$WanderingTimer.wait_time = randf_range(5.0,8.0)
	$WanderingTimer.start()
	
func wandering() -> void:
	var wanering_x = randf_range(-100.0,100.0)
	var wanering_y = randf_range(-80.0,80.0)
	var next_position = position + Vector2(wanering_x, wanering_y)
	
	target_position.x = clamp(next_position.x, 56.0, 1104.0)
	target_position.y = clamp(next_position.y, 192.0, 576.0)
	
	is_wandering = true

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
