windows:
	odin build app -out:demo/VBConsoleAppDemo/bin/Debug/net8.0/LedFrontend.dll -build-mode:dll

run:
	odin build . -out:output/run.exe -show-system-calls -debug
	./output/run.exe

make vb:
	make windows
	cp ./output/*.dll ./demo/VBConsoleAppDemo/bin/Debug/net8.0
	dotnet build demo/VBConsoleAppDemo