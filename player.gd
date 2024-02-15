extends CharacterBody2D


var speed = 100.0
var bombs_limit = 1
var bombs_placed_amount = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var tilemap = get_tree().root.get_node("GameRoom").get_node("GameMap")


func change_facing_direction():
	if Input.is_action_pressed("ui_left"):
		pass
	elif Input.is_action_pressed("ui_right"):
		pass
	elif Input.is_action_pressed("ui_up"):
		pass
	elif Input.is_action_pressed("ui_down"):
		pass

func get_movement(delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
		position += velocity * delta
		print(position)
		print(name)
		move_and_slide()
	
	
func _enter_tree():
	name = "1"
	set_multiplayer_authority(name.to_int())
	
		
func place_bomb():
	if Input.is_action_just_pressed("bomb_placed") and bombs_placed_amount < bombs_limit:
		var player_bomb = preload("res://Bomb.tscn").instantiate()
		var map_position = tilemap.local_to_map(position)
		var spawn_position = tilemap.map_to_local(map_position)
		get_tree().root.add_child(player_bomb)
		player_bomb.global_position = spawn_position
		bombs_placed_amount+=1
		
func generate_explosion(exploding_bomb, explosion_range):
	print(exploding_bomb.position)
	print("bumbuje")
	var map_spawn_position = tilemap.local_to_map(exploding_bomb.position)
	var mapped_explosion = preload("res://ExplosionMap.tscn").instantiate()
	mapped_explosion.set_cell(0, map_spawn_position, 1, Vector2i(3, 3), 0)
	var pos_x = map_spawn_position.x
	var pos_y = map_spawn_position.y
	var blocked_left = false
	var blocked_right = false
	var blocked_up = false
	var blocked_down = false
	
	
	
	for g in range(1, explosion_range+1):
		
		if blocked_right == false:
			var right_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x+g, pos_y))
			if right_block == Vector2i(0,2):
				mapped_explosion.set_cell(0, Vector2i(pos_x+g, pos_y), 1, Vector2i(1, 3), 0)
				tilemap.set_cell(1, Vector2i(pos_x+g, pos_y), -1, Vector2i(-1, -1), -1)
				blocked_right = true
			elif right_block == Vector2i(4,0):
				blocked_right = true
			else:
				mapped_explosion.set_cell(0, Vector2i(pos_x+g, pos_y), 1, Vector2i(1, 3), 0)
				
		if blocked_left == false:
			var left_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x-g, pos_y))
			if left_block == Vector2i(0,2):
				mapped_explosion.set_cell(0, Vector2i(pos_x-g, pos_y), 1, Vector2i(1, 3), 0)
				tilemap.set_cell(1, Vector2i(pos_x-g, pos_y), -1, Vector2i(-1, -1), -1)
				blocked_left = true
			elif left_block == Vector2i(4,0):
				blocked_left = true
			else:
				mapped_explosion.set_cell(0, Vector2i(pos_x-g, pos_y), 1, Vector2i(1, 3), 0)
		
		if blocked_up == false:
			var up_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x, pos_y+g))
			if up_block == Vector2i(0,2):
				mapped_explosion.set_cell(0, Vector2i(pos_x, pos_y+g), 1, Vector2i(0, 3), 0)
				tilemap.set_cell(1, Vector2i(pos_x, pos_y+g), -1, Vector2i(-1, -1), -1)
				blocked_up = true
			elif up_block == Vector2i(4,0):
				blocked_up = true
			else:
				mapped_explosion.set_cell(0, Vector2i(pos_x, pos_y+g), 1, Vector2i(0, 3), 0)
		
		if blocked_down == false:
			var down_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x, pos_y-g))
			if down_block == Vector2i(0,2):
				mapped_explosion.set_cell(0, Vector2i(pos_x, pos_y-g), 1, Vector2i(0, 3), 0)
				tilemap.set_cell(1, Vector2i(pos_x, pos_y-g), -1, Vector2i(-1, -1), -1)
				blocked_down = true
			elif down_block == Vector2i(4,0):
				blocked_down = true
			else:
				mapped_explosion.set_cell(0, Vector2i(pos_x, pos_y-g), 1, Vector2i(0, 3), 0)
		
	get_tree().root.get_node("GameRoom").add_child(mapped_explosion)

func refill_bomb():
	bombs_placed_amount-=1
		
func get_player_position_on_map():
	return tilemap.local_to_map(position)

func _process(delta):
	
	var direction = 0
	
	
	get_movement(delta)
	change_facing_direction()
	place_bomb()
	
	
