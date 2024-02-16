extends TileMap



# Called when the node enters the scene tree for the first time.
func _ready():
	var destructable_cells = get_used_cells_by_id(1,0,Vector2i(0,2), 0)
	for cell in destructable_cells:
		set_cell(1,cell,0,Vector2i(randi_range(0,4),2),0)


func destroy_cell(cell):
	set_cell(1, cell, -1, Vector2i(-1, -1), -1)
	var drop_index = randi_range(0,5)
	if drop_index <= 2:
		var drop = preload("res://DroppedUpgrade.tscn").instantiate()
		drop.set_position_on_map(cell)
		get_tree().root.get_node("GameRoom").add_child(drop)
		pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

