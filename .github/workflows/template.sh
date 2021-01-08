echo "=======================> prometheus-pushgateway "
helm repo add temp  https://openinfradev.github.io/hanu-helm-repo/
helm template prometheus-pushgateway temp/prometheus-pushgateway --version 1.4.3 -f 907.split.yaml.vo
helm repo remove temp 
