CHART=$1
VERSION=$2

helm package $CHART --version $2 --app-version $2 && mv $CHART-$VERSION.tgz docs && helm repo index docs --url https://proyecto-microservicios.github.io/helm-charts
