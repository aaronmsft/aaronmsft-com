# Docker for Azure Functions Core Tools

See: [Dockerfile](Dockerfile)

## build/push/run docker image
```bash
docker build -t aaronmsft/azure-functions-core-tools:latest -f Dockerfile .

docker push aaronmsft/azure-functions-core-tools:latest

docker run --rm -v ${PWD}:/pwd/ -w /pwd/ -p 7071:7071 -it aaronmsft/azure-functions-core-tools:latest bash
```

## create a new (python) function
```
apt-get install python3-venv

python3 -m venv .
. bin/activate
func init 
# select: 3
func new
# select: 5
```
