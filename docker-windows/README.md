# Docker on Windows

Below are some aliases and a Dockerfile that I've found useful for running Docker on Windows 10 for local development scenarios, particularly on my [Surface Go](https://aaronmsft.com/posts/surface-go-developers/), which I previously used almost exclusely via Ubuntu.

Add aliases to `profile.ps1`.
```powershell
code-insiders $PsHome\profile.ps1
# copy aliases from profile.ps1
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

Build `drun` docker image.
```
.\build.ps1
```

Run `dbash` or `drun` aliases.
```
dbash

drun golang

drun python bash
```

# Resources
- https://docs.docker.com/install/linux/docker-ce/binaries/#install-daemon-and-client-binaries-on-linux
