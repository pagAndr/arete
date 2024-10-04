extends CharacterBody3D
#------Animations name constants----------
const walking_animation = "walking"
const running_animation = "running"
const idle_animation = "idle"
const attack_animation = "kick"
#-----------------------------------------
const HIT_STAGGER = 7.0

@onready var camera_ref_point: Node3D = $Camera_ref_point
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals

# PLAYER TELLING SOMEONE IT WAS HIT
signal player_hit

var SPEED = 3.0
const JUMP_VELOCITY = 4.5

var is_running = false

#Vom folosi pentru a bloca mișcarea jucătorului în timpul unei actiune de atac
var is_locked = false

@export var walking_speed = 3.0
@export var running_speed = 5.0

@export var mouse_sens_horizontal = 0.5
@export var mouse_sens_vertical = 0.3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * mouse_sens_horizontal))
		camera_ref_point.rotate_x(deg_to_rad(-event.relative.y * mouse_sens_vertical))

func _physics_process(delta: float) -> void:
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		if animation_player.current_animation != attack_animation:
			animation_player.play(attack_animation)
			is_locked = true
			
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		is_running = true
	else:
		SPEED = walking_speed
		is_running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if is_running:
				if animation_player.current_animation != running_animation:
					animation_player.play(running_animation)
			else:
				if animation_player.current_animation != walking_animation:
					animation_player.play(walking_animation)
			#Rotește vizualul playerului destul de smooth, fără a afecta rotația înuși a nodeului player.
			visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(-input_dir.x, -input_dir.y) , delta * 10)		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != idle_animation:
				animation_player.play(idle_animation);
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


	if !is_locked:
		move_and_slide()
		
func hit(dir):
		emit_signal("player_hit")
		velocity += dir * HIT_STAGGER
