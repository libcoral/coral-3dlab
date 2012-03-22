# Coral 3D Lab #

Exemplo de visualizador 3D construído sobre o framework Coral.

Testado no Linux (GCC 4.5) e OSX (Xcode 4.3).
Espero que ninguém queira usar Windows tão cedo :-)

## Funcionalidades Básicas ##

 *	Suporte a múltiplos modelos 3D na cena.
 *	Salvamento e carregamento de "projetos".
 *	Manipuladores de câmera simples (Examine e Fly)
 *	Console Lua

## Dependências Externas (pré-compiladas) ##

Para compilar o projeto, as seguintes ferramentas devem estar no path do sistema:

 *	[CMake](http://www.cmake.org/) - usado em todo o processo de build.
 *	[Git](http://git-scm.com/) - para obter as dependências do projeto automaticamente.

E os seguintes frameworks devem estar no libpath do sistema:

 *	[Qt libraries](http://qt-project.org/) - framework de GUI.
 *	[OpenSceneGraph](http://www.openscenegraph.org/) - middleware gráfico OpenGL.
 	 *	Recomenda-se baixar os [pacotes pré-compilados do OSG](http://openscenegraph.alphapixel.com/osg/downloads/free-openscenegraph-binary-downloads).

## Dependências Internas (semi-automáticas) ##

Este projeto depende do framework Coral e diversos módulos. Todas as dependências podem ser obtidas executando o script `dependencies/build.cmake` dentro do diretório de build que será usado. Por exemplo, se quisermos compilar o projeto num diretório "build" dentro da raiz do source:

	mkdir build && cd build
	cmake -P ../dependencies/build.cmake

O script pode ser executado novamente sempre que for necessário atualizar as dependências do projeto.

## Compilação ##

Com todas as dependências resolvidas, basta executar o CMake no diretório de build.
Por exemplo, para compilar o projeto em modo `Debug` usando Makefiles no Linux:

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ..
	make

## Como executar a aplicação durante o desenvolvimento ##

Usar o target `run` ou `run-debug`, caso esteja compilando em Release ou Debug, respectivamente. Por exemplo, se estiver compilando em Debug e usando Makefiles:

	make run-debug

## Como gerar um pacote distribuível ##

1. Compilar o projeto em modo `Release` (não há suporte a pacotes em `Debug`)
2. Usar o target `package` do CMake. Por exemplo, para gerar um `.tar.gz`:

		cmake -DCPACK_GENERATOR=TGZ ..
		make package

Note que o pacote não inclui as libs do Qt nem do OpenSceneGraph.
