#### <font color="blue">字符编码问题

---

了解python字符编码之前，要先了解一个老生常谈的问题，"unicode" 和 "str" 有什么区别

# unicode 和 str

* unicode是通用的字符编码，它被不同的编码方式(如utf-8, gbk...)编码后，变成由不同byte组成的str
    
    > Unicode 提供了所有我们需要的字符的空间，但是计算机的传输只能通过bytes 。我们需要一种用 bytes 来表示 Unicode 的方法这样才可以存储和传播他们，这个过程就是encoding

* 在python中，unicode通过encode转换成str，str通过decode转换成unicode

    ```javascript
    >>> a = "测试"
    >>> type(a), a
    (<type 'str'>, '\xe6\xb5\x8b\xe8\xaf\x95') # a是utf-8编码的str
    >>> b = a.decode("utf-8")
    >>> type(b), b
    (<type 'unicode'>, u'\u6d4b\u8bd5') # b是a用utf-8解码后的unicode
    >>> c = b.encode("gbk")
    >>> type(c), c
    (<type 'str'>, '\xb2\xe2\xca\xd4') # c是b用gbk编码后的str，可以看到，编码后的c和a已经不同了，虽然它在gbk终端下显示出来的仍然是中文"测试"
    ```

* python2对unicode和str会做一些隐式操作，允许二者混用

    * 当你进行unicode 和 str 拼接的时候，python会对str做decode操作，隐式转换成unicode进行拼接

        ```javascript
        >>> a = "test"
        >>> b = u"test"
        >>> type(a), type(b)
        (<type 'str'>, <type 'unicode'>)
        >>> type(a + b)
        <type 'unicode'> # 拼接后的结果为unicode，因为python帮你完成了b(str)到b(unicode)的转换
        ```

    * python默认用ascii编码来对str做decode，这种转换，在字符串是全英文时没有任何问题；但是当字符串存在中文时，一旦编码不符，这种隐式转换就会报错

        ```javascript
        >>> a = "测试"
        >>> b = u"测试"
        >>> type(a), type(b)
        (<type 'str'>, <type 'unicode'>)
        >>> c = a + b
        Traceback (most recent call last):
          File "<stdin>", line 1, in <module>
        UnicodeDecodeError: 'ascii' codec can't decode byte 0xe6 in position 0: ordinal not in range(128)
        # 这里的报错原因是："测试"是utf-8终端编码输入的str，在用ascii编码方式做decode时，会出现解码错误
        ```

    * 理论上，str是编码后的字符串，只允许做解码(decode)；unicode是解码后的字符串，只允许做编码(encode)。但是实际上，python的隐式操作使得二者可以任意编解码
        
        ```javascript
        >>> a = "test"
        >>> type(a)
        <type 'str'>
        >>> a.encode("utf-8") # python底层处理为a.decode("ascii").encode("utf-8")
        'test'
        >>> a.decode("utf-8")
        u'test'
        >>> b = u"test"
        >>> type(b)
        <type 'unicode'>
        >>> b.encode("utf-8")
        'test'
        >>> b.decode("utf-8") # python底层处理为a.encode("ascii").decode("utf-8")
        u'test'

        同样，当字符串中存在中文时，这种通过ascii编码方式做的隐式转换，在编码不符时就会报错

        >>> a = "测试"
        >>> type(a)
        <type 'str'>
        >>> a.encode("utf-8")
        Traceback (most recent call last):
          File "<stdin>", line 1, in <module>
        UnicodeDecodeError: 'ascii' codec can't decode byte 0xe6 in position 0: ordinal not in range(128)
        ```

* python2这种隐式转换的存在，看起来是让程序员在写程序的时候不用考虑unicode和str的类型，但实际上国内的python开发人员应该都深受其害，只要一些接口的返回里出现中文，这些隐式转换就很可能带来程序错误
* 最安全的做法是，在程序处理返回时，对字符串采用统一的编码；不同编码的str按照各自编码decode成unicode后，再采用统一的编码方式encode成str来进行返回

    ```javascript
    >>> a = u"测试".encode("utf-8")
    >>> b = u"测试".encode("gbk")
    >>> c = (a.decode("utf-8") + b.decode("gbk")).encode("utf-8")
    >>> print c
    测试测试
    ```

> 参考链接
> 
> [python unicode 之痛](https://pycoders-weekly-chinese.readthedocs.io/en/latest/issue5/unipain.html)

# 坑爹的json.dumps()

