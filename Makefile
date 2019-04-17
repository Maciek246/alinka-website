start:
	bash ./.makefile/start.sh

stop:
	docker-compose stop

clean:
	bash ./.makefile/clean.sh

local:
	docker-compose exec -T app npm start --host 0.0.0.0

test:
	docker-compose exec app npm run test --all --ci

bash:
	docker-compose exec app bash

PROFILE=default
credentials:
	cat ~/.aws/credentials
	docker-compose exec app aws configure --profile $(PROFILE)

deploy:
	docker-compose exec -T app bash ./.makefile/deploy.sh
