CORAL 3D LAB DEVELOPER GUIDE
====================================

Entendendo a hierarquia de m�dulos do Coral 3D lab:

- Namespace raiz:
O namespace principal � 'lab3d', raiz de dois outros namespaces: app e core.
O m�dulo app cont�m 

- O m�dulo 'domain':
O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de dom�nio (ou de neg�cio) e a camada gr�fica.
Essa distin��o existe para que seja simples alterar a forma como os objetos de neg�cio s�o visualizados. Os objetos de dom�nio
(servi�o lab3d.core.domain.IEntity) cont�m todos os dados abstratos, comuns a qualquer tipo de objeto, como posi��o, orienta��o,
dire��o, escala e nome. 

O m�dulo domain cont�m todos os servi�os e componentes da camara de dominio do framework, tais como entidades, algoritmos de navega��o,
algoritmos de modelagem de camera (IView).
	
- Criando uma entidade de dom�nio:
O servi�o IEntity � provido pelo componente lab3d.core.domain.Entity e pode ser instanciado, como segue:

	
Understanting Coral 3d lab modules:
------------------------------------

- The domain module:

The domain model contains all services and components that 
The domain object model
---------------------------------

Accessing the application service
__________________________________

The application service provides the main entry point for handling the application context.
It is a global coral service and can be accessed as follow:
	
	local application = co.system.services:getService( co.Type["lab3d.app.IApplication"] )
	
The IApplication service provides access to current context and to two other methods for initialization
and application main loop entering, respectivelly IApplication:initialize() and IApplication:exec().

The IApplicationContext service:
__________________________________

IApplication.context provides access to current application state such as current scene instance (IScene),
the manipulator manager (IManipulatorManager) and also the current working project (IProject).

The IProject service:
__________________________________

IApplication.context.currentProject is a pointer to current instance of IProject. The current project
contains all working data, such as loaded entities (IEntity instances), current IEntity 