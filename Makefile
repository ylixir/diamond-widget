PROJECT_NAME := $(notdir $(CURDIR))

ELM := npx elm

widget.js: elm.js main.js elm-stuff/gitdeps/github.com/ylixir/ylm-media.git/Port/mediaApp.js
	cat $^ | npx terser --compress --mangle > $@

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

deploy: widget.js index.html
	cp widget.js widget.publish
	cp index.html index.publish
	git checkout gh-pages
	mv widget.publish widget.js
	mv index.publish index.html
	git add $^
	git commit -m "deploy"
	git push
	git checkout master

