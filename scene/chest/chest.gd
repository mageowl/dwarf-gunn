extends Area2D

var _open := false

func _on_body_entered(body: Node2D) -> void:\
	if body is Player and not _open:
		body.explosive_ammo = 2
		
		$GPUParticles2D.emitting = true
		$Sprite2D.frame = 1
		$AudioStreamPlayer.play()
		_open = true
