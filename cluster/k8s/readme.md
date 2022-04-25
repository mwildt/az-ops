# kubectl up an running



# deploy the dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Das Dashboard wird über die entsprechende Konfiguration gestartet

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
```

# create a admin user
kubectl --insecure-skip-tls-verify apply -f ./cluster/k8s/service-account.yml

## CREATE ADMIN ROLE BINDING
```
kubectl --insecure-skip-tls-verify apply -f ./cluster/k8s/dashboaerd-admin-user.yaml
```


```
kubectl --insecure-skip-tls-verify -n kubernetes-dashboard get secret $(kubectl --insecure-skip-tls-verify -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```



# Laden des Dashboaerd via Proxy 
```
kubectl proxy --insecure-skip-tls-verify
```

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login

# Publizieren des Kubernetes Dashboaerds via Ingres

Es kann einefach eine Ingress-Route erzegt werden, welche den vorhanden Service verendet (derselbe, der auch mittels proxy veröffentlicht wird):

servicename: kubernetes-dashboard/

Dieser ist allerdings ein https-service aus Port 443, was zu einem internal Server-Error im Traefik führt, da dem selbst erzeugte Zertifikat von Traefik nicht getraut wird. Um dieses Problem zu lösen, gibt es verschiedene Möglichkeiten:
1. Den Service ohne Https zu erstellen,
2. Traefik beizubringen, dem Zertifikat des Dashbords zu trauen
3. Treafik so zu konfigurieren, das der Zert-Check keinen Fehler verursacht (alle anderen services laufen zur zeit eh noch ohne TLS). Hierzu muss dem Traefik-Ingres-Controller das Flag `--serversTransport.insecureSkipVerify=true` überreicht werden. Eine Steuerung auf Ebende des Traefik Service Scheint zur Zeit noch  nicht zu existieren. (scheinbar zumindest nicht ohne den Traefik CRD zu verwenden https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/, https://github.com/traefik/traefik/issues/7759)


