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

Type "lab3d.core.domain.BoundingBox"
{
	min = "glm.Vec3",
	max = "glm.Vec3",
	center = "glm.Vec3"	
}

Type "lab3d.core.domain.IEntity"
{
	name = "string",
	scale = "glm.Vec3",
	position = "glm.Vec3",
	orientation = "glm.Quat",
	bounds = "lab3d.core.domain.BoundingBox",	
	filename = "string"
}

Type "lab3d.core.domain.Entity"
{
	entity = "lab3d.core.domain.IEntity"
}

Type "lab3d.core.domain.IView"
{
	position = "glm.Vec3",
	orientation = "glm.Quat"
}

Type "lab3d.core.domain.View"
{
	view = "lab3d.core.domain.IView"
}

Type "lab3d.core.domain.IProject"
{
	entities = "lab3d.core.domain.IEntity[]",
	name = "string"
}

Type "lab3d.core.domain.Project"
{
	project = "lab3d.core.domain.IProject"
}