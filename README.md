And he said ...
# "Let there be byte!"

Hi. I'm a Linux and IoT fan, currently working on cloud projects with Kubernetes and Helm. Some bits and bytes of my projects might be usefull for some of you, so I'm trying to publish some small projects from time to time, collecting them in this repo which I use as a kind of blog.

## Flashing image
For programming an ESP32 device, I needed to install esptool.py. But unwilling to install lots of software packages I'd rather
not need anymore after the project, I built a [docker image with esptool.py](posts/esptool_docker_image.md) inside.

## SSL cheat sheet
Proper encryption with TLS is a science itself and can be quite tricky. Therefore it's neccessary to have some tools at hand if you need to check or debug things.
Because it's no everyday business to me, I always have to lookup the right commands and their arguments. So finally I decided to write my own [SSL cheat sheet](posts/ssl-cheat-sheet.md) and am glad to share it.

## Back To The future
Moving an application is easy if it's installed in a VM - you just manipulate the VMs clock. In a Kubernetes cluster, all Nodes must stay in sync on the same time, and thus the applications running in the containers also all share the same time. Moving a node in time would mess up the cluster, and moving a single container seems impossible - but it gets easy, once you get your hands on a [flux capacitor](posts/backToTheFuture.md).

## Say my name
The example at [env-httpd.md](posts/env-httpd.md) shows a small http server for providing central information like stage name or admin contact for your applications and developers with just a small nginx deployment and a configmap.

## Cheat sheet for kubernetes admins

<img src="img/postit_640px.jpg" width="100" align="right"/>And for those on the path to become one. Make your life easier with some aliases and functions in your bashrc or bash_aliasess file (depending on your distribution). You'll find some handy examples in [k8s-cheatsheet.md](posts/k8s-cheatsheet.md).
