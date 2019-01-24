#### <font color="blue">Go的defer处理

---

```javascript
package main

import "fmt"

func deferFunc() (b int) {
	b = 1
	a := true
	defer func() {
		b = 2
	}()

	return
}

func main() {
	fmt.Println(deferFunc())
    // 这里打印出来的是1，而不是2
    // https://stackoverflow.com/questions/37248898/how-does-defer-and-named-return-value-work-in-golang
}
```

# TODO: go的defer底层机制
