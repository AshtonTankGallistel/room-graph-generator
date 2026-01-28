extends Node2D

var myWorld = {"Nodes" = [], "Towns" = [], "Routes" = []}

class townNode:
	var name = "temp name"
	var neighbors = []
	var level = -1
	
	func makeNeighbors(newNeighbor: townNode):
		self.neighbors.append(newNeighbor)
		newNeighbor.neighbors.append(self)

class edge:
	var name = "temp name"
	var neighbors = []
	var level = -1

@export var townCount = 20
@export var routeCount = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minRoutesPerTown = routeCount / townCount - 1;
	var maxRoutesPerTown = minRoutesPerTown + (2 if townCount % routeCount > 0 else 1);
	var currentRouteCount = 0;
	
	for i in range(townCount):
		#Make a town
		var myTown = townNode.new()
		myTown.name = "Town num " + str(i);
		myWorld["Nodes"].append(myTown)
		myWorld["Towns"].append(myTown)
		
		#add a route
		# Do only as other towns exist
		for r in range(min(minRoutesPerTown, myWorld["Towns"].size() - 1)):
			#var myRoute = edge.new()
			#myRoute.edge = "Route " + str(i);
			# Obtain a range of possible options for towns to connect to...
			# Then cycle through them until you find a compatible town
			var options = range(myWorld["Towns"].size() - 1);
			while true:
				var myRand = randi() % options.size();
				if myWorld["Towns"][myRand].neighbors.size() < maxRoutesPerTown: # Internal max of 4 routes per town to keep sizes reasonable.
					myTown.makeNeighbors(myWorld["Towns"][myRand])
					currentRouteCount += 1
					break;
				else:
					options.pop_at(myRand)
					if options.size() <= 0: #stop trying to add a route if there's no valid place for a route
						break;
		#print(myTown)
		#print(myTown.name)
		#print(myTown.neighbors)
		
	#Main setup is done. Add bonus routes for excess connectivity
	var options = range(myWorld["Towns"].size());
	print(currentRouteCount)
	for extraRoute in range(routeCount - currentRouteCount):
		#maxRoutesPerTown
		var townA = obtainRandomValidNeighborNode(maxRoutesPerTown, options)
		var townB = obtainRandomValidNeighborNode(maxRoutesPerTown, options)
		if townA != null and townB != null:
			townA.makeNeighbors(townB)
			#re-add the towns now that they're connected
			options.append(townA)
			options.append(townB)
			
			currentRouteCount += 1
		else:
			print("YOU MESSED UP THE MATH FOR NEIGHBORS.");
	
	
	print(myWorld)
	var myWorldString = "My World:"
	for town in myWorld["Towns"]:
		myWorldString += "\n" + town.name + "\n["
		for nextTown in town.neighbors:
			myWorldString += nextTown.name + ", "
		myWorldString += "]"
	print(myWorldString)
	
#Helper function, runs through nodes to find one that can have a neighbor, and pops any that can't from the list of options
func obtainRandomValidNeighborNode(maxNeighbors: int, intList: Array) -> townNode:
	while true:#intList.size() > 0:
		#Select town A and B at random to link
		var myRand = randi() % intList.size();
		if myWorld["Towns"][myRand].neighbors.size() < maxNeighbors: # Internal max of 4 routes per town to keep sizes reasonable.
			intList.pop_at(myRand)
			return myWorld["Towns"][myRand]
		else:
			intList.pop_at(myRand)
	return null #inaccessible, but prevents the program from complaining


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
