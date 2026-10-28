FROM python:3.13-alpine
RUN adduser -D -u 1001 app && mkdir /data && chown app /data
WORKDIR /app
COPY app.py .
ENV GREETING=hello
EXPOSE 8000
USER app
CMD ["python", "app.py"]
