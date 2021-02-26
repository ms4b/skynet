call version.cmd
cd ..
docker build --tag ms4b/1c-server:%ver% .
docker push ms4b/1c-server:%ver%
