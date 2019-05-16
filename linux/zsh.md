#### <font color="blue">非root用户安装终极shell zsh</font>

---

1. 下载zsh源码包: `wget https://sourceforge.net/projects/zsh/files/zsh/5.7.1/zsh-5.7.1.tar.xz`
2. 解压:

	```js
	$ xz -d zsh-5.7.1.tar.xz
	$ tar -xvf zsh-5.7.1.tar
	```
	
3. 安装zsh，配置安装在用户目录下

	```js
	$ cd zsh-5.7.1
	$ ./configure --prefix=$HOME/
	$ make && make install
	```
	
	> 完成后zsh会安装到`$HOME/bin`下
	
4. 设置默认shell为zsh，在主目录下的`.bashrc`中添加

	```js
	export PATH=$PATH:$HOME/bin   # 添加PATH
	export SHELL=`which zsh`      # 设置$SHELL为zsh
	exec `which zsh` -l           # 设置登录为zsh
	```
	
	> 完成后执行`source ~/.bashrc`即可生效
	
5. 安装oh-my-zsh: `sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`
6. enjoy it !

	* 推荐设置`.zshrc`中的`ZSH_THEME`为"clean"

> 参考链接：
> 
> * [download zsh from source](http://zsh.sourceforge.net/Arc/source.html)
> * [oh-my-zsh官网](https://ohmyz.sh/)