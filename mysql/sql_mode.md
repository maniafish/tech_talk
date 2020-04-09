#### <font color="blue">浅谈sql_mode对数据库的影响</font>

---

# 什么是sql_mode

mysql的sql_mode用于设定数据库进行数据和sql语法校验的严格程度，某些情况下会影响数据操作和迁移的结果，忽略它的话很容易踩坑。

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

该值用于允许插入非法的日期。一般情况下，月份范围是 1 - 12，日范围是 1 - 31。当没有设置该值时，非法日期输入会被置为0000-00-00：

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
	d     | 0000-00-00
	dt    | 0000-00-00 00:00:00
	```

* 示例2

	`INSERT INTO TEST(d, dt) VALUES('2020-11-31', '2020-11-31 12:12:12');`
	
	 插入结果如下(可以看到，只要插入的日期在限定范围内：1~12月、1~31日，就允许插入；即便当前日期11-31是不存在的)：
	 
	 ```js
	 d     | 2020-11-31
	 dt    | 2020-11-31 12:12:12
	 ```
	 
<font color="red"><b>配置建议：不要设置该值，以免程序读取数据库时读出无效的日期</b></font>

## `ANSI_QUOTES`

该值用于设定将双引号`"`作为引用标识符 ` 使用。当没有设置该值时，双引号表示正常的字符串引用：

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

该值用于设定除 0 时的合法性校验。当没有设置该值时，默认除以0的操作不报错，结果作为NULL值处理：
	
* 示例1(查询返回的是NULL值）
	
	```js
	> SELECT 1/0;
	+--------+
	| 1/0    |
	+--------+
	| <null> |
	+--------+
	```

* 示例2

	```js
	> INSERT INTO TEST(num) VALUES(1/0);
	(1048, "Column 'num' cannot be null")
	```
	
	这里报错的原因是我们设定的`num bigint(20) NOT NULL DEFAULT '0'`，要求是NOT NULL，而1/0返回的是NULL，所以不允许插入。(ps: 建议建表的时候对数值类型设置为`NOT NULL`，可以避免一些不可预期的空值带来的影响)
	
单独设置该值，即`SET SESSION sql_mode = 'ERROR_FOR_DIVISION_BY_ZERO';`是无效的；需要和严格模式(`Strict SQL Mode`)结合使用才行，如`SET SESSION sql_mode = 'ERROR_FOR_DIVISION_BY_ZERO,STRICT_TRANS_TABLES';`时：

* 示例1

	```js
	> SELECT 1/0;
	+--------+
	| 1/0    |
	+--------+
	| <null> |
	+--------+
	```
	
	虽然查询结果还是NULL，但是有warning报出：
	
	```js
	> SHOW WARNINGS;
	+---------+------+---------------+
	| Level   | Code | Message       |
	+---------+------+---------------+
	| Warning | 1365 | Division by 0 |
	+---------+------+---------------+
	```

* 示例2(插入时由于除 0 ，直接报出了相应的错误)

	```js
	> INSERT INTO TEST(num) VALUES(1/0);
	(1365, 'Division by 0')
	```

mysql官方文档关于该值有这样的说明：

`Because ERROR_FOR_DIVISION_BY_ZERO is deprecated, it will be removed in a future MySQL release as a separate mode name and its effect included in the effects of strict SQL mode.`

由于该值需要和严格模式结合使用，因此官方在之后的版本会将其废弃，直接作为严格模式中的一部分功能来对外提供。

<font color="red"><b>配置建议：没有设置严格模式(`STRICT_ALL_TABLES`或`STRICT_TRANS_TABLES`)的，无需设置该值；设置了严格模式的，该值可配可不配(未来版本也会废弃，相比之下设置好表结构，数值型字段不允许NULL才是一劳永逸的方法)。</b></font>

## `HIGH_NOT_PRECEDENCE`

该值用于提高 not 运算符的优先级。当没有设置该值时，默认 not 运算符的优先级是在最后的：

* 示例1(先做BETWEEN判断再做not取反)

	```js
	> SELECT NOT 1 BETWEEN -5 AND 5;
	+------------------------+
	| NOT 1 BETWEEN -5 AND 5 |
	+------------------------+
	| 0                      |
	+------------------------+
	```
	
当设置了该值，即`SET SESSION sql_mode='HIGH_NOT_PRECEDENCE'`时：

* 示例1(先做NOT取反，再做BETWEEN判断)

	```js
	> SELECT NOT 1 BETWEEN -5 AND 5;
	+------------------------+
	| NOT 1 BETWEEN -5 AND 5 |
	+------------------------+
	| 1                      |
	+------------------------+
	```

<font color="red"><b>配置建议：不要设置该值，以免由于运算符优先级改变导致程序处理结果和预期不符</b></font>

## `IGNORE_SPACE`

该值用于允许函数名和`(`之间有空格；除此之外，设置该值时，会将mysql内建函数名等作为保留字，使用和保留字相同的名字作为库名/表名/列名时，会报错。当没有设置该值时：

* 示例1(用内建函数count同名来建表是被允许的)

	```js
	> CREATE TABLE count (i int(11) NOT NULL DEFAULT '0');
	Query OK, 0 rows affected
	Time: 0.021s
	
	> SHOW CREATE TABLE count;
	+-------+----------------------------------------+
	| Table | Create Table                           |
	+-------+----------------------------------------+
	| count | CREATE TABLE `count` (                 |
	|       |   `i` int(11) NOT NULL DEFAULT '0'     |
	|       | ) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
	+-------+----------------------------------------+
	```
	
* 示例2(调用方法中间不能有空格)

	```js
	> SELECT count(i) FROM count;
	+----------+
	| count(i) |
	+----------+
	| 0        |
	+----------+
	
	> SELECT count (i) FROM count;
	(1630, "FUNCTION mode_test.count does not exist. Check the 'Function Name Parsing and Resolution' section in the Reference Manual")
	```
	
当设置该值，即`SET SESSION sql_mode='IGNORE_SPACE';`时：

* 示例1(用内建函数count同名来建表被禁止，需要加上引用标识符 ` )

	```js
	> CREATE TABLE count (i int(11) NOT NULL DEFAULT '0');
	(1064, "You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'count (i int(11) NOT NULL DEFAULT '0')' at line 1")
	
	> CREATE TABLE `count` (i int(11) NOT NULL DEFAULT '0');
	Query OK, 0 rows affected
	Time: 0.021s
	
	> SHOW CREATE TABLE count;
	+-------+----------------------------------------+
	| Table | Create Table                           |
	+-------+----------------------------------------+
	| count | CREATE TABLE `count` (                 |
	|       |   `i` int(11) NOT NULL DEFAULT '0'     |
	|       | ) ENGINE=InnoDB DEFAULT CHARSET=latin1 |
	+-------+----------------------------------------+
	```
	
* 示例2(调用方法中间允许有空格)

	```js
	> SELECT count(i) FROM count;
	+----------+
	| count(i) |
	+----------+
	| 0        |
	+----------+
	
	> SELECT count (i) FROM count;
	+-----------+
	| count (i) |
	+-----------+
	| 0         |
	+-----------+
	```

<font color="red"><b>配置建议：建议设置该值，可以一定程度上避免使用内建函数同名的元素造成歧义，另外允许空格的特性可以稍微提升一点用户使用友好度</b></font>

## `NO_AUTO_CREATE_USER`

该值用于禁止自动创建密码为空的用户。当没有设置该值时：

* 示例1

---

> 参考链接：
> 
> * [mysql out-of-range-and-overflow](https://dev.mysql.com/doc/refman/8.0/en/out-of-range-and-overflow.html)
> * [mysql sql_mode](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html)
