extends Node2D

var myWorld = {"Nodes" = [], "Towns" = [], "Routes" = []}

enum Dir{
	NORTH,
	EAST,
	SOUTH,
	WEST
}
class townNode:
	var name = "temp name"
	var neighbors = {} #N, E, S, W
	var level = -1
	var position = Vector2.ZERO
	
	func makeNeighbors(newNeighbor: townNode):
		if position.x == newNeighbor.position.x:
			if position.y > newNeighbor.position.y: #neighbor is NORTH
				self.neighbors[Dir.NORTH] = newNeighbor
				newNeighbor.neighbors[Dir.SOUTH] = self
			else: #SOUTH
				self.neighbors[Dir.SOUTH] = newNeighbor
				newNeighbor.neighbors[Dir.NORTH] = self
		elif position.x > newNeighbor.position.x: # WEST
			self.neighbors[Dir.WEST] = newNeighbor
			newNeighbor.neighbors[Dir.EAST] = self
		else: # EAST
			self.neighbors[Dir.EAST] = newNeighbor
			newNeighbor.neighbors[Dir.WEST] = self
			
		#self.neighbors.append(newNeighbor)
		#newNeighbor.neighbors.append(self)

class edge:
	var name = "temp name"
	var neighbors = []
	var level = -1

@export var townCount = 5
@export var routeCount = 5

var mapSize = 10; #map height and width

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minRoutesPerTown = routeCount / townCount - 1;
	var maxRoutesPerTown = minRoutesPerTown + (2 if townCount % routeCount > 0 else 1);
	var currentRouteCount = 0;
	
	mapSize = max(floor(townCount + (townCount / 25)), 5)
	#result is technically squared, since it's mapSize * mapSize total sqaures
	# also minimum map size of 5, so that we don't need to worry about
	# not having space for stuff
	
	var prevPosition = null
	for i in range(townCount):
		#Make a town
		var myTown = townNode.new()
		myTown.name = "Town num " + str(i);
		#if first town, place randomly. Otherwise, have the new town line up with another town
		if prevPosition == null:
			myTown.position = Vector2(randi() % mapSize,randi() % mapSize)
		else:
			var validSpots = range(mapSize)
			if randf() < 0.5:
				validSpots.pop_at(prevPosition.y)
				myTown.position = Vector2(prevPosition.x,validSpots[randi() % validSpots.size()])
			else:
				validSpots.pop_at(prevPosition.x)
				myTown.position = Vector2(validSpots[randi() % validSpots.size()], prevPosition.y)
		prevPosition = myTown.position
		myWorld["Nodes"].append(myTown)
		myWorld["Towns"].append(myTown)
		
		#Hook up to previous town
		if myWorld["Towns"].size() > 1:
			myTown.makeNeighbors(myWorld["Towns"][myWorld["Towns"].size() - 2])
			currentRouteCount += 1
		
		#add a route
		# Do only as other towns exist
		#for r in range(min(minRoutesPerTown, myWorld["Towns"].size() - 1)):
			##var myRoute = edge.new()
			##myRoute.edge = "Route " + str(i);
			## Obtain a range of possible options for towns to connect to...
			## Then cycle through them until you find a compatible town
			#var options = range(myWorld["Towns"].size() - 1);
			#while true:
				#var myRand = randi() % options.size();
				#if myWorld["Towns"][myRand].neighbors.size() < maxRoutesPerTown: # Internal max of 4 routes per town to keep sizes reasonable.
					#myTown.makeNeighbors(myWorld["Towns"][myRand])
					#currentRouteCount += 1
					#break;
				#else:
					#options.pop_at(myRand)
					#if options.size() <= 0: #stop trying to add a route if there's no valid place for a route
						#break;
		#print(myTown)
		#print(myTown.name)
		#print(myTown.neighbors)
		
	#Main setup is done. Add bonus routes for excess connectivity
	var options = range(myWorld["Towns"].size());
	print(currentRouteCount)
	for extraRoute in []:#range(routeCount - currentRouteCount):
		#maxRoutesPerTown
		var townA = obtainRandomValidNeighborNode(4, options)
		var townB = obtainRandomValidNeighborNode(4, options)
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
		for nextTown in town.neighbors.values():
			myWorldString += nextTown.name + ", "
		myWorldString += "]"
	print(myWorldString)
	
	draw_circle(myWorld["Towns"][0].position, 1, Color.AQUAMARINE)
	
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

func _draw():
	var drawScale = 2 * 50.0 * ( 5.0 / mapSize)
	var offset = Vector2(-250, -250)
	print(drawScale)
	print(mapSize)
	for x in range(mapSize + 1):
		# x used both as x and y. sry if it's weird
		draw_line(Vector2(x * drawScale, 0) + offset, \
					Vector2(x * drawScale, mapSize * drawScale) + offset, \
					Color.SLATE_GRAY)
		draw_line(Vector2(0, x * drawScale) + offset, \
					Vector2(mapSize * drawScale, x * drawScale) + offset, \
					Color.SLATE_GRAY)
		#for y in range(mapSize):
			#draw_line(Vector2(x * drawScale, y * drawScale), \
			#		Vector2(mapSize * drawScale, mapSize * drawScale), \
			#		Color.SLATE_GRAY)
	for town in myWorld["Towns"]:
		#draw_circle(town.position * 10, 10, Color.AQUAMARINE)
		for neighbor in town.neighbors.values():
			draw_line(town.position * drawScale + offset, neighbor.position * drawScale + offset,Color.FIREBRICK, drawScale / 5.0)
	
	for town in myWorld["Towns"]:
		draw_circle(town.position * drawScale + offset, drawScale / 3.0, Color.AQUAMARINE)
	#draw_circle(myWorld["Towns"][0].position, 100, Color.AQUAMARINE)
	print(myWorld["Towns"][0].position * drawScale + offset)
	draw_char(ThemeDB.fallback_font,(myWorld["Towns"][0].position + Vector2(-0.15,0.1)) * drawScale + offset \
			,"S",drawScale / 2,Color.BLACK)
	
	draw_char(ThemeDB.fallback_font,(myWorld["Towns"][myWorld["Towns"].size()-1].position + Vector2(-0.15,0.1)) * drawScale + offset \
			,"F",drawScale / 2,Color.BLACK)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
