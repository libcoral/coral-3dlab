@echo on

mkdir build
chdir build

mkdir mak.vc10
chdir mak.vc10

REM del CMakeCache.txt

cmake -G "Visual Studio 10 Win64" ../../

if %errorlevel% NEQ 0 goto error
goto end

:error
echo Houve um erro. Pressione qualquer tecla para finalizar.
pause >nul

:end
cd ../../
copy "run-debug.vcxproj.user" "build/mak.vc10/src/"

REM echo Pressione qualquer tecla para finalizar.
REM pause >nul