extends Node2D

var _transition := false

# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event.is_action("restart") and not _transition:
		_transition = true
		$StartSound.play()
		await $Interface/Transition.fade_out()
		get_tree().change_scene_to_file("res://scene/game/game.tscn")


func _on_help_button_pressed() -> void:
	%TabContainer.current_tab = (%TabContainer.current_tab + 1) % 2
