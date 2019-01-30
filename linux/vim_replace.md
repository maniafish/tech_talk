#### <font color="blue">vim替换特殊符号

---

# 替换特殊字符为实际控制符

* 替换换行符 `:%s/\\r\\n/\r/g`
* 替换tab `:%s/\\t/\t/g`

    > ps: 设置tab为四个空格的方法
    > ```javascript
    :set tabstop=4
    :set expandtab
    ```

# 替换跨平台的控制符

* 替换`^M`换行符 `:%s/[Ctrl-v][Ctrl-M]/\r/g`
* 替换`^I`制表符 `:%s/[Ctrl-v][Ctrl-I]/\t/g`

# 替换首尾字符

* 第7-15行开头插入`* ` `:7,15s/^/* /g`
* 第7-15行末尾插入` *` `:7,15s/$/ */g`
