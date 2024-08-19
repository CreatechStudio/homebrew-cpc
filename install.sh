#!/bin/bash

region='auto'
arch=$(uname -m)

# 字符串染色程序
if [[ -t 1 ]]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi

tty_universal() { tty_escape "0;$1"; } #正常显示
tty_mkbold() { tty_escape "1;$1"; }    #设置高亮
tty_underline="$(tty_escape "4;39")"   #下划线
tty_blue="$(tty_universal 34)"         #蓝色
tty_red="$(tty_universal 31)"          #红色
tty_green="$(tty_universal 32)"        #绿色
tty_yellow="$(tty_universal 33)"       #黄色
tty_bold="$(tty_universal 39)"         #加黑
tty_cyan="$(tty_universal 36)"         #青色
tty_reset="$(tty_escape 0)"            #去除颜色

if [ -n "$1" ]; then
	region="$1"
fi

runnable() {
	type "$1" 1>/dev/null 2>/dev/null
}

is_chinese_ip() {
    local ip=$(curl -s ifconfig.me)
    local location=$(curl -s "http://ip-api.com/json/${ip}?lang=zh-CN" | grep '"country":"中国"')

    if [ -n "$location" ]; then
        return 0
    else
        return 1
    fi
}

brew_remote='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
brew_tap='createchstudio/cpc'
install_name='cpc'
remote='github'

if is_chinese_ip; then
	if [ "$region" == "auto" ] || [ "$region" == "china" ]; then
		brew_remote='https://gitee.com/ricky-tap/HomebrewCN/raw/master/Homebrew.sh'
		brew_tap='lightum_cc/cpc https://gitee.com/lightum_cc/homebrew-cpc.git'
		install_name='cpc-cn'
		remote='gitee'

		export HOMEBREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
		export HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
		export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
	fi
fi

if runnable brew; then
	echo "${tty_yellow}✅ Homebrew exists"
	echo "${tty_reset}"
else
	echo "${tty_blue}⏳ Try to install Homebrew for you now: "
	echo "${tty_reset}"
	/bin/bash -c "$(curl -fsSL $brew_remote)"
	wait $!
fi

echo "${tty_blue}⏳ Installing CAIE_Code"
echo "${tty_reset}"

echo "${tty_blue}⏳ Activating Homebrew"
echo "${tty_reset}"

if [[ "$arch" == "arm64" ]]; then
	eval $(/opt/homebrew/bin/brew shellenv)
else
	eval $(/usr/local/bin/brew shellenv)
fi

brew tap $brew_tap
wait $!
brew install $install_name --json=v2 > /dev/null
wait

if runnable cpc; then
	echo "${tty_cyan}⏳ Installing dependencies"
	echo "${tty_reset}"

	cpc -c remote $remote
	wait $!

	echo "${tty_green}✅ Install CAIE_Code successfully"
	echo "${tty_reset}"
else
	echo "${tty_red}🚨 Failed to install CAIE_Code, try to install manually. "
	echo "${tty_reset}"
fi
