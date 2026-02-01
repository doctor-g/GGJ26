name=shove_off
godot=godot

all: windows linux $(name).zip $(name)_src.zip

clean:
	rm -rf build

linux: linux/$(name).x86_64

windows: windows/$(name).exe

linux/$(name).x86_64:
	mkdir -p build/linux
	$(godot) -v --export-release --headless "Linux" ../build/linux/$(name).x86_64 project/project.godot

windows/$(name).exe:
	mkdir -p build/windows
	$(godot) -v --export-release --headless "Windows Desktop" ../build/windows/$(name).exe project/project.godot

$(name).zip: windows/$(name).exe linux/$(name).x86_64
	mkdir -p build/executables
	cp -r build/windows/* build/executables
	cp -r build/linux/* build/executables
	cd build/executables; zip $(name).zip *

$(name)_src.zip:
	mkdir -p build/src
	rsync -av --progress project build/src --exclude .godot
	cd build/src; zip -r $(name)_src.zip *