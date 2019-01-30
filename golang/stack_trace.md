#### <font color="blue">Go的调试信息</font>

---

当golang程序出现panic的时候会输出一段堆栈调试信息，开发人员可以通过这些调试信息快速地定位问题。

# 举个栗子

我们通过下面这段程序，直接让程序panic

```javascript
package main

func main() {
	slice := make([]string, 2, 4)
	Example(slice, "hello", 10)
}

func Example(slice []string, str string, i int) {
	panic("stack trace")
}
```

运行后输出的调试信息如下

```javascript
panic: stack trace

goroutine 1 [running]:
main.Example(0xc42003ff30, 0x2, 0x4, 0x106b75a, 0x5, 0xa)
	/Users/maniafish/Myworkspace/go_project/src/test/test_panic.go:9 +0x39
main.main()
	/Users/maniafish/Myworkspace/go_project/src/test/test_panic.go:5 +0x76
exit status 2
```

* 第一行是panic信息: stack trace
* 第二行是发生panic的goroutine及其运行状态(running)
* 接下来就是发生panic的function调用情况了。我们通常会关注显示的文件和行号，可以快速定位到是哪一行代码抛出的异常
* 除此之外我们还可以从中看到发生panic的function的输入参数，如`main.Example(0xc42003ff30, 0x2, 0x4, 0x106b75a, 0x5, 0xa)`对应`func Example(slice []string, str string, i int)`的三个输入参数：

	* slice: 0xc42003ff30(slice指针地址), 0x2(slice的长度), 0x4(slice的容量)
	* str: 0x106b75a(str字符串头指针地址), 0x5(str字符串长度)
	* i: 0xa(i = 10)

# 空指针错误

```javascript
package main

import "fmt"

type S struct {
	Msg string
}

func (s *S) f(a int) {
	fmt.Printf("%v: %d\n", s.Msg, a)
}

func main() {
	Example(nil)
}

func Example(s *S) {
	s.f(1)
}
```

以上这段程序运行结果如下：

```javascript
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x1095257]

goroutine 1 [running]:
main.(*S).f(0x0, 0x1)
	/Users/maniafish/Myworkspace/go_project/src/test/test_panic.go:10 +0x57
main.Example(0x0)
	/Users/maniafish/Myworkspace/go_project/src/test/test_panic.go:18 +0x34
main.main()
	/Users/maniafish/Myworkspace/go_project/src/test/test_panic.go:14 +0x2a
exit status 2
```

1. panic信息(invalid memory address or nil pointer dereference)告诉我们是无效的地址调用
2. 我们通过`main.(*S).f(0x0, 0x1)`的第一个参数，可以知道这个指针`*S`的方法`f()`调用时使用的是空指针
3. 然后通过`main.Example(0x0)`，知道这个空指针是通过`Example()`方法传进来的，定位到了问题所在。

> 参考链接：
> 
> * [Go stack trace](http://colobu.com/2016/04/19/Stack-Traces-In-Go/)
