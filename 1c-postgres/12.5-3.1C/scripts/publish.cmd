call version.cmd
cd ..
docker build --tag ms4b/1c-postgres:%ver% .
docker push ms4b/1c-postgres:%ver%