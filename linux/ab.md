#### <font color="blue">ab压测工具</font>

---

ab压测出现"Failed Requests"的情况：

```js
Failed requests:        101
(Connect: 0, Receive: 0, Length: 101, Exceptions: 0)
```

* Connect: 连接失败
* Receive: 没有收到返回
* Length: 返回长度和之前不一致
* Exceptions: 未预期错误
