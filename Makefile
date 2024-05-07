windows:
	odin build . -build-mode:dll

run:
	odin build . -out:output/run.exe -show-system-calls -debug
	./output/run.exe
