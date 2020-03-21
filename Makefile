PROJECT_NAME := $(notdir $(CURDIR))

ELM := npx elm

go: package-lock.json
	${ELM} reactor

index.html: src/Main.elm elm.json package-lock.json
	${ELM} make src/Main.elm

package-lock.json: package.json elm-git.json
	npm install --save-dev
	npx elm-git-install

clean:
	rm -rf node_modules
	rm -rf elm-stuff
	rm -f package-lock.json
