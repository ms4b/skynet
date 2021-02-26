call version.cmd
docker run --hostname 1c-server --net host -ti --rm --name 1c ms4b/1c-server:%ver%
@rem docker run -ti -p 1540-1541:1540-1541 -p 1560-1591:1560-1591 ms4b/1c-server:%ver%