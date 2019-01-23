#### <font color="blue">为不同的git项目配置各自独立的用户

---

我们在自己的开发机上往往会管理多个git仓库，可能有些git仓库是属于自己的私人github账号，有些是属于公司的个人gitlab开发账号，这样就需要为不同的仓库配置不同的用户

# 方法1: config命令

在git仓库目录下执行

```javascript
$ git config user.name 'xxx'                       
$ git config user.email 'xxx'
```

ps: 配置全局git用户的方法：

```javascript
$ git config --global user.name 'xxx'                       
$ git config --global user.email 'xxx'
```

# 方法2: 修改git配置

git仓库目录下，在.git/config文件中添加以下内容

```javascript
[user]
    name = xxx
    email = xxx
```
