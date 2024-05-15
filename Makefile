windows:
	odin build app -out:demo/DemoNET/DemoNET/bin/Debug/net8.0/BasicOdinGame.dll -build-mode:dll

run:
	odin build . -out:output/run.exe -show-system-calls -debug
	./output/run.exe

make python_demo:
	make windows
	python demo/DemoNET/DemoNET/bin/Debug/net8.0/demo.py
