#!/bin/bash

# Define the docker-compose content
compose_content=$(cat <<EOF
version: "3.8"

services:
  mysql:
    image: mariadb:10.4
    ports:
      - 3306:3306
      - 2222:22
    environment:
      MYSQL_ROOT_PASSWORD: test
      MYSQL_USER: test
      MYSQL_PASSWORD: test
    volumes:
      - mysql:/var/lib/mysql
    restart: unless-stopped

  phpmyadmin:
    image: phpmyadmin:latest
    ports:
      - 8080:80
    environment:
      PMA_HOST: mysql
      PMA_USER: test
      PMA_PASSWORD: test
    restart: unless-stopped

volumes:
  mysql:
EOF
)

echo "$compose_content" > docker-compose.yaml

# Update package lists and install docker-compose if necessary
sudo apt-get update
sudo apt-get install -y docker-compose

# Install the latest docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start Docker containers
docker compose up -d

# Wait for the containers to be fully up and running
sleep 5

# Show the status of all containers
docker ps -a

# Capture the name of the MySQL container

# Restart Docker containers
docker compose down

sleep 5

docker compose up -d

sleep 5

# Show the status of all containers again
docker ps -a

mysql_container=$(docker ps --filter "name=mysql" --format "{{.Names}}")
sleep 2

docker exec -it "$mysql_container" mysql -u root -p"test" -e "GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' IDENTIFIED BY 'test' WITH GRANT OPTION; FLUSH PRIVILEGES;"


xdg-open http://localhost:8080
