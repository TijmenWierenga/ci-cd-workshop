copy_jenkins_pwd:
	docker exec $$(docker container ps -f ancestor=localhost:5000/tijmen/jenkins:lts -q) cat /var/jenkins_home/secrets/initialAdminPassword | pbcopy