CORAL 3D LAB DEVELOPER GUIDE
====================================

Entendendo a hierarquia de módulos do Coral 3D lab:

- Namespace raiz:
O namespace principal é 'lab3d', raiz de dois outros namespaces: app e core.
O módulo app contém 

- O módulo 'domain':
O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de domínio (ou de negócio) e a camada gráfica.
Essa distinção existe para que seja simples alterar a forma como os objetos de negócio são visualizados. Os objetos de domínio
(serviço lab3d.core.domain.IEntity) contém todos os dados abstratos, comuns a qualquer tipo de objeto, como posição, orientação,
direção, escala e nome. 

O módulo domain contém todos os serviços e componentes da camara de dominio do framework, tais como entidades, algoritmos de navegação,
algoritmos de modelagem de camera (IView).
	
- Criando uma entidade de domínio:
O serviço IEntity é provido pelo componente lab3d.core.domain.Entity e pode ser instanciado, como segue:

	
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