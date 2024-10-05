FROM hashicorp/terraform:latest AS terrafrom


WORKDIR /terraform  

COPY . .  

RUN command terraform plan --out tfplan_large.binary -refresh=false

RUN command terraform plan --out tfplan_large.binary -refresh=false

RUN terraform show -json tfplan_large.binary > tfplan_large.json

FROM openpolicyagent/conftest