call version.cmd
docker run --hostname 1c-hasp -ti ms4b/1c-hasp:%ver%
#docker run -ti -v /lib/modules:/lib/modules -v /var/volumes/1c-hasp:/tmp/res ms4b/1c-hasp:3.10.0-1062.9.1.el7.x86_64