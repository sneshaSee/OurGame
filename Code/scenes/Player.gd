extends CharacterBody2D

@export var speed = 200

# oxygen variables
var oxygen;
var max_oxygen = 100.00;
var drain_rate = 10.0;
var recovery_rate = 20.0;
var toggle_mask = true;


func _ready() -> void:
	oxygen = max_oxygen;

func _physics_process(delta):
	
	#mask input
	if(Input.is_action_just_pressed("mask")):
		toggle_mask = !toggle_mask
	
	if(toggle_mask == true):
		oxygen = oxygen - drain_rate * delta
	else:
		oxygen = oxygen + recovery_rate * delta
		
	oxygen = clamp(oxygen, 0.0, max_oxygen)
		
	#movement 
	var direction := Vector2.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()
