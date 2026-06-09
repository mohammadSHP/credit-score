FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN pytest tests/ -v --tb=short
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
