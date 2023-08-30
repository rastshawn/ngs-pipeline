@ECHO OFF
DOSKEY _build=docker build --platform linux/amd64 -t ngs-pipeline .
DOSKEY _run=docker run --rm --platform linux/amd64 -v .\output:/root/output -v .\input:/root/input -w /root  ngs-pipeline $1
DOSKEY _clean=docker image remove -f ngs-pipeline
DOSKEY _interactive=docker run --rm --platform linux/amd64 -it --entrypoint bash -v .\output:/root/output -v .\input:/root/input -w /root  ngs-pipeline
DOSKEY _aliastest=ECHO "Aliases are enabled"
cmd.exe