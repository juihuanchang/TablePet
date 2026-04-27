extends AnimatedSprite2D

func _ready() -> void:
	play("default")
	animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		play("attack")
	
	if animation != "attack":
		handle_movement()

func handle_movement() -> void:
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or $"..".is_wandering == true:
		if animation != "run":
			play("run")
	elif Input.is_action_pressed("ui_left"):
		if animation != "run_backward":
			play("run_backward")
	else:
		if animation != "default":
			play("default")

func _on_animation_finished() -> void:
	if animation == "attack":
		play("default")
