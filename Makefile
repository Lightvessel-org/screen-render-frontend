windows:
	odin build app -out:demo/VBConsoleAppDemo/bin/Debug/net8.0/LedFrontend.dll -build-mode:dll

run:
	odin build . -out:output/run.exe -show-system-calls -debug
	./output/run.exe

make python_demo:
	make windows
	python demo/DemoNET/DemoNET/bin/Debug/net8.0/demo.py
