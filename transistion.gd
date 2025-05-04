@tool
class_name Transition extends ColorRect

@export var fade_in_delay := 0.0
@export var fade_in_duration := 2.0
@export var fade_out_duration := 1.0

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	color = Color.BLACK
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if Engine.is_editor_hint():
		visible = false
	else:
		visible = true
		size = get_viewport_rect().size
		fade_in()

func fade_out() -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "color", Color.BLACK, fade_out_duration)
	return tween.finished
func fade_in() -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "color", Color(Color.BLACK, 0), fade_in_duration).set_delay(fade_in_delay)
	return tween.finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
