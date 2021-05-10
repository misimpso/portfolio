PROJ_BASE=$(shell pwd)
PYTHONVER=python3.9
PYTHONVENV=$(PROJ_BASE)/venv
VENVPYTHON=$(PYTHONVENV)/bin/$(PYTHONVER)

launch:
	@echo "Running main.py"
	cd portfolio/
	uvicorn main:app --reload
	# sleep 3
	# xdg-open http://127.0.0.1:8000

develop: bootstrap
	@echo "Running webapp."
	uvicorn portfolio.main:app --reload
	@echo "\nYou may want to activate the virtual environmnent with 'source venv/bin/activate'\n"

bootstrap:
	@echo "Creating virtual environment 'venv' for development."
	$(PYTHONVER) -m venv venv
	@echo "Installing python modules from portfolio/requirements.txt"
	$(VENVPYTHON) -m pip install -r portfolio/requirements.txt

# clean_build:
# 	@echo "Removing build artifacts"
# 	rm -rf $(PROJ_BASE)/build
# 	rm -rf $(PROJ_BASE)/dist
# 	rm -rf $(PROJ_BASE)/*.egg-info

upload:
	$(VENVPYTHON) -m twine upload dist/*

# test:
# 	$(VENVPYTHON) -m pip install -r ci-cd-requirements.txt
# 	$(VENVPYTHON) -m tox

clean:
	@echo "Removing Python virtual environment 'venv'."
	rm -rf $(PYTHONVENV)
	rm -rf .tox

# sparkling: clean
# 	rm -rf *.whl
# 	find . -name \*~ | xargs rm -f
# 	rm -rf dist build src/*.egg-info
# 	rm -rf **/__pycache__
# 	rm -rf docs/_build/*
# 	rm -f src/version.py
# 	rm -rf htmlcov
# 	rm -rf coverage.xml
# 	rm -rf *.egg-info
# 	rm -rf .pytest_cache
# 	rm -f .coverage
# 	rm -rf .vscode

.PHONY: bootstrap upload clean
# .PHONY: install develop bootstrap clean_build build test clean sparkling upload