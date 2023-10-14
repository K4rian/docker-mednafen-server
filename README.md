<p align="center">
 <img alt="docker-mednafen-server logo" src="https://raw.githubusercontent.com/K4rian/docker-mednafen-server/assets/icons/logo-docker-mednafen-server.svg" width="25%" align="center">
</p>

A Docker image for the [Mednafen](https://mednafen.github.io/) standalone server based on the official [Alpine Linux](https://www.alpinelinux.org/) [image](https://hub.docker.com/_/alpine).<br>
Mednafen-Server allows to play many emulator games online via netplay using the [Mednafen](https://mednafen.github.io/) multi-system emulator.

---
<div align="center">

| Docker Tag | Version | Description | Release Date |
| ---        | :---:   | ---         | :---:        |
| [latest](https://github.com/K4rian/docker-mednafen-server/blob/main/Dockerfile) | 1.1 | Latest stable release | 2023-10-13 |
</div>
<p align="center"><a href="#environment-variables">Environment variables</a> &bull; <a href="#password-protection">Password protection</a> &bull; <a href="#usage">Usage</a> &bull; <a href="#using-compose">Using Compose</a> &bull; <a href="#manual-build">Manual build</a> <!-- &bull; <a href="#see-also">See also</a> --> &bull; <a href="#license">License</a></p>

---
## Environment variables
A few environment variables can be tweaked when creating a container to define the server configuration:

<details>
<summary>Click to expand</summary>

Variable              | Default value  | Description 
---                   | ---            | ---
MDFNSV_MAXCLIENTS     | 50             | Maximum number of clients.
MDFNSV_CONNECTTIMEOUT | 5              | Connection (login) timeout (in seconds).
MDFNSV_PORT           | 4046           | Port to listen on (TCP).
MDFNSV_IDLETIMEOUT    | 30             | Idle timeout (in seconds). Disconnect a client if no data is received from them since X seconds ago.
MDFNSV_MAXCMDPAYLOAD  | 5242880        | The maximum data (in bytes) in the payload of a command to be received by the server (including save state transfers).
MDFNSV_MINSENDQSIZE   | 262144         | Soft send queue start size (in bytes), and minimum size (memory allocated) it will shrink to.
MDFNSV_MAXSENDQSIZE   | 8388608        | Maximum size (in bytes) each internal per-client soft send queue is allowed to grow to. The client is dropped on overflowing this size.
MDFNSV_PASSWORD       |                | Server password *(__NOT__ recommended, see the section below)*.
MDFNSV_ISPUBLIC       | 0              | Make the server public. Ignore the password environment variable (if set) and remove any existing password from the configuration file.

*Descriptions mostly taken from the original __standard.conf__ file in the Mednafen-Server sources.*
</details>

## Password protection
The server can be protected with a (clear, unencrypted) password and defined in various ways:  

— Bind mount a text file containing the password into the container.<br>
The mountpoint path has to be `/run/secrets/mednafenserver`.<br>
This is the __recommended__ method. See the second example in the section below.

— Using the `MDFNSV_PASSWORD` environment variable when creating the container.<br>
This method is __NOT__ recommended for production since all environment variables are visible via `docker inspect` to any user that can use the `docker` command. 

— By editing the `server.conf` file located beside the server binary and accessed by mounting a volume on `/home/mednafen`.

## Usage
__Example 1:__<br>
Run a public server on port `40451` with a maximum of `4 clients` and a connection time out of `15 seconds`:<br>
— *The `ulimit` option is optional but highly recommended for the server to run properly.* 
```bash
docker run -d \
  --name mednafen-server \
  --ulimit memlock=-1 \
  -p 40451:40451 \
  -e MDFNSV_MAXCLIENTS=4 \
  -e MDFNSV_CONNECTTIMEOUT=15 \
  -e MDFNSV_PORT=40451 \
  -e MDFNSV_ISPUBLIC=1 \
  -i k4rian/mednafen-server:latest
```

__Example 2:__<br>
Run a password-protected server using default configuration:<br>
— *In this example, the password is stored in the `secret.txt` file located in the current working directory.* 
```bash
docker run -d \
  --name mednafen-server \
  --ulimit memlock=-1 \
  -p 4046:4046 \
  -v "$(pwd)"/secret.txt:/run/secrets/mednafenserver:ro \
  -i k4rian/mednafen-server:latest
```

__Example 3:__<br />
Run a password-protected __testing__ server on port `4444`:<br>
```bash
docker run -d \
  --name mednafen-server-test \
  --ulimit memlock=-1 \
  -p 4444:4444 \
  -e MDFNSV_PORT=4444 \
  -e MDFNSV_PASSWORD="testing" \
  -i k4rian/mednafen-server:latest 
```

## Using Compose
See [compose/README.md](compose/)

## Manual build
__Requirements__:<br>
— Docker >= __18.09.0__<br>
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```bash
git clone https://github.com/K4rian/docker-mednafen-server.git .
```

- Then run the following command inside the newly created folder:
```bash
docker build --no-cache -t k4rian/mednafen-server .
```
<!---
## See also
* __[Mednafen-Server Egg](https://github.com/K4rian/)__ — A custom egg of Mednafen-Server for the Pterodactyl Panel.
* __[Mednafen-Server Template](https://github.com/K4rian/)__ — A custom template of Mednafen-Server ready to deploy from the Portainer Web UI.
--->
## License
[MIT](LICENSE)