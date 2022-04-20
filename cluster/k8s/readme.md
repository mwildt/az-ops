# kubectl up an running



# deploy the dashboard
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Das Dashboard wird über die entsprechende Konfiguration gestartet

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/


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