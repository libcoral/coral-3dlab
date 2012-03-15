CORAL 3D LAB DEVELOPER GUIDE
====================================

#Índice:

#[Entendendo a hierarquia de módulos do Coral 3D lab](!hierarquia):

## Namespace raiz 'lab3d':

O namespace raiz é 'lab3d' e contém dois outros principais namespaces 'dom' e 'scene'.

O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de domínio (ou de negócio) e a camada gráfica.
Essa distinção existe para que seja simples alterar a forma como os objetos de negócio são visualizados. Os objetos de domínio (serviço lab3d.dom.IEntity) contém todos os dados abstratos, comuns a qualquer tipo de objeto, como posição, orientação, direção, escala e nome. 

O módulo lab3d.dom contém todos os serviços e componentes da camara de dominio do framework, tais como entidades, algoritmos de navegação, algoritmos de modelagem de camera (IView). Já o módulo lab3d.scene contém os módulos da camáda gráfica.

Embora seja possível utilizar apenas a camada gráfica (como será visto), <b>a camada gráfica nunca deve ser manipulada diretamente de forma desassociada da camada de domínio</b>. 
O framework provê mecanismos para que seja possível manipular <b>apenas a camada de négocio</b> (e.x: entidades), de tal forma que as mudanças nessa camada reflitam automaticamentea camada gráfica. Isso permite enxergar e modelar melhor a camada de negócios e flexibilizar de maneira simples a forma como ela é representada graficamente.

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
	
Para que a cena renderize corretamente, é preciso configurar o componente Scene provendo também um serviço de contexto gráfico. A cena sempre renderiza para um determinado contexto ativo (por exemplo, o contexto OpenGL corrente), que é representado pelo serviço qt.IGLContext. Tal serviço é parte do projeto-dependencia coral-qt (git://github.com/libcoral/coral-qt.git) e é através dele que o contexto gráfico ativo é compartilhado. O provedor do contexto gráfico em uma aplicação comum é o canvas gráfico. Esse elemento da interface é provido pelo componente qt.GLWidget, que provê o serviço qt.IGLContext.

### Configurando o contexto gráfico:
	
#### Lua:
	local canvasComponent = co.new "qt.GLWidget"
	
	-- Atribui o contexto do canvas à cena
	sceneComponent.graphicsContext = canvasComponent.context
	
	-- Configura o serviço da renderização (qt.IPainter)
	canvasComponent.painter = sceneComponent.painter
	
Como se pode observar no final do último exemplo, o componente de interface de usuário qt.GLWidget também é configurado com um outro serviço: qt.IPainter. Esse serviço é utilizado pelo canvas sempre que uma nova renderização for necessária. O componente lab3d.scene.Scene provê este serviço.

Tendo configurado o contexto gráfico na cena (qt.IGLContext) e o renderizador no canvas (qt.IPainter), a cena já está pronta para exibir modelos gráficos na interface do usuário.

Posteriormente, na seção de [Manipuladores][#manipuladores], veremos como configurar o componente canvas para tratar interação do usuário (e.x: mouse e teclado) utilizando o serviço qt.IInputListener e lab3d.manipulator.IManipulator.

### Adicionando modelos à cena

O serviço da cena suporta a inclusão ou remoção de modelos gráficos representados pelo serviço lab3d.scene.IModel.
Abaixo há a declaração CSL deste serviço:

	interface IModel
	{	
		string filename;
		coOsg.NodePtr getNode();
		lab3d.dom.BoundingBox getBounds();
	};

A declaração assim mostra que um IModel prove apenas uma forma de se obter um nó compativel com [OpenSceneGraph][http://www.openscenegraph.org/projects/osg] (coOsg.NodePtr é um <i>typedef</i> para osg::Node*). Fica a cargo de cada implementação a estratégia de construção ou carregamento do(s) modelo(s) representados pelo nó gráfico obtido pelo médoto getNode().

Este framework, no entanto, já provê uma implementação <i>default</i> para IModel através do componente lab3d.scene.Model. Este componente utiliza <i>loaders</i> nativos do OpenSceneGraph para construir um nó válido. Isso permite o uso de modelos no formato .IVE de forma simples, como mostrado abaixo:

#### Lua:
	local myModelObj = co.new "lab3d.scene.Model"
	local myModel = myModelObj.model
	myModel.filename = "/myDatapath/P40.ive"
	
	sceneService:addModel( myModel )
	
O trecho acima utiliza apenas a camada gráfica de forma desassociada com a parte de negócio. O modelo adicionado na cena não pode ser manipulado de forma simples porque não possui nenhuma entidade relacionada a ele. Uma implementação customizada de IModel poderia manipular o modelo na cena (e.x: movê-lo ou selecioná-lo) utilizando diretamente a camada do grafo de cena. No entanto, isso acopla o código tornando o complexo e pouco reutilizável.

Por este motivo <b>a camada gráfica nunca deve ser manipulada diretamente de forma desassociada</b>. O framework provê mecanismos para que seja possível manipular <b>apenas a camada de négocio</b>
	
### Estendendo a camada gráfica

Para estender a camada gráfica é necessario apenas prover uma implementação do serviço lab3d.scene.IModel.

Um exemplo C++ pode ser visto na implementação do componente que provê acesso a modelos no formato .IVE (lab3d.scene.Model), em src/lab3d/scene/Model.cpp.

# Manipulando a camada de domínio

## Entidades

### Decorando entidades

Os objetos de negócio lab3d.dom.IEntity possuem suporte a decoração genérica. Isso significa que é possível decorá-los com
qualquer tipo de serviço e, a qualquer momento, recuperar tal decorator. Por exemplo:

- Lua:
	local myEntityComponent = co.new "lab3d.dom.Entity"
	local myEntityService = myEntityComponent.entity
	
	local mySpecialService = co.new( "myModule.SpecialServiceComponent" ).service
	
	-- Adiciona um decorador na entidade
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
	
	// Adiciona um decorador na entidade
	myEntityService->addDecorator( mySpecialService );
	
	...
	
	// Lista os decoradores da entity para um determinado tipo
	co::RefVector<myModule::ISpecialService> mySpecialDecorators; 
	myEntityService->getDecorators<myModule::ISpecialService>( mySpecialDecorators );
	for( int i=0; i < mySpecialDecorators.size(); ++i )
	{
		printSpecialDecorator( mySpecialDecorator[i] );
	}
	
	
### Ouvindo mudanças

## Trabalhando com Projetos

### Adicionando ou removendo entidades

### Ouvindo mudanças em projetos

#### Evento de projeto aberto
#### Evento de projeto fechado
#### Evento de adição/remoção de entidades
#### Eventos seleção de entidades

# SceneManager

# Componentes utilitarios (lab3d.helper)



Quando uma entidade é decorada com um decorador especial,
do tipo lab3d.scene.IModel, 

##O <i>entrypoint</i> da Applicação

##Trabalhando com Projetos

##Trabalhando com componentes



#[Utilizando e estendendo Manipuladores](!manipuladores) 
