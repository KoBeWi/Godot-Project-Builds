extends PackedScene
class_name Prefab

static func create(node: Node, deferred_free := false) -> Prefab:
	assert(node, "Invalid node provided.")
	
	var to_check := node.get_children()
	while not to_check.is_empty():
		var sub: Node = to_check.pop_back()
		if sub.owner == null:
			continue
		
		to_check.append_array(sub.get_children())
		sub.owner = node
	
	var prefab := Prefab.new()
	prefab.pack(node)
	
	if deferred_free:
		node.queue_free()
	else:
		node.free()
	
	return prefab
