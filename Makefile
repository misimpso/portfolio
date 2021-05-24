PROJ_BASE=$(shell pwd)
PYTHONVER=python3.9
PYTHONVENV=$(PROJ_BASE)/venv
VENVPYTHON=$(PYTHONVENV)/bin/$(PYTHONVER)


develop:
	docker run -it \
		--name dev \
		--net host \
		-v $(PROJ_BASE)/portfolio/static:/home/portfolio/static \
		-v $(PROJ_BASE)/portfolio/templates:/home/portfolio/templates \
		misimpso/portfolio_web

bootstrap:
	@echo "Creating virtual environment 'venv' for development."
	$(PYTHONVER) -m venv venv
	@echo "Installing python modules from portfolio/requirements.txt"
	$(VENVPYTHON) -m pip install -r portfolio/requirements.txt

clean:
	@echo "Removing Python virtual environment 'venv'."
	rm -rf $(PYTHONVENV)
	rm -rf .tox

.PHONY: bootstrap upload clean develop
# .PHONY: install develop bootstrap clean_build build test clean sparkling upload