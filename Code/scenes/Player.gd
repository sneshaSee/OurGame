extends CharacterBody2D

@export var speed = 200

var can_input = true;
var stun_timer = 0.0;

# oxygen variables
var oxygen;
var max_oxygen = 100.00;
var drain_rate = 16.0;
var recovery_rate = 20.0;

#mask variables
var toggle_mask = true;
var can_change_mask = true;
@onready var mask_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	oxygen = max_oxygen;

func _physics_process(delta):
	
	#mask input
	if can_change_mask == true: 
		if(Input.is_action_just_pressed("mask")):
			mask_audio.play()
			toggle_mask = !toggle_mask
	
	if(toggle_mask == true):
		oxygen = oxygen - drain_rate * delta
	else:
		oxygen = oxygen + recovery_rate * delta
	
	if oxygen <= 0 and can_input == true:
		can_input = false
		mask_audio.play()
		toggle_mask = !toggle_mask
		stun_timer = 2.0;
	
	if can_input == false:
		stun_timer -= delta
		can_change_mask = false
		if stun_timer <= 0.0:
			can_input = true;
			can_change_mask = true
			
	
	oxygen = clamp(oxygen, 0.0, max_oxygen)
		
	#movement 
	var direction := Vector2.ZERO
	
	if can_input == true:
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
