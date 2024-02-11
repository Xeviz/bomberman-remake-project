extends CharacterBody2D


var speed = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func change_facing_direction():
	if Input.is_action_pressed("ui_left"):
		rotation_degrees = 270
	elif Input.is_action_pressed("ui_right"):
		rotation_degrees = 90
	elif Input.is_action_pressed("ui_up"):
		rotation_degrees = 0
	elif Input.is_action_pressed("ui_down"):
		rotation_degrees = 180

func get_movement(delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		velocity = Vector2.UP.rotated(rotation) * speed
		position += velocity * delta
		move_and_slide()
	
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if name.to_int()== 1:
		position = Vector2(100,100)
	elif name.to_int()== 2:
		position = Vector2(500,500)
	
func _process(delta):
	
	var direction = 0
	var velocity = Vector2.ZERO
	
	get_movement(delta)
	change_facing_direction()
	
	
