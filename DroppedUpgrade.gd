extends CharacterBody2D
var type
var bodies = []

func _ready():
	if type == 0:
		get_node("AnimatedSprite2D").play("amount")
	elif type == 1:
		get_node("AnimatedSprite2D").play("range")
	elif type == 2:
		get_node("AnimatedSprite2D").play("speed")
		
func set_position_on_map(cell):
	position.x = (cell.x*50)+25
	position.y = (cell.y*50)+25

func get_picked_up():
	if type == 0:
		bodies[0].upgrade_amount()
	elif type == 1:
		bodies[0].upgrade_range()
	elif type == 2:
		bodies[0].upgrade_speed()
	get_tree().root.get_node("GameRoom").remove_child(self)
	queue_free()

func _physics_process(delta):
	bodies = get_node("Area2D").get_overlapping_bodies()
	if bodies != []:
		get_picked_up()

	pass
