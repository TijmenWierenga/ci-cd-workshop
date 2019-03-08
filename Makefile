copy_jenkins_pwd:
	docker exec $$(docker container ps -f name=ci_jenkins -q) cat /var/jenkins_home/secrets/initialAdminPassword | pbcopy
copy_public_key:
	cat ~/.ssh/id_rsa.pub | pbcopy
