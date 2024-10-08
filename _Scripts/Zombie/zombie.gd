extends CharacterBody3D


var player = null
var state_machine

const SPEED = 3.0
const DAMAGE = 3.0
const ATTACK_RANGE = 2

@export var player_path := "/root/Main/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Replace with function body.
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Zombie-Walk":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
		"Zombie-Attack": 
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# CONDITIONS
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.get("parameteters/playback")
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


# DE ADAUGAT: DAMAGE → transmite dmg jucatorului
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, DAMAGE)
	
	
