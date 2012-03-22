# Coral 3D Lab #

Exemplo de visualizador 3D constru�do sobre o framework Coral.

Testado no Linux (GCC 4.5) e OSX (Xcode 4.3).
Espero que ningu�m queira usar Windows t�o cedo :-)

## Funcionalidades B�sicas ##

 *	Suporte a m�ltiplos modelos 3D na cena.
 *	Salvamento e carregamento de "projetos".
 *	Manipuladores de c�mera simples (Examine e Fly)
 *	Console Lua

## Depend�ncias Externas (pr�-compiladas) ##

Para compilar o projeto, as seguintes ferramentas devem estar no path do sistema:

 *	[CMake](http://www.cmake.org/) - usado em todo o processo de build.
 *	[Git](http://git-scm.com/) - para obter as depend�ncias do projeto automaticamente.

E os seguintes frameworks devem estar no libpath do sistema:

 *	[Qt libraries](http://qt-project.org/) - framework de GUI.
 *	[OpenSceneGraph](http://www.openscenegraph.org/) - middleware gr�fico OpenGL.
 	 *	Recomenda-se baixar os [pacotes pr�-compilados do OSG](http://openscenegraph.alphapixel.com/osg/downloads/free-openscenegraph-binary-downloads).

## Depend�ncias Internas (semi-autom�ticas) ##

Este projeto depende do framework Coral e diversos m�dulos. Todas as depend�ncias podem ser obtidas executando o script `dependencies/build.cmake` dentro do diret�rio de build que ser� usado. Por exemplo, se quisermos compilar o projeto num diret�rio "build" dentro da raiz do source:

	mkdir build && cd build
	cmake -P ../dependencies/build.cmake

O script pode ser executado novamente sempre que for necess�rio atualizar as depend�ncias do projeto.

## Compila��o ##

Com todas as depend�ncias resolvidas, basta executar o CMake no diret�rio de build.
Por exemplo, para compilar o projeto em modo `Debug` usando Makefiles no Linux:

	cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ..
	make

## Como executar a aplica��o durante o desenvolvimento ##

Usar o target `run` ou `run-debug`, caso esteja compilando em Release ou Debug, respectivamente. Por exemplo, se estiver compilando em Debug e usando Makefiles:

	make run-debug

## Como gerar um pacote distribu�vel ##

1. Compilar o projeto em modo `Release` (n�o h� suporte a pacotes em `Debug`)
2. Usar o target `package` do CMake. Por exemplo, para gerar um `.tar.gz`:

		cmake -DCPACK_GENERATOR=TGZ ..
		make package

Note que o pacote n�o inclui as libs do Qt nem do OpenSceneGraph.
