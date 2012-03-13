Type "glm.Vec3"
{
	x = "double",
	y = "double",
	z = "double"
	
}

Type "glm.Quat"
{
	x = "double",
	y = "double",
	z = "double",
	w = "double"
}

Type "lab3d.dom.BoundingBox"
{
	min = "glm.Vec3",
	max = "glm.Vec3",
	center = "glm.Vec3"	
}

Type "lab3d.dom.IEntity"
{
	name = "string",
	scale = "glm.Vec3",
	position = "glm.Vec3",
	orientation = "glm.Quat",
	bounds = "lab3d.dom.BoundingBox",	
	filename = "string"
}

Type "lab3d.dom.Entity"
{
	entity = "lab3d.dom.IEntity"
}

Type "lab3d.dom.IView"
{
	position = "glm.Vec3",
	orientation = "glm.Quat"
}

Type "lab3d.dom.View"
{
	view = "lab3d.dom.IView"
}

Type "lab3d.dom.IProject"
{
	currentView = "lab3d.dom.IView",
	entities = "lab3d.dom.IEntity[]",
	name = "string"
}

Type "lab3d.dom.Project"
{
	project = "lab3d.dom.IProject"
}