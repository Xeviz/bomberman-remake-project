extends CharacterBody2D
var type = randi_range(0,2)

func _ready():
	get_node("CollisionShape2D").disabled = true
	if type == 0:
		get_node("AnimatedSprite2D").play("amount")
	elif type == 1:
		get_node("AnimatedSprite2D").play("range")
	elif type == 2:
		get_node("AnimatedSprite2D").play("speed")
		
func set_position_on_map(cell):
	position.x = (cell.x*50)+25
	position.y = (cell.y*50)+25
	

func _physics_process(delta):
	

	pass
