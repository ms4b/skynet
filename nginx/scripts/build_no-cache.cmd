call version.cmd
cd ..
docker build --no-cache --tag ms4b/nginx:%ver% .
