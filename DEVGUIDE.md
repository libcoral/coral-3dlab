CORAL 3D LAB DEVELOPER GUIDE
====================================

#�ndice:

# Introdu��o

Este guia apresentar� primeiramente uma vis�o geral sobre a hierarquia de m�dulos, introduzindo o conceito de arquitetura em camadas. Em seguida uma apresenta-se uma introdu��o � camada de neg�cios e como utiliz�-la. Esta se��o tamb�m mostra como adicionar e manipular entidades de dom�nio (lab3d.dom.IEntity) e como escutar mudan�as em seu estado. Nela tamb�m � introduzido o conceito de projeto (lab3d.dom.IProject), bem como cri�-los, carreg�-los, salv�-los e como escutar seus eventos.

Ap�s introduzir a camada de dom�nio e como manipul�-la, este guia apresenta a camada gr�fica e como estend�-la. Nesta se��o apresentamos tamb�m alguns m�dulos chave do framework, respons�veis por escutar mudan�as na camada de dom�nio e fornecer um mecanismo autom�tico de sincroniza��o entre esta camada e a camada gr�fica (lab3d.scene.SceneManager). Isso permite, como ser� visto, que toda a modelagem seja feita com o foco apenas na camada de neg�cios, tornando a cena apenas um reflexo ou vis�o configuravel desse modelo.

Por fim, s�o apresentados alguns m�dulos auxiliares (m�dulos lab3d.helper), uma vis�o geral do funcionamento do visualizador (lab3d.Viewer) e o que s�o e como criar novos manipuladores (lab3d.manipulator.IManipulator).

#1. [Entendendo a hierarquia de m�dulos do Coral 3D lab](!hierarquia):

## Namespace raiz 'lab3d':

O namespace raiz � 'lab3d' e cont�m dois outros principais namespaces 'dom' e 'scene'.

O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de dom�nio (ou de neg�cio) e a camada gr�fica.
Essa distin��o existe para que seja simples alterar a forma como os objetos de neg�cio s�o visualizados. Os objetos de dom�nio (servi�o lab3d.dom.IEntity) cont�m todos os dados abstratos, comuns a qualquer tipo de objeto, como posi��o, orienta��o, dire��o, escala e nome. 

O m�dulo lab3d.dom cont�m todos os servi�os e componentes da camara de dominio do framework, tais como entidades, algoritmos de navega��o, algoritmos de modelagem de camera (IView). J� o m�dulo lab3d.scene cont�m os m�dulos da cam�da gr�fica.

Embora seja poss�vel utilizar apenas a camada gr�fica (como ser� visto), <b>a camada gr�fica nunca deve ser manipulada diretamente de forma desassociada da camada de dom�nio</b>. 
O framework prov� mecanismos para que seja poss�vel manipular <b>apenas a camada de n�gocio</b> (e.x: entidades), de tal forma que as mudan�as nessa camada reflitam automaticamentea camada gr�fica. Isso permite enxergar e modelar melhor a camada de neg�cios e flexibilizar de maneira simples a forma como ela � representada graficamente.

# Manipulando a camada de dom�nio

## Entidades

 Intro...
 
### Decorando entidades

Os objetos de neg�cio lab3d.dom.IEntity possuem suporte a decora��o gen�rica. Isso significa que � poss�vel decor�-los com
qualquer tipo de servi�o e, a qualquer momento, recuperar tal decorator. Por exemplo:

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
	
	
### Ouvindo mudan�as
 IEntityObserver, EntityObserver (lua closures)
 
## Trabalhando com Projetos


##O <i>entrypoint</i> da Applica��o

### Adicionando ou removendo entidades

### Ouvindo mudan�as em projetos

#### Evento de projeto aberto
#### Evento de projeto fechado
#### Evento de adi��o/remo��o de entidades
#### Eventos sele��o de entidades

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
	
Para que a cena renderize corretamente, � preciso configurar o componente Scene provendo tamb�m um servi�o de contexto gr�fico. A cena sempre renderiza para um determinado contexto ativo (por exemplo, o contexto OpenGL corrente), que � representado pelo servi�o qt.IGLContext. Tal servi�o � parte do projeto-dependencia coral-qt (git://github.com/libcoral/coral-qt.git) e � atrav�s dele que o contexto gr�fico ativo � compartilhado. O provedor do contexto gr�fico em uma aplica��o comum � o canvas gr�fico. Esse elemento da interface � provido pelo componente qt.GLWidget, que prov� o servi�o qt.IGLContext.

### Configurando o contexto gr�fico:
	
#### Lua:
	local canvasComponent = co.new "qt.GLWidget"
	
	-- Atribui o contexto do canvas � cena
	sceneComponent.graphicsContext = canvasComponent.context
	
	-- Configura o servi�o da renderiza��o (qt.IPainter)
	canvasComponent.painter = sceneComponent.painter
	
Como se pode observar no final do �ltimo exemplo, o componente de interface de usu�rio qt.GLWidget tamb�m � configurado com um outro servi�o: qt.IPainter. Esse servi�o � utilizado pelo canvas sempre que uma nova renderiza��o for necess�ria. O componente lab3d.scene.Scene prov� este servi�o.

Tendo configurado o contexto gr�fico na cena (qt.IGLContext) e o renderizador no canvas (qt.IPainter), a cena j� est� pronta para exibir modelos gr�ficos na interface do usu�rio.

Posteriormente, na se��o de [Manipuladores][#manipuladores], veremos como configurar o componente canvas para tratar intera��o do usu�rio (e.x: mouse e teclado) utilizando o servi�o qt.IInputListener e lab3d.manipulator.IManipulator.

### Adicionando modelos � cena

O servi�o da cena suporta a inclus�o ou remo��o de modelos gr�ficos representados pelo servi�o lab3d.scene.IModel.
Abaixo h� a declara��o CSL deste servi�o:

	interface IModel
	{	
		string filename;
		coOsg.NodePtr getNode();
		lab3d.dom.BoundingBox getBounds();
	};

A declara��o assim mostra que um IModel prove apenas uma forma de se obter um n� compativel com [OpenSceneGraph][http://www.openscenegraph.org/projects/osg] (coOsg.NodePtr � um <i>typedef</i> para osg::Node*). Fica a cargo de cada implementa��o a estrat�gia de constru��o ou carregamento do(s) modelo(s) representados pelo n� gr�fico obtido pelo m�doto getNode().

Este framework, no entanto, j� prov� uma implementa��o <i>default</i> para IModel atrav�s do componente lab3d.scene.Model. Este componente utiliza <i>loaders</i> nativos do OpenSceneGraph para construir um n� v�lido. Isso permite o uso de modelos no formato .IVE de forma simples, como mostrado abaixo:

#### Lua:
	local myModelObj = co.new "lab3d.scene.Model"
	local myModel = myModelObj.model
	myModel.filename = "/myDatapath/P40.ive"
	
	sceneService:addModel( myModel )
	
O trecho acima utiliza apenas a camada gr�fica de forma desassociada com a parte de neg�cio. O modelo adicionado na cena n�o pode ser manipulado de forma simples porque n�o possui nenhuma entidade relacionada a ele. Uma implementa��o customizada de IModel poderia manipular o modelo na cena (e.x: mov�-lo ou selecion�-lo) utilizando diretamente a camada do grafo de cena. No entanto, isso acopla o c�digo tornando o complexo e pouco reutiliz�vel.

Por este motivo <b>a camada gr�fica nunca deve ser manipulada diretamente de forma desassociada</b>. O framework prov� mecanismos para que seja poss�vel manipular <b>apenas a camada de n�gocio</b>
	
### Estendendo a camada gr�fica

Para estender a camada gr�fica � necessario apenas prover uma implementa��o do servi�o lab3d.scene.IModel.

Um exemplo C++ pode ser visto na implementa��o do componente que prov� acesso a modelos no formato .IVE (lab3d.scene.Model), em src/lab3d/scene/Model.cpp.

# SceneManager

# Componentes utilitarios (lab3d.helper)


Quando uma entidade � decorada com um decorador especial,
do tipo lab3d.scene.IModel, 



#[Utilizando e estendendo Manipuladores](!manipuladores) 
