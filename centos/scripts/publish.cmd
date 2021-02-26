call version.cmd
cd ..
docker build --tag ms4b/centos:%ver% .
docker push ms4b/centos:%ver%