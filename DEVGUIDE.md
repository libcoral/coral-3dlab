CORAL 3D LAB DEVELOPER GUIDE
====================================

##Entendendo a hierarquia de módulos do Coral 3D lab:

- Namespace raiz 'lab3d':
O namespace raiz é 'lab3d' e contém dois outros principais namespaces 'dom' e 'scene'.

O framerwork coral 3d lab diferencia principalmente duas camadas: a cama de domínio (ou de negócio) e a camada gráfica.
Essa distinção existe para que seja simples alterar a forma como os objetos de negócio são visualizados. Os objetos de domínio
(serviço lab3d.dom.IEntity) contém todos os dados abstratos, comuns a qualquer tipo de objeto, como posição, orientação,
direção, escala e nome. 

O módulo lab3d.dom contém todos os serviços e componentes da camara de dominio do framework, tais como entidades, algoritmos de navegação,
algoritmos de modelagem de camera (IView).

Já o módulo lab3d.scene contém os módulos da camáda gráfica.

##A camada gráfica

A camada gráfica tem como constituintes basicos os serviços 'lab3d.scene.IScene', 'lab3d.scene.ICamera'
##Estendendo a camada gráfica

Os objetos de negócio lab3d.dom.IEntity possuem suporte a decoração genérica. Isso significa que é possível decorá-los com
qualquer tipo de serviço e recuperar tal decorator posteriormente. Quando uma entidade é decorada com um decorador especial,
do tipo lab3d.scene.IModel, 
##O <i>entrypoint</i> da Applicação

##Trabalhando com Projetos

##Trabalhando com componentes



##Trabalhando com componentes

## Criando uma entidade de domínio:
O serviço IEntity é provido pelo componente lab3d.core.domain.Entity e pode ser instanciado, como segue:

	
