call version.cmd
cd ..
docker build --tag ms4b/1c-apache:%ver% .
docker push ms4b/1c-apache:%ver%