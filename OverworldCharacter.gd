class_name OverworldCharacter extends KinematicBody2D

const SPEED_FACTOR := 12
enum States {IDLE, RUN}

export(int) var acceleration := 10
export(int) var max_speed := 15
export(String) var character_name := "Default"

var _state = States.IDLE
var velocity := Vector2.ZERO

export(NodePath) onready var animPlayer = get_node(animPlayer) as AnimationPlayer
export(NodePath) onready var sprite = get_node(sprite) as Sprite

onready var animTree :AnimationTree = $AnimationTree
onready var animState :AnimationNodeStateMachinePlayback = animTree.get("parameters/StateMachine/playback")
onready var animStateMachine :AnimationNodeStateMachine = animTree.tree_root.get_node("StateMachine")

func _ready() -> void:
	sprite.texture = AnimationLibrary.CharacterAnimations[character_name]["Idle"]
	animTree.set("parameters/StateMachine/Idle/blend_position", Vector2(0,1))
	animTree.set("parameters/StateMachine/Run/blend_position", Vector2(0,1))
	AnimationLibrary.create_character_animations(self)
	

func _get_direction() -> Vector2:
	return Vector2(
		(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
func _physics_process(delta: float) -> void:
	var input_vector := _get_direction()
	if _state == States.RUN:
		animTree.set("parameters/StateMachine/Idle/blend_position", input_vector)
		animTree.set("parameters/StateMachine/Run/blend_position", input_vector)
		animState.travel("Run")
		
		velocity += input_vector * acceleration * delta * SPEED_FACTOR
		velocity = velocity.clamped(max_speed * delta * SPEED_FACTOR)
		
	else:
		animState.travel("Idle")
		velocity = Vector2.ZERO
	
	move_and_collide(velocity)

func _input(event :InputEvent) -> void:
	if event:
		if _get_direction() != Vector2.ZERO:
			self._state = States.RUN
		else:
			self._state = States.IDLE
	_set_sprite_sheet(_state)

func _set_sprite_sheet(state :int) -> void: ## Sets the sprite sheet for the given state
	sprite.texture = AnimationLibrary.CharacterAnimations[character_name][States.keys()[state].capitalize()]
