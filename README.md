[![Docker Pulls](https://img.shields.io/docker/pulls/aklitzing/virtlyst.svg)](https://hub.docker.com/r/aklitzing/virtlyst)


Virtlyst in Docker
==================

**docker-compose.yml**
```
services:
  virtlyst:
    image: aklitzing/virtlyst
    container_name: virtlyst
    volumes:
      - virtlyst:/root
    restart: always
    ports:
      - "80:80"

volumes:
  virtlyst:
```

Start up: ``docker compose up -d``


SSH
===

Virtlyst will prompt on container console for authentication.
So it is easier to add an ssh key.

Call these commands inside the container.
```
$ ssh-keygen
$ ssh-copy-id user@host
```

