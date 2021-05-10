# Pull official base image
FROM python:3.9-alpine

# Create the app user
RUN addgroup -S portfolio && adduser -S portfolio -G portfolio

# Set work directory inside container
WORKDIR /home/portfolio

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apk update \
    && apk add gcc python3-dev musl-dev build-base curl

# Install dependencies
RUN pip install --upgrade pip
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chown -R portfolio:portfolio ./
USER portfolio
EXPOSE 5000

CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--port=5000"]