# AutoAnimationCreatorDEMO
Automatically generates animations in Godot for 2D sprites

This project shows you how to implement an automated animation creation system for your 2D games in Godot.

Please feel free to download, use, and modify this project, but please do not redistribute it as your own, because I worked hard on this and you're probably a cool person who doesn't take credit for other peoples' work, right?  Sweet!


## For this sytem to work as-is, you must:

1.Create a spritesheet for your animation.
  - All sprites in this spritesheet should be the same dimensions, which means that you should probably pad your artwork in some empty pixels so that there's room for your chracters to move without changing the size of the sprite itself.
    - For example: sprites in the hastily thrown together sample sprites here are all 96 x 96 pixels, but the circle and square are only 64x64 pixels.  There's a 16 pixel transparent border around them at all times.
  - The frames should go left to right for a single direction of the animation, and the full animation for the given direction should be on the same line.
    - For example: All of the frames for your RunSouth animation should be in the first row of your spritesheet.
  - The order of animations should be, from top to bottom: South, Southeast, East, Northeast, North, Northwest, West, Southwest
    - This is the order they are added and assigned to the blend tree in the current code.  You can modify this in the `create_character_animations()` function if you want to.

2.Fill in the Godot Sheet with the file name.
  - Ensure that the `CHARACTER_SPRITESHEETS_PATH` points to the directory where you store your assets.
  - The name of the character (which should match the exported `charater_name` variable on `OverworldCharacter.gd`) goes into the row label.
  - The name of the animation goes into the column label.
  - The file name of the animation goes into the approrpiate cell in the table.
    - For example: Default's Run cycle file name is `DefaultRun.png`, so I paste that into the `Run` column in the `Default` row.
  
3.If your sprites look strange or you get errors, check the following:
  - Ensure that the `CHARACTER_SPRITESHEETS_PATH` points to the directory where you store your assets.
  - Ensure that the `DEFAULT_CHARACTER_SPRITE_SIZE` matches your sprite size (inlcuding the added transparent pixels).
  - Ensure that `CHARACTER_ANIMATIONS_LIBRARY`'s value matches the name of your Godot Sheet.

4. EXTRAS:
  - If you want to add new tracks to the aniamtions, you would do so in the `create_character_animations()` function before the `character.animPlayer.add_animation()` call.
    - Define a track variable with the `var track_name := anim_to_add.add_track()` format.
    - Use that variable in a `anim_to_add.track_set_path(track_name, path)` call to set the pat for the track to use (i.e. what property to change, like rotation, size, etc.)
    - Use `anim_to_add_.track_set_key(track_path, timestamp, value)` to set up a keyframe at `timestamp` seconds (a float) with `value` parameters.

If you still have problems or you have questions about this, you can reach out to me in the [comment section where I posted this on Reddit](https://www.reddit.com/r/godot/comments/vh0yxj/i_automated_my_animation_setup_for_my_2d_pixel/).
I'm happy to help if I can.
