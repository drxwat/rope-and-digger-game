extends HBoxContainer

var heart_empty := preload("res://assets/heart_empty.png")
var heart_full := preload("res://assets/heart_full.png")

var is_initilized := false

func _initialize(hp):
	for i in range(hp):
		var texture_rect = TextureRect.new()
		texture_rect.expand = true
		texture_rect.rect_min_size = Vector2(39, 39)
		texture_rect.size_flags_horizontal = SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = SIZE_EXPAND_FILL
		texture_rect.texture = heart_full
		add_child(texture_rect)
	is_initilized = true
	
func update_health(value):
	if not is_initilized:
		_initialize(value)
	for i in get_child_count():
		var child = get_child(i)
		if value >= i + 1:
			child.texture = heart_full
		else:
			child.texture = heart_empty
