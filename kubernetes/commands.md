#### <font color="blue">部分指令参考</font>

---

# Kubernetes

* 干掉一直停留在Terminating状态的pod

	```js
	kubectl delete pod $pod_id --grace-period=0 --force
	```

# Docker

* 干掉一直停留在Exited状态的container

	```js
	docker rm $(docker ps -f status=exited -q)
	```