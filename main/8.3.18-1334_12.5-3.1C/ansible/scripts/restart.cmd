cd ..
docker stop ansible
pause
docker run --name=ansible --rm --privileged --volume=C:\Users\ijea\IdeaProjects\skynet\src\github.com\ms4b\skynet\main\ansible\roles:/etc/ansible/roles:ro --volume=C:\Users\ijea\IdeaProjects\skynet\src\github.com\ms4b\skynet\main\ansible\test:/home:rw ms4b/ansible
