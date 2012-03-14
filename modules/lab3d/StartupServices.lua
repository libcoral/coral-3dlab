--[[---------------------------------------------------------------------------
	Register global services
--]]---------------------------------------------------------------------------
-- Registers ActorFactory component as provider of global IActorFactory service
co.system.services:addServiceProvider( co.Type["lab3d.scene.IActorFactory"], "lab3d.scene.ActorFactory" )

-- Register OpenSceneGraph model loader service
co.system.services:addServiceProvider( co.Type["lab3d.scene.IModelLoader"], "lab3d.scene.ModelLoader" )

-- Registers main application entry point
co.system.services:addServiceProvider( co.Type["lab3d.IApplication"], "lab3d.Application" )
