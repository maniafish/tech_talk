#### <font color="blue">Go实现队列、堆、栈</font>

用golang标准库的container包，可以轻松地实现队列、堆、栈的数据结构

# container/list

## list添加元素

1. `func (l *List) PushFront(v interface{}) *Element`: 添加 v 至开头
2. `func (l *List) PushBack(v interface{}) *Element`: 添加 v 至末尾
3. `func (l *List) InsertBefore(v interface{}, mark *Element) *Element`: 在 mark 元素前添加 v
4. `func (l *List) InsertAfter(v interface{}, mark *Element) *Element`: 在 mark 元素后添加 v

> 以上方法返回的均为被添加的元素 v

## list删除元素

1. `func (l *List) remove(e *Element) *Element`: 移出 e，并返回 e
2. `func (l *List) Init() *List`: 清空 l，并返回 l

## list移动元素

1. `func (l *List) MoveToFront(e *Element)`: 将 e 移动到开头
2. `func (l *List) MoveToBack(e *Element)`: 将 e 移动到末尾
3. `func (l *List) MoveBefore(e, mark *Element)`: 将 e 移动到 mark 前
4. `func (l *List) MoveAfter(e, mark *Element)`: 将 e 移动到 mark 后

> 以上方法中的 e 和 mark 需要在 l 内，且不为nil

## list实现队列和栈

```js
package main

import (
	"container/list"
	"fmt"
)

func main() {
	q := list.New()
	// 作为栈使用
	// 入栈
	q.PushBack(1)
	q.PushBack(2)
	q.PushBack(3)
	q.PushBack(4)
	// 此时栈元素为1,2,3,4; 栈顶元素为4
	// 遍历并弹出栈元素，先入后出，出栈顺序：4, 3, 2, 1
	for q.Len() > 0 {
		fmt.Println(q.Remove(q.Back()))
	}

	// 作为队列使用
	// 入队
	q.PushBack(1)
	q.PushBack(2)
	q.PushBack(3)
	q.PushBack(4)
	// 此时队列元素为1,2,3,4; 队头元素为1
	// 遍历并弹出队列元素，先入先出，出队顺序：1, 2, 3, 4
	for q.Len() > 0 {
		fmt.Println(q.Remove(q.Front()))
	}
}
```

# container/heap

heap包提供了以下方法进行堆操作：

1. `func Init(h Interface)`: 初始化一个堆
2. `func Pop(h Interface) interface{}`: 弹出堆顶元素(交换堆顶和末尾元素，调整堆并弹出末尾元素)
3. `func Push(h Interface, x interface{})`: 将 x 加入 h 末尾，并调整堆
4. `func Remove(h Interface, i int) interface{}`: 删除 h 第 i 个位置的元素(交换第 i 个位置的元素和末尾元素，调整堆并弹出末尾元素)
5. `func Fix(h Interface, i int)`: 当 h 中第 i 个位置的元素变化时，进行堆调整

## heap实现最小堆

heap包构建堆的前提是输入一个实现了以下方法的接口:

```js
type Interface interface {
    // Len is the number of elements in the collection.
    Len() int
    // Less reports whether the element with
    // index i should sort before the element with index j.
    Less(i, j int) bool
    // Swap swaps the elements with indexes i and j.
    Swap(i, j int)
    // add x as element Len()
    Push(x interface{})
    // remove and return element Len() - 1.
    Pop() interface{}
}
```

其实前三个方法就是go实现排序所需的Interface接口方法，详见：[Go标准库sort](https://golang.org/pkg/sort/#Interface)；后两个方法的Push用于将元素添加到末尾，Pop用于将末尾的元素弹出。以下是最小堆实现：

```js
package main

import (
	"container/heap"
	"fmt"
)

type IntHeap []int

func (h IntHeap) Len() int            { return len(h) }
func (h IntHeap) Less(a, b int) bool  { return h[a] < h[b] }
func (h IntHeap) Swap(a, b int)       { h[a], h[b] = h[b], h[a] }
func (h *IntHeap) Push(x interface{}) { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() interface{} {
	n := h.Len()
	x := (*h)[n-1]
	*h = (*h)[0 : n-1]
	return x
}

func main() {
	h := IntHeap([]int{1, 2, 5})
	heap.Init(&h)
	heap.Push(&h, 3)
	// 遍历弹出堆顶(h[0])元素，弹出顺序为1, 2, 3, 5
	for h.Len() > 0 {
		fmt.Println(heap.Pop(&h))
	}
}
```

若要实现最大堆，只需要修改Less()方法即可：

```js
func (h IntHeap) Less(a, b int) bool { return h[a] > h[b] }
```

## heap实现优先级队列

基于heap的特性，我们可以实现更加复杂的数据结构：以priority最大值优先的优先级队列

```js
package main

import (
	"container/heap"
	"fmt"
)

type Item struct {
	Priority int    // 优先级
	Value    string // 数据
}

type PriorityQueue []*Item

func (q PriorityQueue) Len() int { return len(q) }

// Less 把优先级高的元素往前排
func (q PriorityQueue) Less(a, b int) bool  { return q[a].Priority > q[b].Priority }
func (q PriorityQueue) Swap(a, b int)       { q[a], q[b] = q[b], q[a] }
func (q *PriorityQueue) Push(x interface{}) { *q = append(*q, x.(*Item)) }
func (q *PriorityQueue) Pop() interface{} {
	n := q.Len()
	x := (*q)[n-1]
	*q = (*q)[0 : n-1]
	return x
}

func main() {
	h := PriorityQueue([]*Item{
		&Item{1, "d1"},
		&Item{2, "d2"},
		&Item{5, "d5"},
	})

	heap.Init(&h)
	heap.Push(&h, &Item{3, "d3"})
	// 遍历弹出堆顶元素，依次为d5, d3, d2, d1
	for h.Len() > 0 {
		fmt.Println(heap.Pop(&h))
	}
}
```

---

> 参考链接：
> 
> * [golang package list](https://golang.org/pkg/container/list/)
> * [golang package heap](https://golang.org/pkg/container/heap/)
