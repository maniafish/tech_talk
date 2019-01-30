#### <font color="blue">Go的变量作用域</font>

---

# 变量作用域

## 全局变量

```javascript
package a

var g int // 本包内可见
var G int // 外部import a后可见
```

## 局部变量

```javascript
func Test() {
	var a int // a在Test()内可见
	...
	for i := 1; i < a; i++ { // i在for循环内部可见
		...
	}
	...
	if true {
		var b int // b在if内部可见
	}
}
```

## 参数变量

```javascript
func Test(a int) { // a在Test()方法内可见，在Test()外赋值。
	...
}
```

局部变量声明后未使用会编译失败；参数变量在function内可以不使用，比如以下情况也是可以编译通过的。

```javascript
func main() {
	a := 1
	Test(a) // a作为参数调用
}

func Test(a) { // a在Test()内部没有使用
	fmt.Println("test")
}
```

* 对按值传参的情况，方法内对参数a的修改不影响传入前的原参数a
* 对按址传参的情况，方法内对参数a的修改也会影响到传入前的原参数a

# 循环并发中的变量传参问题

理解了go中的变量作用域后，我们来看看下面这段代码

```javascript
package main

import (
	"fmt"
	"sync"
)

var wg sync.WaitGroup

func main() {
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Println(i)
		}()
	}

	wg.Wait()
}
```

输出结果如下

```javascript
10
10
10
10
10
10
10
10
10
10
```

* 这是因为变量i作为局部变量，同时在for循环和go协程中被引用，循环递增和打印的是同一个地址的数据
* 实际上这个输出是无法预期的，这里都输出10是因为后台协程完成创建时，for循环已经完成了对i的递增操作
* 如果要想让循环中的go协程如我们预期的一样输出1~10的值，要采取以下写法，使用参数变量

```javascript
package main

import (
	"fmt"
	"sync"
)

var wg sync.WaitGroup

func main() {
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			fmt.Println(i)
		}(i)
	}

	wg.Wait()
}
```

# Go的`:=`操作符

Go的`:=`操作符用于声明变量的同时给变量赋值，它也会定义新变量的作用域。以下面这段代码为例

```javascript
package main

import (
	"fmt"
	"sync"
)

var wg sync.WaitGroup

func main() {
	a := 1
	fmt.Printf("a in main: %p, %d\n", &a, a)
	// a in main: 0xc420016090, 1 
	// 在main中声明了变量a，地址为0xc420016090，并给a赋值为1
	
	for a := 2; a < 10; a++ {
		fmt.Printf("a in for: %p, %d\n", &a, a)
		// a in for: 0xc420016098, 2
		// 在for循环中通过 := 声明了一个该循环内可见的局部变量a，地址为0xc420016098，并给a赋值为2
		/*	 
			a in for: 0xc420016098, 3
			a in for: 0xc420016098, 4
			a in for: 0xc420016098, 5
			a in for: 0xc420016098, 6
			a in for: 0xc420016098, 7
			a in for: 0xc420016098, 8
			a in for: 0xc420016098, 9 
		*/
		// 在for循环过程中始终是对这个局部变量a(0xc420016098)的地址做操作，对main中之前声明的a没有影响
	}

	if a == 1 {
		a := 2
		fmt.Printf("a in if: %p, %d\n", &a, a)
		// a in if: 0xc4200160f8, 2
		// 在if中通过 := 声明了一个该条件内可见的局部变量a，地址为0xc4200160f8，并给a赋值为2；对main中的a没有影响
	}

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Printf("a in go before define: %p, %d\n", &a, a)
		// a in go before define: 0xc420016090, 1
		// main中声明的局部变量a，在go协程中同样可见
		
		a := 3
		fmt.Printf("a in go after define: %p, %d\n", &a, a)
		// a in go after define: 0xc420016110, 3
		// 在go协程中通过 := 声明了一个该协程内可见的局部变量a，地址为00xc42001611，并给a赋值为3，对main中的a没有影响
	}()
	wg.Wait()

	// a := 4 这种操作是不被允许的(no new variables on left side of :=)
	b, a := -3, 4
	fmt.Printf("a in main after define b %d: %p, %d\n", b, &a, a)
	// a in main after define b -3: 0xc420016090, 4
	// 在main中重新通过 := 来同时声明a, b；b被声明为一个新的变量并赋值，a仍然是原来main中的变量a(0xc420016090)，不会被重新声明，只会被赋值
}
```
