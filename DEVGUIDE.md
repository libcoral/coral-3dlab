CORAL 3D LAB DEVELOPER GUIDE
====================================

# Manipulando a camada de domínio

### Decorando entidades

Os objetos de negócio lab3d.dom.IEntity possuem suporte a decoração genérica. Isso significa que é possível decorá-los com
qualquer tipo de serviço e, a qualquer momento, recuperar tal decorator. Por exemplo:

- Lua:
	local myEntityComponent = co.new "lab3d.dom.Entity"
	local myEntityService = myEntityComponent.entity
	
	local mySpecialService = co.new( "myModule.SpecialServiceComponent" ).service
	
	-- Adiciona um decorador à entidade
	myEntityService:addDecorator( mySpecialService )
	
	...
	
	-- Lista os decoradores da entity para um determinado tipo
	local mySpecialDecorators = myEntityService:getDecoratorsForType( co.Type["myModule.ISpecialService"] )
	for i, v in ipairs( mySpecialDecorators ) do
		print( mySpecialDecorators.fullName )
	end
	
- C++:
	co::IObject* myEntityComponent = co.newInstance( "lab3d.dom.Entity" )
	lab3d::dom::IEntity* myEntityService = myEntityComponent->getService<lab3d::dom::IEntity>()
	
	myModule::ISpecialService* mySpecialService = co.newInstance( "myModule.SpecialServiceComponent" )->getService<myModule::ISpecialService>();
	
	// Adiciona um decorador à entidade
	myEntityService->addDecorator( mySpecialService );
	
	...
	
	// Lista os decoradores da entity para um determinado tipo
	co::RefVector<myModule::ISpecialService> mySpecialDecorators; 
	myEntityService->getDecorators<myModule::ISpecialService>( mySpecialDecorators );
	for( int i=0; i < mySpecialDecorators.size(); ++i )
	{
		printSpecialDecorator( mySpecialDecorator[i] );
	}
	
	
### Ouvindo mudanças na Entity

A notificação de mudança é feita através do serviço lab3d.dom.IEntityObserver. Contudo, existe um componente que prove um mecanismo de notificação por closures lua: lab3d.helper.EntityObserver.

#### Implementando um entity observer em Coral:

	component Observer
	{
		provides lab3d.dom.IEntityObserver;
	};
	
#### Implementando um entity observer em lua:
	
	local t = {}
	
	function t:onNameChanged( entity, name )
	
	end

	function t:onDecoratorAdded( entity, decorator )
	end

	function t:onDecoratorRemoved( entity,  decorator )
	
	end

	... 
	
	-- registra a tabela t para um entidade especifica
	local EntityObserver = require "lab3d.helper.EntityObserver"
	EntityObserver:addObserver( someEntity, t )
	
No caso da implementação em Lua a definição dos closures é opcional, permitindo a implementação apenas dos closures na qual se deseja ouvir.

## Trabalhando com Projetos

##O <i>entrypoint</i> da Applicação
	
Acessado globalmente utilizando o sistema de serviços do coral:

		local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
		
Serve como entrypoint principal para a manipulação de projetos e entities.

### Adicionando ou removendo entidades
	
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	application:newBlankProject()
	
	local entityObject = co.new "lab3d.dom.Entity"
	local entity = entityObject.entity
	
	application.currentProject:addEntity( entity )
	

Ao adicionar uma entidade em um projeto, ela será automaticamente tratada pelo componente lab3d.scene.SceneManager, que ira procurar por decoradores gráficos (lab3d.scene.IModel) na entity adicionada.

Qualquer decorador gráfico é automaticamente adicionado na cena e atualizado sempre que a entity é modificada. Um decorador pode ser adicionado a qualquer momento em uma entity e a cena irá ser automaticamente atualizada.

### Exemplo de modelo customizado:

	-- myCustomModel é um componente que prove IModel
	local myCustomModelObj = co.new "myModule.MyCustomModel"
	local myCustomModel = myCustomModelObj.model
	
	local entityObject = co.new "lab3d.dom.Entity"
	local entity = entityObject.entity
	
	entity:addDecorator( myCustomModel )
	
	application.currentProject:addEntity( entity )
	
Isso irá trará o modelo customizado à cena, de forma associada ao entity decorado (e.g um picking nesse modelo retorna o entity, utilizando o servico global lab3d.scene.IPickIntersector). Veja mais em [Estendendo a camada gráfica][#graphics].

### SceneManager

O componente lab3d.scene.SceneManager é responsável por realizar a sincronização entre a camada de domínio e a camada gráfica. 

#### Inicializando o SceneManager

	local SceneManager = require "lab3d.scene.SceneManager"
	SceneManager:initialize( scene )
	
A api em Lua permite uma inicialização bem simples como mostrada acima. Em C++ teriamos que instanciar um componente SceneManager e configurar seu receptáculo com a cena.

Em Lua também, o ponteiro para acena passada para o SceneManager na inicialização fica sempre disponível através do field scene:

	...
	SceneManager:initialize( scene )
	print( SceneManager.scene )
	
O scene manager utiliza a api de notificação de eventos de projeto e de entities (IProjectObserver e IEntityObserver) para manter as duas camadas atualizadas.

### Ouvindo mudanças em projetos

A notificação de eventos em projetos é feita através do serviço lab3d.dom.IProjectObserver. Contudo, existe um componente que prove um mecanismo de notificação por closures lua: lab3d.helper.ProjectObserver.

#### Implementando um project observer em Coral:

	component Observer
	{
		provides lab3d.dom.IProjectObserver;
	};
	
#### Implementando um entity observer em lua:
	
	local t = {}
	
	function t:onProjectOpened( newProject )
		
	end
	
	function t:onProjectClosed( project )
		
	end
	
	function t:onEntitiesAdded( project, entities )
		
	end
	
	function t:onEntitiesRemoved( project, entities )
		
	end
	
	function t:onEntitySelectionChanged( project, previous, current )
		
	end
	
	-- registra a tabela t para um entidade especifica
	local ProjectObserver = require "lab3d.helper.ProjectObserver"
	ProjectObserver:addObserver( t )
	
Novamente a implementação em Lua a é opcional, permitindo a implementação apenas dos closures na qual se deseja ouvir.


## A camada gráfica

A camada gráfica tem como constituintes preincipais os serviços 'lab3d.scene.IScene', 'lab3d.scene.ICamera' e lab3d.scene.IView, providos pelos respectivos componentes lab3d.scene.Scene, lab3d.scene.Camera, lab3d.scene.View.

O componente da cena, Scene, prove o serviço IScene para gerenciamento de uma cena com modelos gráficos, visualizados por uma única camera ativa por vez (IScene::camera).

### Criando uma cena:

#### C++:

	...
	// Cria o componente da cena
	co::IObject* sceneComponent = co::newInstance( "lab3d.scene.Scene" );	
	
	// Acessa o serviço IScene
	lab3d::scene::IScene sceneService* = sceneComponent->getService<lab3d::scene::IScene>();
	sceneService->setCamera( myCameraService );
	
#### Lua:
	...
	-- Cria o componente da cena
	local sceneComponent = co.new "lab3d.scene.Scene"
	
	-- Acessa o serviço IScene
	local sceneService = sceneComponent.scene
	sceneService.camera = myCameraService
	
### Configurando o contexto gráfico:
	
#### Lua:
	local canvasComponent = co.new "qt.GLWidget"
	
	-- Atribui o contexto do canvas à cena
	sceneComponent.graphicsContext = canvasComponent.context
	
	-- Configura o serviço da renderização (qt.IPainter)
	canvasComponent.painter = sceneComponent.painter
	

### Adicionando modelos à cena

O serviço da cena suporta a inclusão ou remoção de modelos gráficos representados pelo serviço lab3d.scene.IModel.
Abaixo há a declaração CSL deste serviço:

	interface IModel
	{	
		string filename;
		coOsg.NodePtr getNode();
		lab3d.dom.BoundingBox getBounds();
	};

Este framework, no entanto, já provê uma implementação <i>default</i> para IModel através do componente lab3d.scene.Model. Este componente utiliza <i>loaders</i> nativos do OpenSceneGraph para construir um nó válido. Isso permite o uso de modelos no formato .IVE de forma simples, como mostrado abaixo:

#### Lua:
	local myModelObj = co.new "lab3d.scene.Model"
	local myModel = myModelObj.model
	myModel.filename = "/myDatapath/P40.ive"
	
	sceneService:addModel( myModel )
	
O trecho acima utiliza apenas a camada gráfica de forma desassociada com a parte de negócio. O modelo adicionado na cena não pode ser manipulado de forma simples porque não possui nenhuma entidade relacionada a ele. Uma implementação customizada de IModel poderia manipular o modelo na cena (e.x: movê-lo ou selecioná-lo) utilizando diretamente a camada do grafo de cena. No entanto, isso acopla o código tornando o complexo e pouco reutilizável.

Por este motivo <b>a camada gráfica nunca deve ser manipulada diretamente de forma desassociada</b>. O framework provê mecanismos para que seja possível manipular <b>apenas a camada de négocio</b>
	
### [Estendendo a camada gráfica](!graphics)

Para estender a camada gráfica é necessario apenas prover uma implementação do serviço lab3d.scene.IModel.

Um exemplo C++ pode ser visto na implementação do componente que provê acesso a modelos no formato .IVE (lab3d.scene.Model), em src/lab3d/scene/Model.cpp.

Como explicado antes, se estas estensões de IModel forem adicionadas como decoradores de em uma instancia de IEntity, ela automaticamente será associada a ela e será renderizada tendo como origem a posição da entity. Na verdade, a transformação geométrica provida pela IEntity (posição, escala, rotação) afetará todos os decoradores gráficos (IModel) da entity.

#[Utilizando e estendendo Manipuladores](!manipuladores) 

Para estender um manipulador basta implementar o service IManipulator e utilizar a implementação de IManipulatorManager para registrá-lo. Isso irá disponibilizá-lo globalmente na aplicação bem como expor seus elementos de interface (IManipulator:resourceIcon) na barra de ferramentas de manipuladores.

