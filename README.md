# helm-charts
Charts con diferentes implementaciones de patrones de microservicios

## Table of contents

- [Prerequisitos](#prerequisitos)
- [Minikube](#minikube)
- [Helm 3](#helm3)

## Prerequisitos

[Minikube](https://minikube.sigs.k8s.io/docs/start/) implementa un cluster local de [Kubernetes](http://kubernetes.io) en macOS, Linux y Windows.
[Helm](https://helm.sh) es el estándar para manejar aplicaciones hechas para Kubernetes.

# Instalación
## Docker
https://docs.docker.com/get-docker/

```
docker version
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b
 Built:             Wed Mar 11 01:26:01 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b
  Built:            Wed Mar 11 01:24:39 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```
## minikube
https://kubernetes.io/es/docs/tasks/tools/install-minikube/
https://kubernetes.io/docs/setup/learning-environment/minikube/

```
minikube version
minikube version: v1.12.1
commit: 5664228288552de9f3a446ea4f51c6f29bbdd0e0-dirty
```
## kubectl
https://kubernetes.io/es/docs/tasks/tools/install-kubectl/
```
kubectl version
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.2", GitCommit:"52c56ce7a8272c798dbc29846288d7cd9fbae032", GitTreeState:"clean", BuildDate:"2020-04-16T11:56:40Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.3", GitCommit:"2e7996e3e2712684bc73f0dec0200d64eec7fe40", GitTreeState:"clean", BuildDate:"2020-05-20T12:43:34Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}
```
## helm
https://helm.sh/docs/intro/install/
```
helm version
version.BuildInfo{Version:"v3.2.4", GitCommit:"0ad800ef43d3b826f31a5ad8dfbb4fe05d143688", GitTreeState:"clean", GoVersion:"go1.13.12"}
```
# Run

## Start minikube
```
minikube start --cpus 4 --memory 8192

😄  minikube v1.12.1 on Fedora 29
🎉  minikube 1.13.1 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.13.1
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

✨  Using the docker driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
🐳  Preparing Kubernetes v1.18.3 on Docker 19.03.2 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube"
```
https://kubernetes.io/docs/setup/learning-environment/minikube/

## Desplegar ELK
## Desplegar cluster Elasticsearch
Agregar repositorio de elastic a los locales.
```
helm repo add elastic https://helm.elastic.co
"elastic" has been added to your repositories
```
Bajar values específicos para helm para instalar un cluster multinodo.
```
curl -O https://raw.githubusercontent.com/elastic/Helm-charts/master/elasticsearch/examples/minikube/values.yaml
```
Instalar Elasticsearch en el cluster de kubernetes que levantamos con minikube a partir del chart en el repo elastic y los values que bajamos. Si no se elige un namespace se hace en el namespace default.
```
helm install elasticsearch elastic/elasticsearch -f ./values.yaml

NAME: elasticsearch
LAST DEPLOYED: Sun Oct 11 20:51:54 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=default -l app=elasticsearch-master -w
2. Test cluster health using Helm test.
  $ helm test elasticsearch --cleanup
```
Podemos mapear el puerto 9200 del master a nuestro host para verificar que todo esté configurado y funcionando correctamente.

```
kubectl port-forward svc/elasticsearch-master 9200

Forwarding from 127.0.0.1:9200 -> 9200
Forwarding from [::1]:9200 -> 9200
```

Si vamos al navegador y consumimos localhost:9200 debería verse una salida como la siguiente:
```
{
  "name" : "elasticsearch-master-1",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "kxwONuevQ4eVrWqDP3dAww",
  "version" : {
    "number" : "7.9.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "d34da0ea4a966c4e49417f2da2f244e3e97b4e6e",
    "build_date" : "2020-09-23T00:45:33.626720Z",
    "build_snapshot" : false,
    "lucene_version" : "8.6.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Desplegar Kibana UI

```
helm install kibana elastic/kibana

NAME: kibana
LAST DEPLOYED: Sun Oct 11 22:21:03 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Para poder acceder a kibana desde el host sin necesidad de mantener el port forwarding exponemos el deployment en un puerto del nodo.

```
kubectl delete service kibana-kibana
service "kibana-kibana" deleted

kubectl expose deployment kibana-kibana --Port=5601 --type=NodePort
service/kibana-kibana exposed
```

Ahora chequeamos como acceder a este servicio en minikube.

```
minikube service kibana-kibana --url
http://172.17.0.3:30199
```
Si accedemos a esa URL desde el navegador veremos la interfaz de Kibana.

## Desplegar Filebeat
FIlebeat se encarga de tomar los logs de los diferentes servicios que corren en el cluster y llevarlos a Elasticsearch para que sean indexados y luego mostrados en Kibana.

```
helm install filebeat elastic/filebeat --version 7.9.2

NAME: filebeat
LAST DEPLOYED: Sun Oct 11 22:38:05 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Watch all containers come up.
  $ kubectl get pods --namespace=default -l app=filebeat-filebeat -w
```
Una vez que el deployment queda listo en este momento tenemos el siguiente estado en el cluster:
```
kubectl get pods

NAME                                             READY   STATUS    RESTARTS   AGE
elasticsearch-master-0                           1/1     Running   0          115m
elasticsearch-master-1                           1/1     Running   0          115m
elasticsearch-master-2                           1/1     Running   0          115m
filebeat-filebeat-d92bz                          1/1     Running   0          8m55s
kibana-kibana-7bcd98966b-76fbt                   1/1     Running   0          25m

kubectl get services

NAME                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
elasticsearch-master            ClusterIP   10.100.169.185   <none>        9200/TCP,9300/TCP   115m
elasticsearch-master-headless   ClusterIP   None             <none>        9200/TCP,9300/TCP   115m
kibana-kibana                   NodePort    10.111.130.192   <none>        5601:30199/TCP      21m
kubernetes                      ClusterIP   10.96.0.1        <none>        443/TCP             156m

helm list

NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
elasticsearch   default         1               2020-10-11 20:51:54.71541471 -0300 -03  deployed        elasticsearch-7.9.2     7.9.2
filebeat        default         1               2020-10-11 22:38:05.484498432 -0300 -03 deployed        filebeat-7.9.2          7.9.2
kibana          default         1               2020-10-11 22:21:03.402156087 -0300 -03 deployed        kibana-7.9.2            7.9.2
```
Podemos verificar que los logs que Filebeat envía ya están siendo indexados en Elasticsearch:

```
kubectl port-forward svc/elasticsearch-master 9200

curl localhost:9200/_cat/indices

green open .kibana-event-log-7.9.2-000001   J6foJ1_TQgyzf5UTxy9dqA 1 1    1  0  11.1kb  5.5kb
green open .apm-custom-link                 CpuzUPU2SaOEdCUkIU7sDw 1 1    0  0    416b   208b
green open .kibana_task_manager_1           sEnduuJjS3WapqDTynDZ2w 1 1    6 72 123.7kb 78.3kb
green open filebeat-7.9.2-2020.10.12-000001 NRwzWijfR-qhM_i1Abo7_Q 1 1 1390  0   1.7mb  554kb
green open .apm-agent-configuration         6X1NDyZkTtOQucQyzSMnUw 1 1    0  0    416b   208b
green open .kibana_1                        I7Ldc30DRHa3XxlWhgmbnQ 1 1   21  1  20.8mb 10.4mb

```
El siguiente paso consiste en realizar las configuraciones necesarias en Kibana y Elasticsearch para poder ver los logs que manda Filebeat.

**Management → Kibana → Index Patterns → Create index pattern**
filebeat-* -> @timestamp


## Desplegar Metricbeat
Metricbeat se encarga de obtener metricas de los diferentes servicios que corren en el cluster y llevarlas a Elasticsearch para que sean indexadas y luego mostradas en Kibana.
```
helm install metricbeat elastic/metricbeat

NAME: metricbeat
LAST DEPLOYED: Sun Oct 11 22:45:45 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Watch all containers come up.
  $ kubectl get pods --namespace=default -l app=metricbeat-metricbeat -w
```
La configuración en Kibana es muy similar a la de Filebeat.

## Deployment de prueba
## Hello World

Parados en el repositorio de charts:
```
helm install hello-world --generate-name

NAME: hello-world-1602469792
LAST DEPLOYED: Sun Oct 11 23:29:52 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
```
Usando el siguiente filtro **kubernetes.container.name: hello-world** podemos ver en Kibana los logs de este servicio de prueba.

Borramos el release ya que no lo usaremos.
```
helm delete hello-world-1602469792

release "hello-world-1602469792" uninstalled
```

## Desplegar Kong Api Gateway

## Desplegar Nginx Ingress Controller
