CORAL 3D LAB DEVELOPER GUIDE
====================================

# Manipulando a camada de dom�nio

### Decorando entidades

Os objetos de neg�cio lab3d.dom.IEntity possuem suporte a decora��o gen�rica. Isso significa que � poss�vel decor�-los com
qualquer tipo de servi�o e, a qualquer momento, recuperar tal decorator. Por exemplo:

- Lua:
	local myEntityComponent = co.new "lab3d.dom.Entity"
	local myEntityService = myEntityComponent.entity
	
	local mySpecialService = co.new( "myModule.SpecialServiceComponent" ).service
	
	-- Adiciona um decorador � entidade
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
	
	// Adiciona um decorador � entidade
	myEntityService->addDecorator( mySpecialService );
	
	...
	
	// Lista os decoradores da entity para um determinado tipo
	co::RefVector<myModule::ISpecialService> mySpecialDecorators; 
	myEntityService->getDecorators<myModule::ISpecialService>( mySpecialDecorators );
	for( int i=0; i < mySpecialDecorators.size(); ++i )
	{
		printSpecialDecorator( mySpecialDecorator[i] );
	}
	
	
### Ouvindo mudan�as na Entity

A notifica��o de mudan�a � feita atrav�s do servi�o lab3d.dom.IEntityObserver. Contudo, existe um componente que prove um mecanismo de notifica��o por closures lua: lab3d.helper.EntityObserver.

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
	
No caso da implementa��o em Lua a defini��o dos closures � opcional, permitindo a implementa��o apenas dos closures na qual se deseja ouvir.

## Trabalhando com Projetos

##O <i>entrypoint</i> da Applica��o
	
Acessado globalmente utilizando o sistema de servi�os do coral:

		local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
		
Serve como entrypoint principal para a manipula��o de projetos e entities.

### Adicionando ou removendo entidades
	
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	application:newBlankProject()
	
	local entityObject = co.new "lab3d.dom.Entity"
	local entity = entityObject.entity
	
	application.currentProject:addEntity( entity )
	

Ao adicionar uma entidade em um projeto, ela ser� automaticamente tratada pelo componente lab3d.scene.SceneManager, que ira procurar por decoradores gr�ficos (lab3d.scene.IModel) na entity adicionada.

Qualquer decorador gr�fico � automaticamente adicionado na cena e atualizado sempre que a entity � modificada. Um decorador pode ser adicionado a qualquer momento em uma entity e a cena ir� ser automaticamente atualizada.

### Exemplo de modelo customizado:

	-- myCustomModel � um componente que prove IModel
	local myCustomModelObj = co.new "myModule.MyCustomModel"
	local myCustomModel = myCustomModelObj.model
	
	local entityObject = co.new "lab3d.dom.Entity"
	local entity = entityObject.entity
	
	entity:addDecorator( myCustomModel )
	
	application.currentProject:addEntity( entity )
	
Isso ir� trar� o modelo customizado � cena, de forma associada ao entity decorado (e.g um picking nesse modelo retorna o entity, utilizando o servico global lab3d.scene.IPickIntersector). Veja mais em [Estendendo a camada gr�fica][#graphics].

### SceneManager

O componente lab3d.scene.SceneManager � respons�vel por realizar a sincroniza��o entre a camada de dom�nio e a camada gr�fica. 

#### Inicializando o SceneManager

	local SceneManager = require "lab3d.scene.SceneManager"
	SceneManager:initialize( scene )
	
A api em Lua permite uma inicializa��o bem simples como mostrada acima. Em C++ teriamos que instanciar um componente SceneManager e configurar seu recept�culo com a cena.

Em Lua tamb�m, o ponteiro para acena passada para o SceneManager na inicializa��o fica sempre dispon�vel atrav�s do field scene:

	...
	SceneManager:initialize( scene )
	print( SceneManager.scene )
	
O scene manager utiliza a api de notifica��o de eventos de projeto e de entities (IProjectObserver e IEntityObserver) para manter as duas camadas atualizadas.

### Ouvindo mudan�as em projetos

A notifica��o de eventos em projetos � feita atrav�s do servi�o lab3d.dom.IProjectObserver. Contudo, existe um componente que prove um mecanismo de notifica��o por closures lua: lab3d.helper.ProjectObserver.

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
	
Novamente a implementa��o em Lua a � opcional, permitindo a implementa��o apenas dos closures na qual se deseja ouvir.


## A camada gr�fica

A camada gr�fica tem como constituintes preincipais os servi�os 'lab3d.scene.IScene', 'lab3d.scene.ICamera' e lab3d.scene.IView, providos pelos respectivos componentes lab3d.scene.Scene, lab3d.scene.Camera, lab3d.scene.View.

O componente da cena, Scene, prove o servi�o IScene para gerenciamento de uma cena com modelos gr�ficos, visualizados por uma �nica camera ativa por vez (IScene::camera).

### Criando uma cena:

#### C++:

	...
	// Cria o componente da cena
	co::IObject* sceneComponent = co::newInstance( "lab3d.scene.Scene" );	
	
	// Acessa o servi�o IScene
	lab3d::scene::IScene sceneService* = sceneComponent->getService<lab3d::scene::IScene>();
	sceneService->setCamera( myCameraService );
	
#### Lua:
	...
	-- Cria o componente da cena
	local sceneComponent = co.new "lab3d.scene.Scene"
	
	-- Acessa o servi�o IScene
	local sceneService = sceneComponent.scene
	sceneService.camera = myCameraService
	
### Configurando o contexto gr�fico:
	
#### Lua:
	local canvasComponent = co.new "qt.GLWidget"
	
	-- Atribui o contexto do canvas � cena
	sceneComponent.graphicsContext = canvasComponent.context
	
	-- Configura o servi�o da renderiza��o (qt.IPainter)
	canvasComponent.painter = sceneComponent.painter
	

### Adicionando modelos � cena

O servi�o da cena suporta a inclus�o ou remo��o de modelos gr�ficos representados pelo servi�o lab3d.scene.IModel.
Abaixo h� a declara��o CSL deste servi�o:

	interface IModel
	{	
		string filename;
		coOsg.NodePtr getNode();
		lab3d.dom.BoundingBox getBounds();
	};

Este framework, no entanto, j� prov� uma implementa��o <i>default</i> para IModel atrav�s do componente lab3d.scene.Model. Este componente utiliza <i>loaders</i> nativos do OpenSceneGraph para construir um n� v�lido. Isso permite o uso de modelos no formato .IVE de forma simples, como mostrado abaixo:

#### Lua:
	local myModelObj = co.new "lab3d.scene.Model"
	local myModel = myModelObj.model
	myModel.filename = "/myDatapath/P40.ive"
	
	sceneService:addModel( myModel )
	
O trecho acima utiliza apenas a camada gr�fica de forma desassociada com a parte de neg�cio. O modelo adicionado na cena n�o pode ser manipulado de forma simples porque n�o possui nenhuma entidade relacionada a ele. Uma implementa��o customizada de IModel poderia manipular o modelo na cena (e.x: mov�-lo ou selecion�-lo) utilizando diretamente a camada do grafo de cena. No entanto, isso acopla o c�digo tornando o complexo e pouco reutiliz�vel.

Por este motivo <b>a camada gr�fica nunca deve ser manipulada diretamente de forma desassociada</b>. O framework prov� mecanismos para que seja poss�vel manipular <b>apenas a camada de n�gocio</b>
	
### [Estendendo a camada gr�fica](!graphics)

Para estender a camada gr�fica � necessario apenas prover uma implementa��o do servi�o lab3d.scene.IModel.

Um exemplo C++ pode ser visto na implementa��o do componente que prov� acesso a modelos no formato .IVE (lab3d.scene.Model), em src/lab3d/scene/Model.cpp.

Como explicado antes, se estas estens�es de IModel forem adicionadas como decoradores de em uma instancia de IEntity, ela automaticamente ser� associada a ela e ser� renderizada tendo como origem a posi��o da entity. Na verdade, a transforma��o geom�trica provida pela IEntity (posi��o, escala, rota��o) afetar� todos os decoradores gr�ficos (IModel) da entity.

#[Utilizando e estendendo Manipuladores](!manipuladores) 

Para estender um manipulador basta implementar o service IManipulator e utilizar a implementa��o de IManipulatorManager para registr�-lo. Isso ir� disponibiliz�-lo globalmente na aplica��o bem como expor seus elementos de interface (IManipulator:resourceIcon) na barra de ferramentas de manipuladores.

