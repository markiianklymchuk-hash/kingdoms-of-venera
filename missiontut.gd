extends Control

var camera
var text = {
	"0" = "First of all, we need to be able to gather resources. Select the worker that is highlighted",
	"1" = "Press the gather button on the control card.",
	"2" = "Press on any one of the trees.",
	"3" = "Now you gather lumber. However, you need more workers. select the command centre.",
	"4" = "Press on the worker button on the contol card. After a few seconds, you will have a new worker",
	"5" = "",
	"6" = "The enemy comes! But we can defeat him. Press the multiselect button and drag a box over your warriors. then, press the attack button and click on the enemy.",
	"7" = "Now let's build a farm. Select the highligted worker",
	"8" = "Press the build button",
	"9" = "Press the farm button and choose a position",
	"10" = "Drag the camera around to see. You now know the basics, have fun!",
}
func _ready():
	camera = get_parent().get_parent().get_node("Camera")
func _draw():
	$tuttext.text = text[str(get_parent().get_parent().tutorial_phase)]
	if get_parent().get_parent().tutorial_phase == 0:
		draw_circle(get_tree().get_first_node_in_group("tut1").global_position - camera.global_position + Vector2(576, 324), get_tree().get_first_node_in_group("tut1").unit[get_tree().get_first_node_in_group("tut1").type]["size"] * 3/2, Color("ffff00ff"), false, 2)
	if get_parent().get_parent().tutorial_phase == 3:
		draw_circle(get_tree().get_first_node_in_group("tut2").global_position - camera.global_position + Vector2(576, 324), get_tree().get_first_node_in_group("tut2").unit[get_tree().get_first_node_in_group("tut2").type]["size"] * 3/2, Color("ffff00ff"), false, 4)
	if get_parent().get_parent().tutorial_phase == 7:
		draw_circle(get_tree().get_first_node_in_group("tut4").global_position - camera.global_position + Vector2(576, 324), get_tree().get_first_node_in_group("tut4").unit[get_tree().get_first_node_in_group("tut4").type]["size"] * 3/2, Color("ffff00ff"), false, 2)
