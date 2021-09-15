docker-mednafen-server
=====

A Docker image for the [Mednafen](https://mednafen.github.io/) standalone server based on the official [Alpine Linux](https://www.alpinelinux.org/) [image](https://hub.docker.com/_/alpine). 



## Introduction 

This image is used to set up and run a __Mednafen server__ that allow to play many emulators games online via netplay using [Mednafen](https://mednafen.github.io/).



## Environment variables

A few environment variables can be tweaked when creating a container to define the server configuration:

Variable              | Default value  | Description 
---                   | ---            | ---
MDFNSV_MAXCLIENTS     | 50             | Maximum number of clients.
MDFNSV_CONNECTTIMEOUT | 5              | Connection (login) timeout (in seconds).
MDFNSV_PORT           | 4046           | Port to listen on.
MDFNSV_IDLETIMEOUT    | 30             | Idle timeout (in seconds). Disconnect a client if no data is received from them since X seconds ago.
MDFNSV_MAXCMDPAYLOAD  | 5242880        | The maximum data in the payload of a command to be received by the server (including save state transfers).
MDFNSV_MINSENDQSIZE   | 262144         | Soft send queue start size, and minimum size (memory allocated) it will shrink to.
MDFNSV_MAXSENDQSIZE   | 8388608        | Maximum size each internal per-client soft send queue is allowed to grow to. The client is dropped on overflowing this size.
MDFNSV_PASSWORD       |                | Server password *(__NOT__ recommended, see the section below)*.

*Descriptions taken from the original __standard.conf__ file in the Mednafen server sources.*



## Password protection

The server can be protected with a (clear, unencrypted) password and defined in various ways:  

— Bind mount a text file containing the password into the container.  
The mountpoint path has to be `/run/secrets/mednafenserver`.   
This is the __recommended__ method. See the second example in the section below.

— Using the `MDFNSV_PASSWORD` environment variable when creating the container.   
This method is __NOT__ recommended for production since all environment variables are visible via `docker inspect` to any user that can use the `docker` command. 

— By editing the `server.conf` file located beside the server binary and accessed by mounting a volume on `/home/mednafen`.   



## Example uses

__Example 1:__                                 
Run a public server on port `40451` with a maximum of `4 clients` and a connection time out of `15 seconds`:    
— *The `ulimit` option is optional but highly recommended for the server to run properly.* 
```
$ docker run -d \
    --name mednafen-server \
    --ulimit memlock=-1 \
    -p 40451:40451 \
    -e MDFNSV_MAXCLIENTS=4 \
    -e MDFNSV_CONNECTTIMEOUT=15 \
    -e MDFNSV_PORT=40451 \
    -i k4rian/mednafen-server:latest
```


__Example 2:__                                     
Run a password-protected server using default configuration:   
— *In this example, the password is stored in the `secret.txt` file located in the current working directory.* 
```
$ docker run -d \
    --name mednafen-server \
    --ulimit memlock=-1 \
    -p 4046:4046 \
    -v "$(pwd)"/secret.txt:/run/secrets/mednafenserver:ro \
    -i k4rian/mednafen-server:latest
```


__Example 3:__                                     
Run a password-protected __testing__ server on port `4444`:   
```
$ docker run -d \
    --name mednafen-server-test \
    --ulimit memlock=-1 \
    -p 4444:4444 \
    -e MDFNSV_PORT=4444 \
    -e MDFNSV_PASSWORD="testing" \
    -i k4rian/mednafen-server:latest 
```



## Manual build

__Requirements__:                               
— Docker >= __18.03.1__                         
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```
$ git clone https://github.com/K4rian/docker-mednafen-server.git .
```

- Then run the following command inside the newly created folder:
```
$ docker build --no-cache -t k4rian/mednafen-server .
```



## License

[MIT](LICENSE)