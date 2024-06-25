FROM python:3.11.4

EXPOSE 5000

COPY . .

RUN pip install --no-cache -r requirements.txt && \
    mkdir -p /mlflow

CMD mlflow server \
    --host 0.0.0.0 \
    --port 5000 \
    --default-artifact-root mlops-teste-ceia-2024 \
    --backend-store-uri mysql+pymysql://admin:password123@terraform-20240528005435692400000001.cvgm5zx41sjv.us-east-1.rds.amazonaws.com:3306/mlflowdb