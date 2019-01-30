#### <font color="blue">Go的interface</font>

---

* go的interface类型定义了一组方法，如果某个对象实现了某个interface的所有方法，此对象就实现了此interface。 
* interface focus on what the data does, instead of what the data is(From William Kennedy)
* interface能够帮助我们更好地做泛型编程，实现代码逻辑的抽象和灵活组合，更方便地进行面向对象的编程。  

下面通过一个例子来说明一下go中基于interface的编程设计思路。

# 场景1

![composition1](./image/composition1.jpg)

## 设计思路

* 定义结构体A，实现方法Store()
* 定义结构体B，实现方法Pull()
* 定义System封装A和B，并通过System向外提供api

## 代码示例

```javascript
// A is a system for data collection
type A struct {
	...
}

// Store function for storing data
func (a *A) Store(data interface{}) {
	...
}

// B is a system for data pulling 
type B struct {
	...
}

// Pull function for pulling data
func (b *B) Pull(data interface{}) {
	...
}

// System wraps A and B together
type System struct {
	A
	B
}

// Api providing api for users
func Api(s *System, data []interface{}) error {
	...
	for _, v := range data {
		s.Store(v)
	}
	...
	dp := ...
	err = s.Pull(dp)
	...
	return
}

func main() {
	a := A {
		...
	}
	
	b := B {
		...
	}
	
	s := System{a, b}
	data := ...
	err := Api(&s, data)
	if err != nil {
		...
	}
	...
}
```

# 场景2

![composition2](./image/composition2.jpg)

## 设计思路

* 系统组件A1\~A3都实现了同样的方法Store()，B1\~B3实现了Pull()，考虑使用interface进行抽象解耦
* system无需关心具体的A和B，只需要做interface的组合即可

## 代码示例

```javascript
// Storer is an interface for data collection
type Storer interface {
	Store(data interface{})
}


// A1 is a system for data collection
type A1 struct {
	...
}

// Store function for storing data
func (a *A1) Store(data interface{}) {
	...
}

// define A2 ~ A3 implementing Storer
...

// Puller is an interface for data pulling 
type Puller interface {
	Pull(data interface{})
}

// B1 is a system for data pulling 
type B1 struct {
	...
}

// Pull function for pulling data
func (b *B1) Pull(data interface{}) {
	...
}

// define B2 ~ B3 implementing Puller
...

// System wraps Storer and Puller together
type System struct {
	Storer
	Puller
}

// Api providing api for users
func Api(s *System, data []interface{}) error {
	...
	for _, v := range data {
		s.Store(v)
	}
	...
	dp := ...
	err = s.Pull(dp)
	...
	return
}

func main() {
	...
	a := A1 {
		...
	}
	
	b := B1 {
		...
	}
	
	// s can be any composition of An and Bn
	s := System{&a, &b}
	data := ...
	err := Api(&s, data)
	if err != nil {
		...
	}
	...
}
```

## 进一步抽象

* 我们希望`Api()`方法变得更加通用，它无需关心System的具体结构，只关心System提供的Pull()和Store()方法
* 因此我们可以定义一个PullStorer来做Puller和Storer的interface组合，这样一来只要是实现了Puller和Storer的结构体，都可以由Api()方法调用来对外提供服务

```javascript
...

// PullStorer is an interface implementing Storer and Puller
type PullStorer interface {
	Storer
	Puller
}

// Api providing api for users
func Api(s PullStorer, data []interface{}) error {
	...
	for _, v := range data {
		s.Store(v)
	}
	...
	dp := ...
	err = s.Pull(dp)
	...
	return
}

func main() {
	...
	// s can be any composition of An and Bn
	s := System{
		...
	}
	
	data := ...
	err := Api(&s, data)
	if err != nil {
		...
	}
	...
}
```

## interface滥用问题

* 我们现在定义了以下interface

```javascript
// Storer is an interface for data collection
type Storer interface {
	Store(data interface{})
}

// Puller is an interface for data pulling 
type Puller interface {
	Pull(data interface{})
}

// PullStorer is an interface implementing Storer and Puller
type PullStorer interface {
	Storer
	Puller
}
```

* 我们的`Api()`里关注的是`Store()`和`Pull()`方法

```javascript
// Api providing api for users
func Api(s PullStorer, data []interface{}) error {
	...
	for _, v := range data {
		s.Store(v)
	}
	...
	dp := ...
	err = s.Pull(dp)
	...
	return
}
```

* 这个传入`Api()`的s，可以是任意实现了Store()方法的An和任意实现了Pull()方法的Bn的组合
* 我们在`Api()`中调用`s.Store()`，实际上调用的是`s.Storer.Store()`；调用`s.Pull()`，实际上调用的是`s.Puller.Pull()`
* 既然我们的`Api()`关注的只是Puller和Storer，那么我们为什么要额外让他们组合成一个PullStorer来传入呢

基于以上设计思路，我们可以去掉System和PullStorer，得到以下简洁且可扩展性强的代码

```javascript
// Storer is an interface for data collection
type Storer interface {
	Store(data interface{})
}

// A1 is a system for data collection
type A1 struct {
	...
}

// Store function for storing data
func (a *A1) Store(data interface{}) {
	...
}

// define A2 ~ A3 implementing Storer
...

// Puller is an interface for data pulling 
type Puller interface {
	Pull(data interface{})
}

// B1 is a system for data pulling 
type B1 struct {
	...
}

// Pull function for pulling data
func (b *B1) Pull(data interface{}) {
	...
}

// define B2 ~ B3 implementing Puller
...

// Api providing api for users
func Api(s Storer, p Puller, data []interface{}) error {
	...
	for _, v := range data {
		s.Store(v)
	}
	...
	dp := ...
	err = p.Pull(dp)
	...
	return
}

func main() {
	...
	a := A1 {
		...
	}
	
	b := B1 {
		...
	}
	
	// a can be any An, b can be any Bn
	data := ...
	err := Api(&a, &b, data)
	if err != nil {
		...
	}
	...
}
```
