windows:
	odin build app -out:demo/VBConsoleAppDemo/bin/Debug/net8.0/LedFrontend.dll -build-mode:dll

dev:
	odin build . -out:output/run.exe -show-system-calls -debug
	./output/run.exe

vb:
	make windows
	copy .\output\*.dll .\demo\VBConsoleAppDemo\bin\Debug\net8.0
	dotnet build demo/VBConsoleAppDemo

run:
	make vb
	demo/VBConsoleAppDemo/bin/Debug/net8.0/VBConsoleAppDemo.exe
