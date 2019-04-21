start:
	bash ./.makefile/start.sh

stop:
	docker-compose stop

clean:
	bash ./.makefile/clean.sh

local:
	docker-compose exec -T app npm start --host 0.0.0.0

bash:
	docker-compose exec app bash

PROFILE=default
credentials:
	cat ~/.aws/credentials
	docker-compose exec app aws configure --profile $(PROFILE)

TARGET=
deploy:
	docker-compose exec -T app terraform init -reconfigure -backend-config=config/$(TARGET).tfbackend
	docker-compose exec -T app terraform apply -auto-approve -var-file=config/$(TARGET).tfvars
