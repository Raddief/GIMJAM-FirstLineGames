@tool
extends StyleBox
class_name StyleBoxStacked

@export var style_boxes: Array[StyleBox] :
	set(value):
		style_boxes = value
		for c in style_boxes:
			if c == null: continue
			if not c.changed.is_connected(emit_changed): 
				c.changed.connect(emit_changed)
		emit_changed()

func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	for style_box in style_boxes:
		if style_box:
			style_box.draw(to_canvas_item, rect)
