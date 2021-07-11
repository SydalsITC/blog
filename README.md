And he said ...
# "Let there be byte!"

Hi. I'm a Linux and IoT fan, currently working on cloud projects with Kubernetes and Helm. Some bits and bytes of my projects might be usefull for some of you, so I'm trying to publish some small projects from time to time, collecting them in this repo which I use as a kind of blog.

## Back To The future
Moving an application is easy if it#s installed in a VM - you just manipulate the VMs clock. In a Kubernetes cluster, all Nodes must stay in sync on the same time, and tus the applicatiosn running in the containers also all share te same time. Moving a node in time would mess up the cluster, and moving a single container seems impossible - but it gets easy, once you get hands on a [flux capacitor](backIntoTheFuture.md).

## Say my name
The example at [env-httpd.md](env-httpd.md) shows a small http server for providing central information like stage name or admin contact for your applications and developers with just a small nginx deployment and a configmap.

## Cheat sheet for kubernetes admins

<img src="img/postit_640px.jpg" width="100" align="right"/>And for those on the path to become one. Make your life easier with some aliases and functions in your bashrc or bash_aliasess file (depending on your distribution). You'll find some handy examples in [k8s-cheatsheet.md](k8s-cheatsheet.md).
