FROM python:3.12-alpine
WORKDIR /svc
RUN pip install --no-cache-dir flask==3.0.0
COPY app.py .
EXPOSE 9000
USER nobody
CMD ["python", "app.py"]
