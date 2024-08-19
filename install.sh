#!/bin/bash

region='auto'
install_vsc=false
arch=$(uname -m)

# 字符串染色程序
if [[ -t 1 ]]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi

tty_universal() { tty_escape "0;$1"; } # 正常显示
tty_mkbold() { tty_escape "1;$1"; }    # 设置高亮
tty_underline="$(tty_escape "4;39")"   # 下划线
tty_blue="$(tty_universal 34)"         # 蓝色
tty_red="$(tty_universal 31)"          # 红色
tty_green="$(tty_universal 32)"        # 绿色
tty_yellow="$(tty_universal 33)"       # 黄色
tty_bold="$(tty_universal 39)"         # 加黑
tty_cyan="$(tty_universal 36)"         # 青色
tty_reset="$(tty_escape 0)"            # 去除颜色

# 解析命令行参数
while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		--region)
		region="$2"
		shift # 跳过值
		shift # 跳到下一个参数
		;;
		--with-vsc)
		install_vsc=true
		shift # 跳到下一个参数
		;;
		*)    # 未知参数
		echo "${tty_red}🚨 Unknown option: $1"
		echo "${tty_reset}"
		exit 1
		;;
	esac
done

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

install_vsc_extension() {
	# 判断扩展是否已安装
	if ! "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --list-extensions | grep -q "createchstudioshanghaiinc.cpc-interpreter-extension"; then
		echo "${tty_blue}⏳ Installing CAIE Pseudocode Extensions"
		echo "${tty_reset}"
		"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --install-extension createchstudioshanghaiinc.cpc-interpreter-extension
		wait $!
		echo "${tty_green}✅ Install CAIE Pseudocode Extensions successfully"
		echo "${tty_reset}"
	else
		echo "${tty_yellow}⚠️ CAIE Pseudocode Extensions already installed"
		echo "${tty_reset}"
	fi
}

brew_remote='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
brew_tap='createchstudio/cpc'
install_name='cpc'
remote='github'

if is_chinese_ip; then
	if [ "$region" == "auto" ] || [ "$region" == "china" ]; then
		echo "${tty_yellow}🇨🇳 Detected that you are in China, use mirror to download"
		echo "${tty_reset}"
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

export HOMEBREW_NO_AUTO_UPDATE=1

brew tap $brew_tap
wait $!
brew install $install_name && {
    echo "${tty_cyan}⏳ Installing dependencies"
    echo "${tty_reset}"

    cpc -c remote $remote
    wait $!

    echo "${tty_green}✅ Install CAIE_Code successfully"
    echo "${tty_reset}"

	# 如果需要，安装 Visual Studio Code 及其扩展
	if [ "$install_vsc" = true ]; then
		if [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
			echo "${tty_yellow}✅ Visual Studio Code already installed"
			echo "${tty_reset}"
			install_vsc_extension()
		else
			echo "${tty_blue}⏳ Installing Visual Studio Code"
			echo "${tty_reset}"
			brew install --cask visual-studio-code && {
				echo "${tty_green}✅ Install Visual Studio Code successfully"
				echo "${tty_reset}"
				install_vsc_extension()
			} || {
				echo "${tty_red}🚨 Failed to install Visual Studio Code, try to install manually."
				echo "${tty_reset}"
			}
		fi
	fi
} || {
    echo "${tty_red}🚨 Failed to install CAIE_Code, try to install manually."
    echo "${tty_reset}"
}
