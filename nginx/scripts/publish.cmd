call version.cmd
cd ..
docker build --tag ms4b/nginx:%ver% .
docker push ms4b/nginx:%ver%