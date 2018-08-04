nodes:
  - address: ${IP01} # hostname or IP to access nodes
    user: ubuntu # root user (usually 'root')
    role: [controlplane,etcd,worker] # K8s roles for node
    ssh_key_path: ~/.ssh/${SSH_KEY}.pem # path to PEM file
  - address: ${IP02}
    user: ubuntu
    role: [controlplane,etcd,worker]
    ssh_key_path: ~/.ssh/${SSH_KEY}.pem
  - address: ${IP03}
    user: ubuntu
    role: [controlplane,etcd,worker]
    ssh_key_path: ~/.ssh/${SSH_KEY}.pem

addons: |-
  ---
  kind: Namespace
  apiVersion: v1
  metadata:
    name: cattle-system
  ---
  kind: ServiceAccount
  apiVersion: v1
  metadata:
    name: cattle-admin
    namespace: cattle-system
  ---
  kind: ClusterRoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: cattle-crb
    namespace: cattle-system
  subjects:
  - kind: ServiceAccount
    name: cattle-admin
    namespace: cattle-system
  roleRef:
    kind: ClusterRole
    name: cluster-admin
    apiGroup: rbac.authorization.k8s.io
  ---
  apiVersion: v1
  kind: Service
  metadata:
    namespace: cattle-system
    name: cattle-service
    labels:
      app: cattle
  spec:
    ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
    selector:
      app: cattle
  ---
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    namespace: cattle-system
    name: cattle-ingress-http
    annotations:
      nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "1800"   # Max time in seconds for ws to remain shell window open
      nginx.ingress.kubernetes.io/proxy-send-timeout: "1800"   # Max time in seconds for ws to remain shell window open
      nginx.ingress.kubernetes.io/ssl-redirect: "false"        # Disable redirect to ssl
  spec:
    rules:
    - host: ${RANCHER_URL}
      http:
        paths:
        - backend:
            serviceName: cattle-service
            servicePort: 80
  ---
  kind: Deployment
  apiVersion: extensions/v1beta1
  metadata:
    namespace: cattle-system
    name: cattle
  spec:
    replicas: 1
    template:
      metadata:
        labels:
          app: cattle
      spec:
        serviceAccountName: cattle-admin
        containers:
        - image: rancher/rancher:latest
          args:
          - --no-cacerts
          imagePullPolicy: Always
          name: cattle-server
          ports:
          - containerPort: 80
            protocol: TCP
