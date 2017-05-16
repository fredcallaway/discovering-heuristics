.PHONY: default clean

default:
	python setup.py build_ext --inplace

clean:
	rm -f sprt/*.c
	rm -f sprt/*.so
	rm -rf build

exp1:
	-rm -r experiment/static/json/*
	bin/make_stimuli.py 'exp1_config.yml'
	cd experiment && make
