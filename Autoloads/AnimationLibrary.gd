extends Node2D

signal animation_library_built
signal animations_for_character_created

const CHARACTER_ANIMATIONS_LIBRARY := "CharacterAnimationsTable"  #This value is the name of a sheet created with the GDSheets plugin.  This is filled in with character_name on the rows, and animations on the columns
const CHARACTER_SPRITESHEETS_PATH := "res://Assets/Character/"  ## This is the path to you character sprite sheet assets
const MOVEMENT_ANIMATION_LENGTH := 0.8 ## The animaion's length n float seconds, which should be the same for all animations you want to use this on
const DEFAULT_CHARACTER_SPRITE_SIZE := Vector2(96,96) ## The default size for sprites, which should be the same on all animations

var _animations_database :Dictionary = GDSheets.sheet(CHARACTER_ANIMATIONS_LIBRARY)  ## Pulls the GDSheet as a Dictionary
var CharacterAnimations := {} ## This is the output variable that will hold the library once parsed

func _ready() -> void:
	if _parse_animation_information():
			emit_signal("animation_library_built")

func _parse_animation_information() -> bool:  ## Returns true when it has succesfully filled CharacterAnimations with data
	for character in _animations_database.keys():
	
		# Initialize animations library by key (character name)
		CharacterAnimations[character] = {}
		for animation_name in _animations_database[character].keys():
			if _animations_database[character][animation_name]:
				CharacterAnimations[character][animation_name] = load(CHARACTER_SPRITESHEETS_PATH + _animations_database[character][animation_name])
	if CharacterAnimations.empty():
		return false
	else:
		return true
	
func create_character_animations(character :OverworldCharacter) -> void:
	## This is the big one that actually creates yoru animations from the files and puts them into an AnimationPlayer and AnimationTree
	## It takes a character, which is an OverworldCharater class in my project as an argument.  The OverworldCharacter class inherits from KinematicBody2D
	## The character needs to have a Sprite called CharacterSprite, an AnimationTree, and an AnimationPlayer as children.
	## The character also needs a 'character_name' string variable that matches the character_name in the GDSheet
	## The AnimationTree node needs a StateMachine with animations and travel routes connected up.  There should be one node in the Statemachine for each animation defined in your GDSheet
	## This function references a 'Globals' autoload with a 'Directions' enum that defines the possible facings.
	
	for animation in CharacterAnimations[character.character_name]:
		var frame := 0
		for direction in Globals.Directions:
		
			# Determine animation name
			var anim_name :String = animation + direction.capitalize()
			
			# Define a new blank animation
			var anim_to_add := Animation.new()
			
			# Create the node properties tracks
			var vframes_track := anim_to_add.add_track(Animation.TYPE_VALUE)
			var hframes_track := anim_to_add.add_track(Animation.TYPE_VALUE)
			var frame_track := anim_to_add.add_track(Animation.TYPE_VALUE)
			var tracks := [vframes_track, hframes_track, frame_track]
			
			# Define the first timestamp in the animation
			var timestamp := 0.0
			
			# Determine the number of vertical frames (rows) in the spritesheet by diving the total height of the spritesheet by the DEFAULT_CHARACTER_SPRITE_SIZE.y
			var rows := int(character.sprite.texture.get_height() / DEFAULT_CHARACTER_SPRITE_SIZE.y)
			
			# Determine number of horizontal frames in the spritesheet by diving the total with of the spritesheet by the DEFAULT_CHARACTER_SPRITE_SIZE.x
			var columns := int(character.sprite.texture.get_width() / DEFAULT_CHARACTER_SPRITE_SIZE.x)
			
			
		# SET UP THE ANIMATION
			
			# Set the step
			anim_to_add.step = 0.1
			
			# Enable looping
			anim_to_add.loop = true
			
			# Set the animation length in float seconds
			anim_to_add.set_length(MOVEMENT_ANIMATION_LENGTH)
			
			# Set the update mode to discrete on applicable tracks
			for i in tracks.size():
				if anim_to_add.track_get_type(i) == Animation.TYPE_VALUE:
					anim_to_add.value_track_set_update_mode(i, Animation.UPDATE_DISCRETE)
			
			# Setting sprite h_frames
			anim_to_add.track_set_path(hframes_track, "CharacterSprite:hframes")
			anim_to_add.track_insert_key(hframes_track, timestamp, columns)
			
			# Setting sprite v_frames
			anim_to_add.track_set_path(vframes_track, "CharacterSprite:vframes")
			anim_to_add.track_insert_key(vframes_track, timestamp, rows)
			
			# Set animation keyframes
			anim_to_add.track_set_path(frame_track, "CharacterSprite:frame")
			for i in columns:
				# Uses the 'columns' variable calculated earlier, as all spritesheets should be formatted so that a column is a frame for the animation in a given direction
				anim_to_add.track_insert_key(frame_track, timestamp, frame)
				timestamp += 0.1
				frame += 1
			
			# Add the animation to the character's AnimationPlayer
			character.animPlayer.add_animation(anim_name, anim_to_add)
			
			
	# SET UP THE ANIMATION TREE AND BELND SPACES
	## Note that the AnimationTree should be pre-configured on the character's scene.
	## I accomplish this by using an OverworldCharacter base scene with the correct setup and making new inherited scenes from it
		
	# Pull a reference to the character's AnimationTree
	var animTree :AnimationTree = character.animTree
	
	# Pull a reference to the character's AnimationStateMachine
	var animStateMachine :AnimationNodeStateMachine = animTree.tree_root.get_node("StateMachine")
		
		# Initialize an array for the states
	var states := []
		
		
		# Set the 'states' array programatically to ensure that all states are accounted for as strings.
	for animation in CharacterAnimations[character.character_name]:
		states.append(str(animation))
		
		
	for state in states:
			
		# Pull a reference to the StateMachine node for the given state
		var node :AnimationNodeBlendSpace2D = animStateMachine.get_node(state)

		# Ensure autotriangles is enabled
		node.auto_triangles = true
		
		# Set blend mode to discrete
		node.blend_mode = AnimationNodeBlendSpace2D.BLEND_MODE_DISCRETE
		
		# ITERATION OVER DIRECTIONS TO CREATE BLEND POINTS
		for direction in Globals.Directions.values():
			
			# Create a new Animation blend point
			var blend_point = AnimationNodeAnimation.new()
			
			# Match statement to determine which point to set where and with which animation
			# This statement will default to a printed error if no direction was matched.
			match direction:

				Globals.Directions.SOUTH :
					node.add_blend_point(blend_point, Vector2(0,1), 0)
					node.get_blend_point_node(0).animation = state + "South"

				Globals.Directions.SOUTHEAST :
					node.add_blend_point(blend_point, Vector2(0.5,0.5), 1)
					node.get_blend_point_node(1).animation = state + "Southeast"
					
				Globals.Directions.EAST :
					node.add_blend_point(blend_point, Vector2(1,0), 2)
					node.get_blend_point_node(2).animation = state + "East"

				Globals.Directions.NORTHEAST :
					node.add_blend_point(blend_point, Vector2(0.5,-0.5), 3)
					node.get_blend_point_node(3).animation = state + "Northeast"

				Globals.Directions.NORTH :
					node.add_blend_point(blend_point, Vector2(0,-1), 4)
					node.get_blend_point_node(4).animation = state + "North"

				Globals.Directions.NORTHWEST :
					node.add_blend_point(blend_point, Vector2(-0.5,-0.5), 5)
					node.get_blend_point_node(5).animation = state + "Northwest"

				Globals.Directions.WEST :
					node.add_blend_point(blend_point, Vector2(-1,0), 6)
					node.get_blend_point_node(6).animation = state + "West"

				Globals.Directions.SOUTHWEST :
					node.add_blend_point(blend_point, Vector2(-0.5,0.5), 7)
					node.get_blend_point_node(7).animation = state + "Southwest"

				_:
					print("ERROR: no direction matched for assigning animations and blend points in ", state)
		
			# A yield to ensure that triangles are updating before moving on
			yield(node, "triangles_updated")
	
	# Emit a signal when the animations are finished.
	emit_signal("animations_for_character_created")
