PROJECT_NAME := $(notdir $(CURDIR))

ELM := npx elm

widget.js: elm.js main.js elm-stuff/gitdeps/github.com/ylixir/ylm-media.git/Port/mediaApp.js
	cat $^ > $@

elm.js: src/Main.elm elm.json package-lock.json
	${ELM} make --optimize src/Main.elm --output $@

package-lock.json: package.json elm-git.json
	npm install --save-dev
	npx elm-git-install

clean:
	rm -rf node_modules
	rm -rf elm-stuff
	rm -f package-lock.json
	rm -f elm.js
	rm -f widget.js
