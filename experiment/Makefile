all: 
	coffee -o static/js -cb src/*

watch:
	coffee -o static/js -cbw src/*

demo:
	cp templates/exp.html index.html
	rsync -av --delete-after --copy-links . cocosci@cocosci-fred.dreamhosters.com:/home/cocosci/cocosci.dreamhosters.com/webexpt/cueball-demo