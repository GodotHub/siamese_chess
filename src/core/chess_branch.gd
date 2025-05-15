extends Object
class_name ChessBranch

class ChessBranchNode:
	var state:ChessState = null
	var group:int = 0
	var time:float = 0	# 节点添加时的时间，可以根据父节点和当前节点的时间差来求出思考时间
	var children:Dictionary[String, ChessBranchNode] = {}
	var dead:bool = false # 当前着法出现吃王情况时，标记父节点和本身为dead，没有活的子节点，判定棋局结束
	var score:float = 0	# 这里的score并非ChessState的Score，是经过搜索后相对不片面的评分
	var parent:ChessBranchNode = null

var branch:ChessBranchNode = null	# 树形结构，只包含步数
var current_node:ChessBranchNode = null
func _init() -> void:
	branch = ChessBranchNode.new()
	current_node = branch
	current_node.time = Time.get_unix_time_from_system()

func set_state(_state:ChessState) -> void:
	if !is_instance_valid(_state):
		return
	current_node.state = _state
	current_node.group = _state.step % 2

func get_state() -> ChessState:
	return current_node.state

func create_branch(node:ChessBranchNode, move:Move) -> ChessBranchNode:
	var test_state:ChessState = node.state.duplicate()
	var group:int = test_state.get_piece(move.position_name_from).group
	test_state.execute_move(move)
	var next_branch_node:ChessBranchNode = ChessBranchNode.new()
	next_branch_node.state = test_state
	next_branch_node.time = Time.get_unix_time_from_system()
	next_branch_node.parent = node
	next_branch_node.group = 1 if group == 0 else 0
	node.children[move.stringify()] = next_branch_node
	if test_state.score > 100 || test_state.score < -100:
		node.dead = true
		next_branch_node.dead = true
		# TODO: 可以搜一下空着，空着没有吃王则判定逼和
	set_score(next_branch_node, test_state.score)
	return next_branch_node

func execute_move(move:Move) -> void:
	if current_node.children.has(move.stringify()):
		current_node = current_node.children[move.stringify()]
	else:
		current_node = create_branch(current_node, move)

func search(current_branch_node:ChessBranchNode = null, depth:int = 2) -> void:
	if !is_instance_valid(current_branch_node):
		current_branch_node = current_node
	var move_list:Array[Move] = current_branch_node.state.get_all_move(current_branch_node.group)
	for move:Move in move_list:
		if !current_branch_node.children.has(move.stringify()):
			create_branch(current_branch_node, move)
		if depth && !current_branch_node.dead:	# 死棋不用继续搜
			search(current_branch_node.children[move.stringify()], depth - 1)

func set_score(branch_node:ChessBranchNode, score:float, is_leaf:bool = true) -> void:
	if is_leaf || branch_node.group == 1 && score < branch_node.score || branch_node.group == 0 && score > branch_node.score:
		branch_node.score = score
		if is_instance_valid(branch_node.parent):
			set_score(branch_node.parent, score, false)

func get_best_move() -> Move:
	var best_move:Move = null
	for iter:String in current_node.children:
		if !current_node.children[iter].dead && (!is_instance_valid(best_move) || current_node.group == 1 && current_node.children[iter].score < current_node.children[best_move.stringify()].score || current_node.group == 0 && current_node.children[iter].score > current_node.children[best_move.stringify()].score):
			best_move = Move.parse(iter)
	print_score(current_node)
	return best_move

func print_score(branch_node:ChessBranchNode, depth:int = 0) -> void:
	for iter_str:String in branch_node.children:
		var iter_move:Move = Move.parse(iter_str)
		print(" ".repeat(depth) + iter_move.position_name_from + iter_move.position_name_to + ": " + ("%f" % branch_node.children[iter_str].score))
		#print_score(branch_node.children[iter], depth + 1)
	print("-----")
