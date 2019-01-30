#### <font color="blue">Go的slice</font>

---

go的slice可以理解为一种动态可变长的数组，初始化时可以指定长度len和容量cap；可以通过`append()`方法在slice末尾追加元素。

# 一个append的栗子

```javascript
package main

import "fmt"

func main() {
	s0 := []int{1, 2, 3, 4}
	fmt.Printf("s0: %v, len(s): %d, cap(s): %d\n\n", s0, len(s0), cap(s0))
	// s0: [1 2 3 4], len(s): 4, cap(s): 4
	// 初始化一个slice s0，len = cap = 4(不指定cap的情况下，默认cap = len)

	s1 := s0[:2]
	fmt.Printf("s1: %v, len(s1): %d, cap(s1): %d\n\n", s1, len(s1), cap(s1))
	// s1: [1 2], len(s1): 2, cap(s1): 4
	// 取s0的前个元素构成s1，len = 2, cap = 4

	s2 := append(s1, 5, 6, 7)
	fmt.Printf("s2: %v, len(s2): %d, cap(s2): %d\n", s2, len(s2), cap(s2))
	fmt.Printf("s0: %v, len(s0): %d, cap(s0): %d\n\n", s0, len(s0), cap(s0))
	// s2: [1 2 5 6 7], len(s2): 5, cap(s2): 8
	// append 5, 6, 7到s1，此时空间不足，按照两倍cap动态扩容，分配一块新的内存空间给s2
	// s0: [1 2 3 4], len(s0): 4, cap(s0): 4
	// s0不变

	s3 := append(s1, 8, 9)
	fmt.Printf("s3: %v, len(s3): %d, cap(s3): %d\n", s3, len(s3), cap(s3))
	fmt.Printf("s0: %v, len(s0): %d, cap(s0): %d\n\n", s0, len(s0), cap(s0))
	// s3: [1 2 8 9], len(s3): 4, cap(s3): 4
	// append 8, 9到s1，空间足够，无须扩容
	// s0: [1 2 8 9], len(s0): 4, cap(s0): 4
	// s0的后两个元素被append的8, 9取代
}
```

通过以上栗子可以看出：

1. go的slice只有在空间不足时，才会进行动态扩容，分配新的内存地址。所以在日常开发的时候，要尽量避免以下操作：
	
	```javascript
	func A(i []int){
		...
		b := append(i, ...)
		...
	}
		
	func main(){
		...
		a := []int{...}
		A(a[:2])
		...
	}
	```
		
	要防止slice b的操作影响到slice a，可以使用`copy()`方法
		
	```javascript
	func A(i []int){
		...
		b := append(i, ...)
		...
	}
		
	func main(){
		...
		a := []int{...}
		i := make([]int, 2)
		copy(i, a[:2])
		A(i)
		...
	}
	```
		
2. go的slice执行的动态扩容是一个内存拷贝的操作，分配一块新的2倍cap的空间给slice。因此在平时开发的时候，应该尽可能地分配确定的len和cap给slice，防止频繁append进行内存拷贝带来的性能损耗。

	比如以下这段代码
	
	```javascript
	func main() {
		a := make([]int, 0)
		for i := 0; i <= 10; i++ {
			a = append(a, i)
		}
	
		fmt.Println(a)
	}
	```
	
	可以改写成下面这样，使用确定的len
	
	```javascript
	func main() {
		a := make([]int, 10)
		for i := 0; i < 10; i++ {
			a[i] = i
		}
	
		fmt.Println(a)
	}
	```
	
	即便在不确定len的情况下，也应该尽量预留一个相对充足的cap，来减少2倍cap扩容的次数

	```javascript
	func main() {
		a := make([]int, 0, 10)
		for i := 0; i < 10; i++ {
			a = append(a, i)
		}
	
		fmt.Println(a)
	}
	```
	
# 默认按地址传递

* 通过1.1中的栗子

	```javascript
	func A(i []int){
		...
		b := append(i, ...) // 操作b的时候也会影响到a
		...
	}
		
	func main(){
		...
		a := []int{...}
		A(a[:2])
		...
	}
	```

	就可以知道，go中slice传参默认是按址传递的，因此在function内对传入的slice进行写操作的时候要注意：这种操作是会影响到function调用方的原slice的。**go的map也是默认按址传递**
