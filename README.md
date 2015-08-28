# Jenkins JNLP slave Docker image

[`jenkinsci/jnlp-slave`](https://hub.docker.com/r/jenkinsci/jnlp-slave/)

A [Jenkins](https://jenkins-ci.org) slave using JNLP to establish connection.

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more info.

## Running

To run a Docker container

    docker run jenkinsci/jnlp-slave -url http://jenkins-server:port <secret> <slave name>

optional environment variables:

* `JENKINS_URL`: url for the Jenkins server, can be used as a replacement to `-url` option, or to set alternate jenkins URL
* `JENKINS_TUNNEL`: (`HOST:PORT`) connect to this slave host and port instead of Jenkins server, assuming this one do route TCP traffic to Jenkins master. Useful when when Jenkins runs behind a load balancer, reverse proxy, etc.

