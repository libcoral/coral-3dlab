Type "eigen.Vec3"
{
	x = "double",
	y = "double",
	z = "double"
	
}

Type "eigen.Quat"
{
	x = "double",
	y = "double",
	z = "double",
	w = "double"
}

Type "lab3d.dom.BoundingBox"
{
	min = "eigen.Vec3",
	max = "eigen.Vec3",
	center = "eigen.Vec3"	
}

Type "co.IService"
{
}

Type "lab3d.scene.IModel"
{
	filename = "string"
}

Type "lab3d.scene.Model"
{
	model = "lab3d.scene.IModel"
}

Type "lab3d.dom.IEntity"
{
	name = "string",
	visible = "bool",
	scale = "eigen.Vec3",
	position = "eigen.Vec3",
	orientation = "eigen.Quat",
	bounds = "lab3d.dom.BoundingBox",
	decorators = "co.IService[]"
}

Type "lab3d.dom.Entity"
{
	entity = "lab3d.dom.IEntity"
}

Type "lab3d.dom.IView"
{
	position = "eigen.Vec3",
	orientation = "eigen.Quat"
}

Type "lab3d.dom.View"
{
	view = "lab3d.dom.IView"
}

Type "lab3d.dom.IProject"
{
	currentView = "lab3d.dom.IView",
	entities = "lab3d.dom.IEntity[]",
	selectedEntity = "lab3d.dom.IEntity",
	name = "string"
}

Type "lab3d.dom.Project"
{
	project = "lab3d.dom.IProject"
}