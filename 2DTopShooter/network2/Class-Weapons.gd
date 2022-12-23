extends Control

func _on_weaponbut1_pressed():
	Global.primary = 1

func _on_weaponbut2_pressed():
	Global.primary = 2

func _on_weaponbut3_pressed():
	Global.primary = 3

func _on_Sweaponbut1_pressed():
	Global.secondary = 1

func _on_Sweaponbut2_pressed():
	Global.secondary = 2

func _on_classbut1_pressed():
	Global.frame = 1

func _on_classbut2_pressed():
	Global.frame = 2

func _on_classbut3_pressed():
	Global.frame = 3
