#### <font color="blue">Go调试工具delve</font>

---

开发程序过程中调试代码是开发者经常要做的一件事情，当然Go语言可以通过Println之类的打印数据来调试，但是每次都需要重新编译，这是一件相当麻烦的事情。庆幸的是golang内置支持gdb来进行调试，但是对于golang这种多用于并发编程的语言，gdb调试对于goroutine协程来说并不是特别友好。因此，我们需要一个更加适合golang的调试器。这里介绍一个github上star数超高，简单易用的golang调试器 —— delve。

# 安装

1. 按照[github官网](https://github.com/go-delve/delve)上的教程进行安装即可，首先检查`xcode-select`是否安装

	```js
	$ xcode-select -v
	```

2. 通过`go get`安装（鉴于各人代理加速的情况，可能会很慢，请耐心等待）

	```js
	$ go get -u github.com/go-delve/delve/cmd/dlv
	```

# TODO
