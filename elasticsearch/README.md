# Elasticsearch

`helm repo add elastic https://helm.elastic.co
"elastic" has been added to your repositories`

`curl -O https://raw.githubusercontent.com/elastic/Helm-charts/master/elasticsearch/examples/minikube/values.yaml`

`helm install --name elasticsearch elastic/elasticsearch -f ./values.yaml`