#### <font color="blue">ConfigMap的使用</font>

---

ConfigMap用于将配置文件从容器镜像中解耦，从而增强容器应用的可移植性。ConfigMap API Resource将配置数据以键值对的形式存储，这些数据可以在Pod中消费或者为系统组件提供配置，用来设定应用环境参数、配置文件等。

这里我们用ConfigMap来进行配置文件加载。

# 注册ConfigMap资源

1. 和k8s的其他资源一样，ConfigMap也可以通过yaml文件来进行注册，资源类型为ConfigMap

	```js
	$ cat config.yaml
	apiVersion: v1
	kind: ConfigMap
	metadata:
	  name: special-config
	  namespace: default
	data:
	  response: |
	    hello, world
	    
	$ kubectl apply -f config.yaml
	```

2. 通过`kubectl describe configmap special-config`可以看到，该name为`special-config`的ConfigMap资源已经完成了注册

	```js
	Name:         special-config
	Namespace:    default
	Labels:       <none>
	Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"v1","data":{"response":"hello, world\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"special-config","namespace":"default"}}...
	
	Data
	====
	response:
	----
	hello, world
	
	Events:  <none>
	```
	
	注册的内容为一个key-value对：`response`: `hello, world`

# 引用ConfigMap资源

1. 创建一个简单的镜像

	```js
	$ cat demo.go
	package main

	import (
		"io"
		"io/ioutil"
		"log"
		"net/http"
	)
	
	// HelloServer the web server
	func HelloServer(w http.ResponseWriter, req *http.Request) {
		b, err := ioutil.ReadFile("config.toml")
		if err != nil {
			io.WriteString(w, err.Error())
		} else {
			w.Write(b)
		}
	}
	
	func main() {
		http.HandleFunc("/", HelloServer)
		log.Fatalf("ListenAndServe: %v", http.ListenAndServe(":8080", nil))
	}
	
	$ cat Dockerfile
	FROM golang:1.9.6
	
	COPY ./demo.go /go/src/
	WORKDIR /go/src
	
	CMD ["go", "run", "demo.go"]
	
	$ docker build -t demo-hello:v1 .
	```
	
	该镜像启动一个服务器，每次收到请求时把config.toml文件中配置的内容返回给客户端
	
2. 使用Deployment模式部署应用服务

	```js
	$ cat hello.yaml
	apiVersion: extensions/v1beta1
	kind: Deployment
	metadata:
	  name: gm-v1
	  labels:
	    app: gm-v1
	spec:
	  replicas: 2
	  selector:
	    matchLabels:
	      app: gm-v1
	  template:
	    metadata:
	      labels:
	        app: gm-v1
	    spec:
	      containers:
	      - name: gm-v1
	        image: demo-hello:v1
	        volumeMounts:
	        - name: config-volume
	          mountPath: /etc/config
	      volumes:
	        - name: config-volume
	          configMap:
	            name: special-config
	---
	apiVersion: v1
	kind: Service
	metadata:
	  name: gm-v1
	spec:
	  ports:
	  - name: http
	    port: 80
	    targetPort: 8080
	    nodePort: 30011
	  type: NodePort
	  selector:
	    app: gm-v1
	    
	$ kubectl apply -f hello.yaml
	```
	
	* 在这里，我们通过`volumeMounts`将`config-volume`挂载到容器的`/etc/config`目录
	* 设定`config-volume`对应name为`special-config`的ConfigMap资源，则该ConfigMap里的所有内容都会被挂载到指定的目录里去
	* 如果需要挂载多个ConfigMap，只要在`volumeMounts`里指定多个name，并且在`volumes`里指定这些name对应的ConfigMap即可

3. 通过`kubectl get pods`可以看到该服务启动了两个pod

	```js
	NAME                     READY     STATUS    RESTARTS   AGE
	gm-v1-745d88999d-782ck   1/1       Running   0          5m
	gm-v1-745d88999d-t48rn   1/1       Running   0          5m
	```

4. 通过volumeMount挂载的ConfigMap会覆盖挂载的路径(如果路径不存在，则会创建路径并挂载），挂载在该路径下的文件以注册ConfigMap时的key-value对命名；key为文件名，value为文件内容

	```js
	$ kubectl exec -it gm-v1-745d88999d-782ck cat /etc/config/response
	hello, world
	```
	
	* 进入容器内部，通过cat命令可以看到，挂载在`/etc/config`下的文件以ConfigMap注册的key(response)命名，内容为value(hello, world)
	* 如果在注册ConfigMap时指定了多个key-value对，如
		
		```js
		data:
		  response: |
		    hello, world
		  test.conf: |
		    a = b
		```
		则会在挂载路径下创建以`response`、`test.conf`命名的文件，文件内容分别为`hello, world`，`a = b`
		
# 引用指定的key

如果我们不希望引入的ConfigMap覆盖整个挂载路径，只希望引用ConfigMap中指定的key，并且在挂载路径中生成指定的文件名，可以通过以下方法

```js
$ cat hello.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: gm-v1
  labels:
    app: gm-v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: gm-v1
  template:
    metadata:
      labels:
        app: gm-v1
    spec:
      containers:
      - name: gm-v1
        image: demo-hello:v1
        volumeMounts:
        - name: config-volume
          mountPath: /go/src/config.toml
          subPath: config.toml
      volumes:
        - name: config-volume
          configMap:
            name: special-config
            items:
            - key: response
              path: config.toml
---
apiVersion: v1
kind: Service
metadata:
  name: gm-v1
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
    nodePort: 30011
  type: NodePort
  selector:
    app: gm-v1
    
$ kubectl apply -f hello.yaml
```

* 这里我们使用`subPath`指定具体的文件名，只挂载该文件路径
* 指定挂载的ConfigMap key: `response`，对应挂载的文件`config.toml`
* 由于我们的http服务是就是打印`config.toml`中的内容，返回给客户端，因此访问服务对外的接口即可看到引用的ConfigMap中`response`对应的value

	```js
	$ curl '127.0.0.1:30011'
	hello, world
	```

# 注意

* 参考以上的例子，可以在k8s中通过ConfigMap动态地为服务加载配置资源
* 引用ConfigMap的服务，其namespace要和对应的ConfigMap资源一致
* 如果使用的是subPath的方式来加载配置文件，当变更了ConfigMap里相应key对应的内容并重载后，容器内的配置文件内容并不会更新([issue-50345](https://github.com/kubernetes/kubernetes/issues/50345))
    * 用Path的方式加载整个目录，配置路径的内容会更新
    * 用subPath的方式，重启pod后，配置才会更新

> 参考链接：
> 
> * [kubernetes configmap](https://k8smeetup.github.io/docs/tasks/configure-pod-container/configmap)
