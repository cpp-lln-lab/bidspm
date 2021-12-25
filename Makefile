.PHONY: clean clean_docker
clean:
	rm Dockerfile*
	rm version.txt

clean_docker:
	rm Dockerfile*

Dockerfile:
	bash build_image.sh

Dockerfile_dev:
	bash build_image.sh

version.txt:
	grep -w "^version" CITATION.cff | sed "s/version: /v/g" > version.txt