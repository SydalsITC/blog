# Simple httpd for providing environment parameters

Sometimes your applications need to know what stage they're on - dev, qa or prod. There're lots of possibilities to solve this. Here's a small example how we realized this in some small test environment.

Basically we deployed an nginx http server. Because we didn't want a persistent volume for the wwwroot, we decided to put the few bytes of central information into a configmap and moutn this as wwwroot.

## configmap.yaml
The wwwroot is stored inside a configmap which provides the index.html and other files. In our Poc, we stored the central cluster information in a file called cluster.yaml. Important: the configmap must be deployed before the nginx web server.
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: wwwroot
  namespace: kube-system
data:
  # example of a complex property defined using --from-file
  index.html: |-
    <html>
      <body>
      <h1>env http in kube-system</h1>
      get cluster name, stage etc. at <a href="/cluster.yaml">/cluster.yaml</a>.
      </body>
    </html>
  cluster.yaml: |-
    stage: "demo"
    name: "rancher-demo.mycompany.tld"
    contact:
      mail: "k8s@servicedesk.mycompany.tld"
      phone: "123 456"
  # examples of one-liner property files
  stage.txt: "demo\n"
  cluster.json: "{\n  \"stage\": \"demo\",\n  \"name\": \"rancher-demo.mycompany.tld\"\n}\n"

```
## Deploy the http server
In the next step, two nginx pods get deployed. They listen on port 8080 which avoids some issues on clusters where pods are not allowed to run privileged.
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: env-httpd
  namespace: kube-system
  labels:
    app: env-httpd
spec:
  replicas: 2
  selector:
    matchLabels:
      app: env-httpd
  template:
    metadata:
      name: env-httpd
      labels:
        app: env-httpd
    spec:
      containers:
        - name: env-httpd
          # thegeeklab provides an nginx which runs at 8080; this avoid some
          # issues in cluster where pods are not allowed to run as root
          image: quay.io/thegeeklab/nginx:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
              name: http-port-pod
              protocol: TCP
          volumeMounts:
            - name: wwwroot-volume
              # default nginx wwwroot often is /var/www/html
              # thegeeklab/nginx uses /var/lib/nginx/html
              mountPath: /var/lib/nginx/html
      restartPolicy: Always
      volumes:
        - name: wwwroot-volume
          configMap:
            name: wwwroot
```

## At your service.
This deployment needs a service to become accessible to the outside world:
```
---
apiVersion: v1
kind: Service
metadata:
  name: env
  namespace: kube-system
spec:
  selector:
    app: env-httpd
  ports:
    - name: env
      port: 80
      targetPort: http-port-pod

```
The http server is now available inside the cluster at env.kube-system.svc.cluster.local and provides the cenral configuration as yaml like this:
```
stage: "demo"
name: "rancher-demo.mycompany.tld"
contact:
  mail: "k8s@servicedesk.mycompany.tld"
  phone: "123 456"
```
This is just a small example. The yaml may provide more information if needed like what ticket system to use if there's a problem. Or one may add other files with special configuration, one for each applicatiaon.

## Downsides
A small disadvantage is that once you update the configmap, the new data doesn't get visible in the http server until you restart the pods manually. To get around this, a helm chart for this deployment would help, where helm generates a _checksum_ on the configmap and stores this in the deployment. This ensures that helm restarts the pods if the "wwwroot" config changes.

