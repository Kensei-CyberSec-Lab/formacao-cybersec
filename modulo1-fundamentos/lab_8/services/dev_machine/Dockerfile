# services/dev_machine/Dockerfile
# (sem alterações, já continha uma flag)
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install Flask==2.0.1 Werkzeug==2.0.3
EXPOSE 22 5000 8080 1337
CMD python flag_server.py & flask run --host=0.0.0.0 --port=5000