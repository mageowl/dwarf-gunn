extends Control

var score1 := 0
var score2 := 0

func set_score(id: int, score: int) -> void:
	match id:
		0:
			%Score1.text = "%d\npoints" % score
			score1 = score
		1:
			%Score2.text = "%d\npoints" % score
			score2 = score
	
	if score1 > score2:
		%Winner1.visible = true
		%Winner2.visible = false
	elif score1 < score2:
		%Winner1.visible = false
		%Winner2.visible = true
	else:
		%Winner1.visible = false
		%Winner2.visible = false
