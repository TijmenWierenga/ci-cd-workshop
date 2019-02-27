# CI/CD Cluster

## Setup Docker Registry
For the cluster we are going to extend the Jenkins image with some Docker capabilities. Therefore we need a private registry where we can store our custom images. Create the registry as a service in our cluster:
``` bash
docker service create \
  --publish 5000:5000 \
  --name registry \
  registry:2
```

## Build Jenkins
Jenkins needs a custom build with Docker installed to be able to mount the docker socket and pass it to Docker build slaves. Therefore, build the custom image. The image has Docker included and permissions are configured correctly so it can run with the regular Jenkins user.

``` bash
DOCKER_BUILDKIT=1 docker build -t localhost:5000/tijmen/jenkins:lts ./jenkins
```

Finally, push the image to the registry:

``` bash
docker push localhost:5000/tijmen/jenkins:lts
```

## Setup Gitea/Jenkins
Deploy the basic services

``` bash
docker stack deploy -c docker-compose.yml ci
```


## Start Jenkins
``` bash
open "http://$(docker-machine ip default):8080"
```

Get root password:
``` bash
make copy_jenkins_pwd
```

Install the suggested plugins.

## Config Gitea
``` bash
open "http://$(docker-machine ip default):3000"
```
At the moment, the `SSL_DOMAIN` environment variable is not set automatically.

Set it to the *IP address of the Docker daemon*, which will be **192.168.99.100** or **localhost**.

## Connect Gitea with Jenkins
* Create account in Gitea
* Download **Gitea** and **Docker** plugin for Jenkins
* Configure Gitea plugin:
  * [Add server here](http://192.168.99.100:8080/configure)
  * Use credentials from Gitea account
  * The host to connect to is [http://192.168.99.100:3000](http://192.168.99.100:3000)
  * Use username as organization name
* Click **new item** -> **Gitea organization** and enter your username as the item's name.

## Config Docker in Jenkins (docker-machine)
Download the Docker plugin and browse to [/configure](http://192.168.99.100:8080/configure).
Add a new cloud (Docker) with the following details:

key | value |
-----|-----|
Name | docker |
Docker Host URI | unix:///var/run/docker.sock |
Docker Hostname or IP address | unix:///var/run/docker.sock |

After that, click `test connection` to confirm everything is working.

Next, configure a Docker Agent Template with the following details:

key | value |
-----|--------|
Labels | docker |
Enabled | true |
Name | docker |
Docker Image | odavid/jenkins-jnlp-slave |

Also add the container settings for the template:

key | value |
-----|-----|
Volumes | /var/run/docker.sock:/var/run/docker.sock |

Last but not least set the connect method to **Connect with JNLP** and click **save**.
