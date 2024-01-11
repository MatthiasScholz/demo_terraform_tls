subj := "/C=DE/ST=Bavaria/L=Munich/O=Matthias Scholz Corp./OU=Org/CN=opinionated.xyz"
private_key:
	openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -subj $(subj) -keyout private_key.pem -out public_cert.pem

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve
