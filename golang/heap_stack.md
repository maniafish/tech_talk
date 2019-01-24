#### <font color="blue">Go的堆栈分配

---

# Golang的程序栈

* 每个goroutine维护着一个栈空间，默认最大为4KB
* 当goroutine的栈空间不足时，golang会调用`runtime.morestack`(汇编实现：asm_xxx.s)来进行动态扩容
* 连续栈：当栈空间不足的时候申请一个2倍于当前大小的新栈，并把所有数据拷贝到新栈， 接下来的所有调用执行都发生在新栈上。
* 每个function维护着各自的栈帧(stack frame)，当function退出时会释放栈帧

> 参考链接：
>   
> * [go语言连续栈](https://tiancaiamao.gitbooks.io/go-internals/content/zh/03.5.html)
> * [为何说Goroutine的栈空间可以无限大](http://blog.xiayf.cn/2014/01/17/goroutine-stack-infinite/)
> * [Goroutine stack](https://studygolang.com/articles/10597)

## function内部的栈操作

用一段简单的代码来说明Go函数调用及传参时的栈操作：

``` javascript
package main

func g(p int) int {
     return p+1;
}

func main() {
     c := g(4) + 1
     _ = c
}
```
	
执行`go tool compile -S main.go`生成汇编，并截取其中的一部分来说明一下程序调用时的栈操作

``` javascript
"".g t=1 size=17 args=0x10 locals=0x0
    // 初始化函数的栈地址
    // 0-16表示函数初始地址为0，数据大小为16字节(input: 8字节，output: 8字节)
    // SB是函数寄存器
    0x0000 00000 (test_stack.go:3)  TEXT    "".g(SB), $0-16
    // 函数的gc收集提示。提示0和1是用于局部函数调用参数，需要进行回收
    0x0000 00000 (test_stack.go:3)  FUNCDATA    $0, gclocals·aef1f7ba6e2630c93a51843d99f5a28a(SB)
    0x0000 00000 (test_stack.go:3)  FUNCDATA    $1, gclocals·33cdeccccebe80329f1fdbee7f5874cb(SB)
    // FP(frame point)指向栈底
    // 将FP+8位置的数据(参数p)放入寄存器AX
    0x0000 00000 (test_stack.go:4)  MOVQ    "".p+8(FP), AX
    0x0005 00005 (test_stack.go:4)  MOVQ    (AX), AX
    // 寄存器值自增
    0x0008 00008 (test_stack.go:4)  INCQ    AX
    // 从寄存器中取出值，放入FP+16位置(返回值)
    0x000b 00011 (test_stack.go:4)  MOVQ    AX, "".~r1+16(FP)
    // 返回，返回后程序栈的空间会被回收
    0x0010 00016 (test_stack.go:4)  RET
    0x0000 48 8b 44 24 08 48 8b 00 48 ff c0 48 89 44 24 10  H.D$.H..H..H.D$.
    0x0010 c3                                               .
"".main t=1 size=32 args=0x0 locals=0x10
    0x0000 00000 (test_stack.go:7)  TEXT    "".main(SB), $16-0
    0x0000 00000 (test_stack.go:7)  SUBQ    $16, SP
    0x0004 00004 (test_stack.go:7)  MOVQ    BP, 8(SP)
    0x0009 00009 (test_stack.go:7)  LEAQ    8(SP), BP
    0x000e 00014 (test_stack.go:7)  FUNCDATA    $0, gclocals·33cdeccccebe80329f1fdbee7f5874cb(SB)
    0x000e 00014 (test_stack.go:7)  FUNCDATA    $1, gclocals·33cdeccccebe80329f1fdbee7f5874cb(SB)
    // SP(stack point)指向栈顶
    // 把4存入SP的位置
    0x000e 00014 (test_stack.go:8)  MOVQ    $4, "".c(SP)
    // 这里会看到没有第9行`call g()`的调用出现，这是因为go汇编编译器会把一些短函数变成内嵌函数，减少函数调用
    0x0016 00022 (test_stack.go:10) MOVQ    8(SP), BP
    0x001b 00027 (test_stack.go:10) ADDQ    $16, SP
    0x001f 00031 (test_stack.go:10) RET
```
事实上，即便我定义了指针调用，以上的数据也都是在栈上拷贝的；那么Golang中的数据什么时候会被分配到堆上呢？

> 参考链接：
> 
> * [Golang汇编快速指南](http://blog.rootk.com/post/golang-asm.html)
> * [Golang汇编](https://lrita.github.io/2017/12/12/golang-asm/#how)
> * [Golang汇编命令解读](http://www.cnblogs.com/yjf512/p/6132868.html)

# Golang逃逸分析

* 在编译程序优化理论中，逃逸分析是一种确定指针动态范围的方法，用于分析在程序的哪些地方可以访问到指针。
* Golang在编译时的逃逸分析可以减少gc的压力，不逃逸的对象分配在栈上，当函数返回时就回收了资源，不需要gc标记清除。
* 如果你定义的对象的方法上有同步锁，但在运行时，却只有一个线程在访问，此时逃逸分析后的机器码，会去掉同步锁运行，提高效率。

## 举个栗子

还是`1.1`里的那段程序代码，我们可以执行`go build -gcflags '-m -l' test_stack.go`来进行逃逸分析，输出结果如下

```javascript
# command-line-arguments
./test_stack.go:3: g p does not escape
./test_stack.go:9: main &c does not escape
```
可以看到，对象c是没有逃逸的，还是分配在栈上。

即便在一开始定义的时候直接把c定义为指针：

```javascript
package main

func g(p *int) int {
	return *p + 1
}

func main() {
	c := new(int)
	(*c) = 4
	_ = g(c)
}
```
逃逸分析的结果仍然不会改变

```javascript
# command-line-arguments
./test_stack.go:3: g p does not escape
./test_stack.go:8: main new(int) does not escape
```

那么，什么时候指针对象才会逃逸呢？

## 按值传递和按址传递

* 按值传递

```javascript
package main

func g(p int) int {
	ret := p + 1
	return ret
}

func main() {
	c := 4
	_ = g(c)
}
```

返回值ret是按值传递的，执行的是栈拷贝，不存在逃逸

* 按址传递

```javascript
package main

func g(p *int) *int {
	ret := *p + 1
	return &ret
}

func main() {
	c := new(int)
	*c = 4
	_ = g(c)
}
```

返回值&ret是按址传递，传递的是指针对象，发生了逃逸，将对象存放在堆上以便外部调用

```javascript
# command-line-arguments
./test_stack.go:5:9: &ret escapes to heap
./test_stack.go:4:14: moved to heap: ret
./test_stack.go:3:17: g p does not escape
./test_stack.go:9:10: main new(int) does not escape
```

golang只有在function内的对象可能被外部访问时，才会把该对象分配在堆上

* 在g()方法中，ret对象的引用被返回到了方法外，因此会发生逃逸；而p对象只在g()内被引用，不会发生逃逸
* 在main()方法中，c对象虽然被g()方法引用了，但是由于引用的对象c没有在g()方法中发生逃逸，因此对象c的生命周期还是在main()中的，不会发生逃逸

## 再看一个栗子

```javascript
package main

type Ret struct {
	Data *int
}

func g(p *int) *Ret {
	var ret Ret
	ret.Data = p
	return &ret
}

func main() {
	c := new(int)
	*c = 4
	_ = g(c)
}
```

 逃逸分析结果

```javascript
# command-line-arguments
./test_stack.go:10:9: &ret escapes to heap
./test_stack.go:8:6: moved to heap: ret
./test_stack.go:7:17: leaking param: p to result ~r1 level=-1
./test_stack.go:14:10: new(int) escapes to heap
```

* 可以看到，ret和2.2中一样，存在外部引用，发生了逃逸
* 由于ret.Data是一个指针对象，p赋值给ret.Data后，也伴随p发生了逃逸
* main()中的对象c，由于作为参数p传入g()后发生了逃逸，因此c也发生了逃逸
* 当然，如果定义ret.Data为int(instead of *int)的话，对象p也是不会逃逸的(执行了拷贝)

> 参考链接：
> 
> * [Go语言逃逸分析](https://gocn.io/article/355)

# 对开发者的一些建议

## 大对象按址传递，小对象按值传递

* 按址传递更高效，按值传递更安全(from William Kennedy)
* 90%的bug都来自于指针调用

## 初始化一个结构体，使用引用的方式来传递指针

```javascript
func r() *Ret{
	var ret Ret
	ret.Data = ...
	...
	return &ret
}
```

只有返回ret对象的引用时才会把对象分配在堆上，我们不必要在一开始的时候就显式地把ret定义为指针

```javascript
ret = &Ret{}
...
return ret
```
对阅读代码也容易产生误导
