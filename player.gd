extends CharacterBody2D

var DESTRUCTIBLE_BLOCKS = [Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2), Vector2i(4,2)]
var speed = 100.0
var bombs_range = 1
var bombs_limit = 1
var bombs_placed_amount = 0
var player_map_position = Vector2i(0,0)
var alive = true
var current_animation = "idle"





# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var tilemap = get_tree().root.get_node("GameRoom").get_node("GameMap")
@onready var placing_bomb_sound = $PlacingBombSound
@onready var explosion_sound = $ExplosionSound
@onready var pick_up_sound = $PickUpSound
@export var bomb : PackedScene
@export var explosion_map : PackedScene

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	placing_bomb_sound.volume_db = -5
	pick_up_sound.volume_db = -10

func play_pick_up_sound():
	var new_pick_up_sound = pick_up_sound.duplicate()
	add_child(new_pick_up_sound)
	new_pick_up_sound.play()

func upgrade_speed():
	play_pick_up_sound()
	speed += 25.0

func upgrade_amount():
	play_pick_up_sound()
	bombs_limit += 1

func upgrade_range():
	play_pick_up_sound()
	bombs_range += 1

func change_facing_direction():
	if Input.is_action_pressed("ui_left"):
		current_animation = "left_animation"
		get_node("AnimatedSprite2D").play(current_animation)
	elif Input.is_action_pressed("ui_right"):
		current_animation = "right_animation"
		get_node("AnimatedSprite2D").play(current_animation)
	elif Input.is_action_pressed("ui_up"):
		current_animation = "up_animation"
		get_node("AnimatedSprite2D").play(current_animation)
	elif Input.is_action_pressed("ui_down"):
		current_animation = "down_animation"
		get_node("AnimatedSprite2D").play(current_animation)
	else:
		current_animation = "idle_animation"
		get_node("AnimatedSprite2D").play(current_animation)
	

func get_movement(delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
		global_position += velocity * delta
		#print(global_position)
		#print(name)
		move_and_slide()
	player_map_position = tilemap.local_to_map(global_position)
	
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	

func try_to_place_bomb():
	if Input.is_action_just_pressed("bomb_placed") and bombs_placed_amount < bombs_limit:
		bombs_placed_amount+=1
		placing_bomb_sound.play()
		var spawn_position = tilemap.map_to_local(player_map_position)
		place_bomb.rpc(spawn_position, bombs_range)
		
@rpc("any_peer", "call_local")
func place_bomb(spawn_pos, range):
	for i in GameManager.players:
		print(GameManager.players[i].name)
	var player_bomb = bomb.instantiate()
	player_bomb.global_position = spawn_pos
	player_bomb.bomb_range = range
	player_bomb.player_name = name
	get_tree().root.add_child(player_bomb)
	
		
func generate_explosion(exploding_bomb, explosion_range):
	var map_spawn_position = tilemap.local_to_map(exploding_bomb.global_position)
	var pos_x = map_spawn_position.x
	var pos_y = map_spawn_position.y
	var blocked_left = false
	var blocked_right = false
	var blocked_up = false
	var blocked_down = false
	
	var explosion_cells = [Vector2i(3, 3)]
	var explosion_coords = [map_spawn_position]
	
	
	
	
	for g in range(1, explosion_range+1):
		
		if blocked_right == false:
			var right_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x+g, pos_y))
			if right_block in DESTRUCTIBLE_BLOCKS:
				blocked_right = true
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x+g, pos_y))
			elif right_block == Vector2i(4,0):
				blocked_right = true
			elif Vector2i(pos_x+g, pos_y) == player_map_position:
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x+g, pos_y))
			else:
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x+g, pos_y))
				
		if blocked_left == false:
			var left_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x-g, pos_y))
			if left_block in DESTRUCTIBLE_BLOCKS:
				blocked_left = true
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x-g, pos_y))
			elif left_block == Vector2i(4,0):
				blocked_left = true
			elif Vector2i(pos_x-g, pos_y) == player_map_position:
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x-g, pos_y))
			else:
				explosion_cells.append(Vector2i(1, 3))
				explosion_coords.append(Vector2i(pos_x-g, pos_y))
		
		if blocked_up == false:
			var up_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x, pos_y+g))
			if up_block in DESTRUCTIBLE_BLOCKS:
				blocked_up = true
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y+g))
			elif up_block == Vector2i(4,0):
				blocked_up = true
			elif Vector2i(pos_x, pos_y-g) == player_map_position:
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y+g))
			else:
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y+g))
		
		if blocked_down == false:
			var down_block = tilemap.get_cell_atlas_coords(1, Vector2i(pos_x, pos_y-g))
			if down_block in DESTRUCTIBLE_BLOCKS:
				blocked_down = true
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y-g))
			elif down_block == Vector2i(4,0):
				blocked_down = true
			elif Vector2i(pos_x, pos_y-g) == player_map_position:
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y-g))
			else:
				explosion_cells.append(Vector2i(0, 3))
				explosion_coords.append(Vector2i(pos_x, pos_y-g))
	generate_explosion_for_others.rpc(explosion_cells, explosion_coords)
	

@rpc("any_peer","call_local")
func generate_explosion_for_others(explosion_atlas, explosion_cords):
	var mapped_explosion = explosion_map.instantiate()
	var new_explosion_sound = explosion_sound.duplicate()
	add_child(new_explosion_sound)
	new_explosion_sound.play()
	for i in range(len(explosion_atlas)):
		var block = tilemap.get_cell_atlas_coords(1, explosion_cords[i])
		for g in GameManager.players:
			if GameManager.players[g].map_position == explosion_cords[i]:
				print("ktoś zdechł " , GameManager.players[g].id)
				get_tree().root.get_node("GameRoom").get_node(str(GameManager.players[g].id)).die()
		if block in DESTRUCTIBLE_BLOCKS:
			tilemap.destroy_cell(explosion_cords[i])
		mapped_explosion.set_cell(0, explosion_cords[i], 1, explosion_atlas[i], 0)
	get_tree().root.get_node("GameRoom").add_child(mapped_explosion)

func refill_bomb():
	bombs_placed_amount-=1
		
func get_player_position_on_map():
	return player_map_position
	
func send_my_position_to_manager():
	for i in GameManager.players:
		if(str(GameManager.players[i].id) == name):
			GameManager.players[i].map_position = get_player_position_on_map()
			
			

func die():
	current_animation = "death_animation"
	get_node("AnimatedSprite2D").play(current_animation)
	alive = false
	

func _process(delta):
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		if alive:
			get_movement(delta)
			change_facing_direction()
			try_to_place_bomb()
			send_my_position_to_manager()
		else:
			get_node("CollisionShape2D").disabled = true 
		
	
	
	
	
