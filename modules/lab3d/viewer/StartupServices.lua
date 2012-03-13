--[[---------------------------------------------------------------------------
	Register global services
--]]---------------------------------------------------------------------------
-- Registers ActorFactory component as provider of global IActorFactory service
co.system.services:addServiceProvider( co.Type["lab3d.core.scene.IActorFactory"], "lab3d.core.scene.ActorFactory" )

-- Register OpenSceneGraph model loader service
co.system.services:addServiceProvider( co.Type["lab3d.core.scene.IModelLoader"], "lab3d.core.scene.ModelLoader" )

-- Registers main application entry point
co.system.services:addServiceProvider( co.Type["lab3d.core.IApplication"], "lab3d.core.Application" )
	
