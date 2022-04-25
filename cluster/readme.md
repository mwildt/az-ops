# Kubernetes Setup

Die Virtuelle Maschine kann für Kubernetes vorbereitet werden. Dazu müssen einige Pakete installiert und ein paar Anpassungen
an der VM vorgenommen werden. Zunächst wir das Install-Skript geladen.

```
curl https://raw.githubusercontent.com/mwildt/az-ops/main/cluster/install.sh -o install.sh
```

Und dann die Installation mittels des k8s-master skripts ausgeführt.
```
sudo ./install.sh -- k8s-master.sh
```
Danach kann der Kubernes-Knoten als Master initialisiert werden:

```
sudo kubeadm init \
--apiserver-cert-extra-sans 20.113.163.189 \
--pod-network-cidr=192.168.0.0/16 \
| sudo tee -a /var/logs/kubeadm-init.logs
```
Die Option apiserver-cert-extra-sans gibt an, dass das eigene Zertifikat für die Kommunikation mit der Kubernetes API auch für die Public-IP der
Azure-VM guelitg ist (es muss natürlich die richtige IP/Domain eingetragen werden) Für die Verwendung von kubectl muss folgendes ausgeführt werden:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
`kubectl` ist damit auf der vm einsatzbereit. Das ausführen von `kubectl get pods --all-namespaces` sollte eine Liste aller auf definierten Pods liefern.

Damit Kubectl auch von einer entferten Maschine ausgeführt werden kann, muss die Konfiguration entsprechend übertragen werden. Wichtig: Es muss die IP in der Datei `~/.kube/config`auf die öffentliche IP der Azure-VM angepasst werden.

## Weitere Einrichtung des Kubernetes System

### DNS
Ein Aufruf von `kubectl get pods --all-namespaces` zeigt, dass schon einige Pods auf dem System laufen, einige aber eauch im status Pending sind. Hierbei handelt es sich um die Core-DNS-Pods, welche für den Betrieb des Cluster hofreich sind.

https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart

```
kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml

kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
```

 Der Aufruf von `kubectl get pods --all-namespaces` zeigt nun, dass viele der vorhandenen Pods vom Status `Pending` in den Status `Running` wechseln.

### Ausführen von PODs auf dem Master-Node
Kubernetes sieht eigentlich nicht vor, dass auch auf derm Master-Node Pods deployt werden (dieser ist für die Steuerung vorbehalten). Diese Einschränkung kann aber für unser Single-Node-Szenario expliziet deaktiviert werden. Dazu muss folgdenes ausgeführt werden.

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Weitere Schritte
Das Single-Node Cluster ist damit Erfolgreich gestartet. Es können nun weitere Deployments und Konfigurationen durcheführt werden.

* Das Kubernetes Dashboard deployen
* Traefk als Inress-Controller deployen
* Eine App Deployen und Mittels Ingress öffentlich verfügbar machen
* Das Dashboard öffentlich verfügbar machen.

