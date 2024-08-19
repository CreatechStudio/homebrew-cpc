class CpcCn < Formula
    desc "CAIE_Code project description"
    homepage "https://gitee.com/ricky-tap/CAIE_Code"
    url "https://gitee.com/ricky-tap/CAIE_Code.git"
    version "0.1.4"

    depends_on "pypy3.10"

    def install
        # 克隆代码库到临时目录
        repo_path = prefix/"CAIE_Code"
        system "git", "clone", stable.url, repo_path
        cd repo_path do
            # 配置安全目录
            system "git", "config", "--global", "--add", "safe.directory", repo_path

            # 获取 macOS 版本号
            os_version = `sw_vers -productVersion`.strip
            major_version = os_version.split('.')[0].to_i

            # 根据 macOS 版本和架构选择正确的可执行文件
            executable = if major_version >= 12
                "cpc"
            else
                arch = `uname -m`.strip
                if arch == "arm64"
                    "cpc_arm"
                else
                    "cpc_x86"
                end
            end

            # 将可执行文件符号链接到 Homebrew 的 bin 目录
            bin.install_symlink "#{repo_path}/bin/#{executable}" => "cpc"
            # 将 man 手册页符号链接到 Homebrew 的 man 目录
            man1.install_symlink "#{repo_path}/man/cpc.1" => "cpc.1"
        end
    end

    def caveats
        <<~EOS
            如果你移动了安装目录，请重新运行 Homebrew 安装命令以重新创建符号链接。
        EOS
    end

    test do
        # 测试是否成功安装并链接了 cpc
        assert_predicate bin/"cpc", :exist?, "cpc 符号链接未创建"
        assert_match "test", shell_output("#{bin}/cpc --version")
    end
end
