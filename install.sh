#!/bin/bash

region='auto'

if [ -n "$1" ]; then
	region="$1"
fi

runnable() {
	type "$1" 1>/dev/null 2>/dev/null
}

is_chinese_ip() {
    # 获取当前 IP 地址
    local ip=$(curl -s ifconfig.me)

    # 查询 IP 的地理位置
    local location=$(curl -s "http://ip-api.com/json/${ip}?lang=zh-CN" | grep '"country":"中国"')

    if [ -n "$location" ]; then
        # echo "当前 IP ($ip) 是中国的。"
        return 0
    else
        # echo "当前 IP ($ip) 不是中国的。"
        return 1
    fi
}

brew_remote='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
brew_tap='createchstudio/cpc'
install_name='cpc'
remote='github'

if is_chinese_ip; then
	if [ "$region" == "auto" ] || [ "$region" == "china" ]; then
		brew_remote='https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh'
		brew_tap='lightum_cc/cpc https://gitee.com/lightum_cc/homebrew-cpc.git'
		install_name='cpc-cn'
		remote='gitee'
	fi
fi

if runnable brew; then
	echo "Homebrew exists"
else
	echo "Try to install Homebrew for you now"
	/bin/bash -c "$(curl -fsSL $brew_remote)"
fi

echo "Installing CAIE_Code"

brew tap $brew_tap
brew install $install_name

if runnable cpc; then
	echo "Installing dependencies"
	cpc -c remote $remote
	cpc -i

	echo "Install CAIE_Code successfully"
else
	echo "Failed to install CAIE_Code, try to install manually. "
fi
