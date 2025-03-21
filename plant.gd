
extends Node2D
class_name Plant

@export var genes: Vector3

signal plant_clicked(tile:Vector3i)

var tile: Vector3i

var highlighted: bool = false
var selected: bool = false


var baby: bool
var new_baby : bool

func gene_to_modulate(gene:float, which:int):
	var model: Vector3 = Vector3.ZERO
	var white = Color(1,1,1)
	var red = Color(1,0,0)
	var blue = Color(0,1,0)
	var green = Color(0,0,1)
	var teal = Color(0,1,1)
	var yellow = Color(1,0,1)
	var purple = Color(1,1,0)
	var primaries:Array[Color] = [red,blue,green]
	var secondaries:Array[Color] = [teal, yellow, purple]
	var mode : String
	var strength:float = abs(gene)
	if gene > 0:
		return white.lerp(primaries[which], strength)
	else:
		return white.lerp(secondaries[which], strength)
		

func set_gene_expression():
	$AdultParts/LeftFlower.modulate = gene_to_modulate(genes.x, 0)
	$AdultParts/CenterFlower.modulate = gene_to_modulate(genes.y, 1)
	$AdultParts/RightFlower.modulate = gene_to_modulate(genes.z, 2)
	
	if genes.x > 0:
		%FireProgress.value = genes.x * 100
		%IceProgress.value = 0.
	else:
		%FireProgress.value = 0.
		%IceProgress.value = -genes.x * 100
	if genes.y > 0:
		%NatureProgress.value = genes.y * 100
		%MagicProgress.value = 0.
	else:
		%NatureProgress.value = 0.
		%MagicProgress.value = -genes.y * 100
	if genes.z > 0:
		%WaterProgress.value = genes.z * 100
		%EarthProgress.value = 0.
	else:
		%WaterProgress.value = 0.
		%EarthProgress.value = -genes.z * 100

func _ready():
	set_gene_expression()
	$AdultParts.visible = false
	baby = true
	$TooltipLayer.visible = false

func grow_up():
	$AdultParts.visible = true
	baby = false

func select()->void:
	selected=true
	
func deselect() -> void:
	selected = false
	modulate = Color.WHITE
	
func start_highlight() -> void:
	%HighlightCursor.emitting=true
	highlighted=true
	
func stop_highlight()-> void:
	highlighted=false
	%HighlightCursor.emitting = false
	

func _on_area_2d_mouse_entered():
	if not baby:
		$TooltipLayer.visible = true
		$TooltipLayer/Tooltip.position = position


func _on_area_2d_mouse_exited():
	$TooltipLayer.visible = false
	

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and not baby:
		plant_clicked.emit(tile)

func _process(delta):
	if highlighted:
		%HighlightPath.progress_ratio = $HighlightTimer.time_left
	if selected:
		var lerp_percent : float
		if $CursorTimer.time_left < $CursorTimer.wait_time/2:
			lerp_percent = $CursorTimer.time_left/($CursorTimer.wait_time/2)
		else:
			lerp_percent = ($CursorTimer.wait_time - $CursorTimer.time_left)/($CursorTimer.wait_time/2)
		modulate = Color.DARK_SLATE_GRAY.lerp(Color.WHITE, lerp_percent)
