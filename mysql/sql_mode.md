#### <font color="blue">浅谈sql_mode对数据库的影响</font>

---

# 什么是sql_mode

mysql的sql_mode用于设定数据库进行数据校验和sql语法校验的严格程度，某些情况下会影响数据操作的准确性，忽略它的话有时候会踩坑。

# 操作sql_mode

* 查看全局sql_mode: `SELECT @@GLOBAL.sql_mode;`
* 查看当前会话的sql_mode: `SELECT @@SESSION.sql_mode;`
* 修改全局sql_mode: `SET GLOBAL sql_mode = '<需要设置的sql_mode, 不同mode间用逗号分隔>'`
* 修改全局sql_mode: `SET SESSION sql_mode = '<需要设置的sql_mode, 不同mode间用逗号分隔>'`

接下来我们依次介绍一下mysql都有哪些sql_mode，以及它们各自的作用是什么。

# sql_mode的类型

> 以下示例使用的TEST表结构为:
> 
> ```js
> Create Table | CREATE TABLE `TEST` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `d` date DEFAULT NULL,
  `dt` datetime DEFAULT CURRENT_TIMESTAMP,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `value` varchar(255) NOT NULL DEFAULT '',
  `num` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
> ```
> 
> mysql版本为5.7.28

## `ALLOW_INVALID_DATES`

一般情况下，月份范围是 1 - 12，日范围是 1 - 31。当没有设置该值时，以下操作都是被允许的：

* 示例1

	`INSERT INTO TEST(d, dt) VALUES('2020-13-13', '2020-13-13 55:55:55');`

	插入结果如下(非法插入默认被设置为0000-00-00 00:00:00)：

	```js
	d     | 0000-00-00
	dt    | 0000-00-00 00:00:00
	```
	
* 示例2

	`INSERT INTO TEST(d, dt) VALUES('2020-11-31', '2020-11-31 12:12:12');`

	插入结果如下(即便时间有效，只要日期无效，同样会被设置为0000-00-00 00:00:00)：
	
	```js
	d     | 0000-00-00
	dt    | 0000-00-00 00:00:00
	```

当设置了该值，即`SET SESSION sql_mode = 'ALLOW_INVALID_DATES';`时：

* 示例1

	`INSERT INTO TEST(d, dt) VALUES('2020-13-13', '2020-13-13 55:55:55')`
	
	插入结果如下(和没设置`ALLOW_INVALID_DATES`时一样)：
	
	```js
	id    | 1
	d     | 0000-00-00
	dt    | 0000-00-00 00:00:00
	```

* 示例2

	`INSERT INTO TEST(d, dt) VALUES('2020-11-31', '2020-11-31 12:12:12');`
	
	 插入结果如下(可以看到，只要插入的日期和时间的数值在限定范围内：1~12月、1~31日、0~23时、0~59分、0~59秒，就允许插入；即便当前日期11-31是不存在的)：
	 
	 ```js
	 d     | 2020-11-31
	 dt    | 2020-11-31 12:12:12
	 ```
	 
<font color="red"><b>配置建议：不要设置该值，以免程序读取数据库时读出无效的日期</b></font>

## `ANSI_QUOTES`

该值用于设定是否将双引号`"`作为引用标识符 ` 使用。当没有设置该值时，双引号表示正常的字符串引用：

* 示例1

	```js
	> INSERT INTO TEST(value) VALUES("data");
	> SELECT `value` FROM TEST;
	+-------+
	| value |
	+-------+
	| data  |
	+-------+
	> SELECT "value" FROM TEST;
	+-------+
	| value |
	+-------+
	| value |
	+-------+
	```
	
当设置了该值，即`SET SESSION sql_mode = 'ANSI_QUOTES';`，双引号和 ` 等价：

* 示例1(由于data字段不存在，因此返回错误)

	```js
	> INSERT INTO TEST(value) VALUES("data");
	(1054, "Unknown column 'data' in 'field list'")
	```
	
* 示例2(选择字符串变成了选择value字段值)

	```js
	> SELECT "value" FROM TEST;
	+-------+
	| value |
	+-------+
	| data  |
	+-------+
	```

<font color="red"><b>配置建议：不要设置该值，插入时可能引发错误，查询时容易引起歧义。</b></font>

## `ERROR_FOR_DIVISION_BY_ZERO`

---

> 参考链接：
> 
> * [mysql out-of-range-and-overflow](https://dev.mysql.com/doc/refman/8.0/en/out-of-range-and-overflow.html)
> * [mysql sql_mode](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html)
