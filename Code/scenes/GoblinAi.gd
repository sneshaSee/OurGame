extends CharacterBody2D

@export var speed = 120.0
@export var chase_speed = 300.0
@export var arrive_distance = 6.0

@export var caught = false

#can see player logic
@onready var ray: RayCast2D = $RayCast2D

@export var point_a: Vector2
@export var point_b: Vector2
@export var player_path: NodePath

@onready var vision_area: Area2D = $VisionArea

var player: CharacterBody2D
var going_to_b := true
var player_in_vision = false

var point_index: int = 0

enum State { PATROL, CHASE }
var state = State.PATROL

func _ready() -> void:
	player = get_node(player_path) as CharacterBody2D

func _physics_process(_delta):
	if player_in_vision and player.toggle_mask == false and _has_line_of_sight():
		state = State.CHASE
	else:
		state = State.PATROL
	match state:
		State.PATROL:
			patrol()
		State.CHASE:
			chase()

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == player and state == State.CHASE:
			caught = true			
	
	if caught == true:
		get_node("../GameOverUi").game_over()
		
func patrol():
	var target = point_b if going_to_b else point_a
	var to_target = target - global_position
	
	if to_target.length() <= arrive_distance:
		going_to_b = !going_to_b
		return
	
	velocity = to_target.normalized() * speed
	
func chase():
	if(player.toggle_mask == true):
		state = State.PATROL
		return
	
	var to_player = player.global_position - global_position
	velocity = to_player.normalized() * chase_speed

	
func _on_VisionArea_body_entered(body):
	if body == player:
		player_in_vision = true

func _on_VisionArea_body_exited(body):
	if body == player:
		player_in_vision = false

func _has_line_of_sight():
	#aim the ray at the player
	ray.target_position = to_local(player.global_position)
	ray.force_raycast_update()
	
	# if it hits something make sure its the player
	if ray.is_colliding():
		return ray.get_collider() == player
	
	# if nothing blocks it, it can see
	return true;

	
