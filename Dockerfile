#########################################################################################
# Setup Base Environment
#########################################################################################

FROM python:3.10-slim-buster as base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV VIRTUAL_ENV=/opt/venv
EXPOSE 5000
WORKDIR /home/portfolio

RUN apt-get update -y && \
    apt-get install \
    make \
    build-essential \
    -y

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

RUN python3 -m venv $VIRTUAL_ENV && \
    . $VIRTUAL_ENV/bin/activate && \
    $VIRTUAL_ENV/bin/pip install --upgrade setuptools pip

COPY "requirements.txt" .
RUN $VIRTUAL_ENV/bin/pip install -r requirements.txt

#########################################################################################
# Build Runtime Package
#########################################################################################

FROM base as builder

COPY . .
RUN $VIRTUAL_ENV/bin/pip install -r requirements-dev.txt
RUN $VIRTUAL_ENV/bin/python -m build --wheel

#########################################################################################
# Install Runtime package
#########################################################################################

FROM base as runtime
COPY --from=builder /home/portfolio/dist/ build/
RUN find build/ -maxdepth 1 -name "*.tar.gz" -o -name "*.whl" | xargs -r -n1 -t $VIRTUAL_ENV/bin/pip install
ENTRYPOINT ["/opt/venv/bin/uvicorn", "portfolio.main:app", "--host=0.0.0.0", "--port=5000"]


#########################################################################################
# Build package for local development
#########################################################################################

FROM base as develop
COPY . .
RUN $VIRTUAL_ENV/bin/pip install --editable .[test]
ENTRYPOINT ["/opt/venv/bin/uvicorn", "portfolio.main:app", "--host=0.0.0.0", "--port=5000", "--reload"]



# # Install dependencies
# RUN pip install --upgrade pip
# COPY requirements.txt requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt

# COPY . .

# RUN chown -R portfolio:portfolio ./
# USER portfolio
# EXPOSE 5000

# CMD ["uvicorn", "main:app", "--port=5000", "--reload"]