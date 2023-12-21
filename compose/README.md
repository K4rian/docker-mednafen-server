Mednafen-Server using Docker Compose
=====
This example defines a basic set up for a Mednafen-Server using Docker Compose. 

Project structure:
```
.
├── docker-compose.yml
├── mednafen-server.env
├── secret.txt
└── README.md
```

[_docker-compose.yml_](docker-compose.yml)
```
services:
  mednafen-server:
    image: k4rian/mednafen-server:latest
    container_name: mednafen-server
    volumes:
      - data:/home/mednafen
      - /etc/localtime:/etc/localtime:ro
    env_file:
      - mednafen-server.env
    secrets:
      - mednafenserver
    ports:
      - 4060:4060/tcp
    ulimits:
      memlock: -1
    restart: unless-stopped

volumes:
  data:

secrets:
  mednafenserver:
    file: ./secret.txt
```

* When deploying, Compose maps the server port to the same port of the host as specified in the compose file.

* The environment file *[mednafen-server.env](mednafen-server.env)* holds the server configuration.

* The server password is defined in the *[secret.txt](secret.txt)* file.   
— Compose will mount it to `/run/secrets/mednafenserver` within the container.

* The secret name has to be `mednafenserver`.  

* To make the server public, the `secrets` definitions in the compose file have to be omitted.

## Deployment
```bash
docker compose -p mednafen-server up -d
```
*__Note__*: the project is using a volume in order to store the server data that can be recovered if the container is removed and restarted.

## Expected result
Check that the container is running properly:
```bash
docker ps | grep "mednafen"
```

To see the server log output:
```bash
docker compose -p mednafen-server logs
```

## Stop the container
Stop and remove the container:
```bash
docker compose -p mednafen-server down
```

Both the container and its volume can be removed by providing the `-v` argument:
```bash
docker compose -p mednafen-server down -v
```