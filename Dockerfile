#########################################################################################
# Setup Base Environment
#########################################################################################

FROM python:3.10-slim-buster as base

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
EXPOSE 5678

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/portfolio

COPY requirements.txt .
RUN pip install --upgrade setuptools pip && \
    pip install -r requirements.txt && \
    rm requirements.txt

ENTRYPOINT [ "/bin/bash" ]

#########################################################################################
# Build Runtime Package
#########################################################################################

FROM base as builder

COPY . .
RUN pip install -r requirements-dev.txt && \
    python -m build --wheel

#########################################################################################
# Install Runtime package
#########################################################################################

FROM base as runtime
COPY --from=builder /home/portfolio/dist/ build/
RUN find build/ -maxdepth 1 -name "*.tar.gz" -o -name "*.whl" | xargs -r -n1 -t pip install && \
    rm -r build/

ENTRYPOINT ["uvicorn", "portfolio.main:app", "--host=0.0.0.0", "--port=5678"]
# ENTRYPOINT [ "/bin/bash" ]
