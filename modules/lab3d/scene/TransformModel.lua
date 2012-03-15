--[[---------------------------------------------------------------------------
	Transform model: provides a transform group of models and retrieves 
	the correspondent OpenSceneGraph transform node for that group.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local glm = require "glm"

local SceneManager = require "lab3d.SceneManager"
local ProjectObserver = require "lab3d.helper.ProjectObserver"

local ExamineManipulator =  co.Component( "lab3d.manipulator.ExamineManipulator" )

-- local functions table
local locals = {}
