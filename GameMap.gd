extends TileMap

@export var drop_upgrade : PackedScene
@onready var random_generator = RandomNumberGenerator.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	random_generator.seed = hash("Godot")
	generate_map()
	

func generate_map():
	var destructable_cells = get_used_cells_by_id(1,0,Vector2i(0,2), 0)
	
	
	for cell in destructable_cells:
		set_cell(1, cell, 0, Vector2i(get_random_number_range(0, 4), 2), 0)

func get_random_number_range(start, end):
	return random_generator.randi_range(start,end)

func destroy_cell(cell):
	set_cell(1, cell, -1, Vector2i(-1, -1), -1)
	var drop_index = get_random_number_range(0,5)
	if drop_index <= 2:
		drop_item.rpc(cell, drop_index)
		pass
		
@rpc("any_peer", "call_local")
func drop_item(cell, drop_index):
	var drop = drop_upgrade.instantiate()
	drop.type = drop_index
	drop.set_position_on_map(cell)
	get_tree().root.get_node("GameRoom").add_child(drop)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

