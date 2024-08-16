Mednafen-Server using Docker Compose
=====
This example defines a basic set up for a Mednafen-Server using Docker Compose. 

## Project structure
```shell
.
├── docker-compose.yml
├── mednafen-server.env
├── secret.txt
└── README.md
```

## [Compose file](docker-compose.yml)
```yaml
services:
  mednafen-server:
    image: k4rian/mednafen-server:latest
    container_name: mednafen-server
    hostname: mednafen
    volumes:
      - data:/home/mednafen
      - /etc/localtime:/etc/localtime:ro
    env_file:
      - mednafen-server.env
    secrets:
      - mednafenserver
    ports:
      - 4046:4046/tcp
    ulimits:
      memlock: -1
    restart: unless-stopped

volumes:
  data:

secrets:
  mednafenserver:
    file: ./secret.txt
```

* The environment file *[mednafen-server.env](mednafen-server.env)* holds the server environment variables.

* The server password is defined in the *[secret.txt](secret.txt)* file.<br>
Compose will mount it to `/run/secrets/mednafenserver` within the container.

* The secret name must be `mednafenserver`.

* To make the server public, omit the `secrets` definitions in the Compose file.

## Deployment
```bash
docker compose -p mednafen-server up -d
```
> The project is using a volume in order to store the server data that can be recovered if the container is removed and restarted.

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