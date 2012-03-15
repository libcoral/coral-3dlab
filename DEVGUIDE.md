CORAL 3D LAB DEVELOPER GUIDE
====================================

##Entendendo a hierarquia de m�dulos do Coral 3D lab:

- Namespace raiz 'lab3d':
O namespace raiz � 'lab3d' e cont�m dois outros principais namespaces 'dom' e 'scene'.

O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de dom�nio (ou de neg�cio) e a camada gr�fica.
Essa distin��o existe para que seja simples alterar a forma como os objetos de neg�cio s�o visualizados. Os objetos de dom�nio
(servi�o lab3d.dom.IEntity) cont�m todos os dados abstratos, comuns a qualquer tipo de objeto, como posi��o, orienta��o,
dire��o, escala e nome. 

O m�dulo lab3d.dom cont�m todos os servi�os e componentes da camara de dominio do framework, tais como entidades, algoritmos de navega��o,
algoritmos de modelagem de camera (IView).

J� o m�dulo lab3d.scene cont�m os m�dulos da cam�da gr�fica.

##A camada gr�fica

A camada gr�fica tem como constituintes basicos os servi�os 'lab3d.scene.IScene', 'lab3d.scene.ICamera'
##Estendendo a camada gr�fica

Os objetos de neg�cio lab3d.dom.IEntity possuem suporte a decora��o gen�rica. Isso significa que � poss�vel decor�-los com
qualquer tipo de servi�o e recuperar tal decorator posteriormente. Quando uma entidade � decorada com um decorador especial,
do tipo lab3d.scene.IModel, 
##O <i>entrypoint</i> da Applica��o

##Trabalhando com Projetos

##Trabalhando com componentes



##Trabalhando com componentes

## Criando uma entidade de dom�nio:
O servi�o IEntity � provido pelo componente lab3d.core.domain.Entity e pode ser instanciado, como segue:

	
