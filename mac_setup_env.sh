#!/bin/bash

# 该脚本用于新mac电脑安装开发环境

# 定义环境变量
readonly SSH_PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"
readonly SSH_KEY_EMAIL="email"
readonly NVM_SCRIPT_PATH="$HOME/.nvm/nvm.sh"
readonly ZSH_CONFIG_PATH="$HOME/.zshrc"
readonly NODE_VERSIONS=("22" "20")
readonly DEFAULT_NODE_VERSION="22"

# 初始化.zshrc
function init_zshrc() {
    if [[ ! -f "$ZSH_CONFIG_PATH" ]]; then
        touch "$ZSH_CONFIG_PATH"
    fi
}

# 检查并安装指定版本的Node.js
function install_or_check_node_version() {
    local node_version=$1
    if nvm ls "$node_version" &> /dev/null; then
        echo "Node.js version $node_version is already installed."
    else
        echo "Installing Node.js version $node_version..."
        nvm install "$node_version"
    fi
}

# 安装SSH密钥
function install_ssh_keys() {
    if [[ -f "$SSH_PUBLIC_KEY_PATH" ]]; then
        echo "SSH keys already installed."
    else
        echo ">>> Installing SSH keys..."
        ssh-keygen -t rsa -C "$SSH_KEY_EMAIL"
    fi
}

# 安装NVM及Node.js版本
function install_nvm_and_node_versions() {
    if [[ -f "$NVM_SCRIPT_PATH" ]]; then
        echo "NVM is already installed."
    else
        echo ">>> Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    add_nvm_dir_to_zshrc
    
    source "$ZSH_CONFIG_PATH"

    for version in "${NODE_VERSIONS[@]}"; do
        install_or_check_node_version "$version"
    done
    
    if nvm version default &> /dev/null; then
        echo "Default Node.js version is already set to $DEFAULT_NODE_VERSION."
    else
        nvm use "$DEFAULT_NODE_VERSION"
        nvm alias default "$DEFAULT_NODE_VERSION"
    fi
}

# 向.zshrc中添加NVM路径
function add_nvm_dir_to_zshrc() {
    local nvm_dir_content="export NVM_DIR=\"$HOME/.nvm\""
    local path_export_content="[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\""
    
    if ! grep -Fxq "$nvm_dir_content" "$ZSH_CONFIG_PATH"; then
        echo "$nvm_dir_content" >> "$ZSH_CONFIG_PATH"
    fi

    if ! grep -Fxq "$path_export_content" "$ZSH_CONFIG_PATH"; then
        echo "$path_export_content" >> "$ZSH_CONFIG_PATH"
    fi
}

# 安装tnpm
function install_tnpm() {
    if tnpm version &> /dev/null; then
        echo "Tnpm is already installed."
    else
        echo ">>> Installing Tnpm..."
        npm install -g tnpm --registry=https://registry.anpm.alibaba-inc.com
    fi

    tnpm login
}

# 安装Python
function install_python() {
    if python --version &> /dev/null; then
        echo "Python is already installed."
    else
        echo ">>> Installing Pyenv..."

        if [[ -d "$HOME/.pyenv" ]]; then
            echo "$HOME/.pyenv already exists"
        else 
            curl https://pyenv.run | bash
        fi

        add_pyenv_root_to_zshrc
    fi

    source "$ZSH_CONFIG_PATH"
}

# 向.zshrc中添加Pyenv路径
function add_pyenv_root_to_zshrc() {
    local pyenv_root_content='export PYENV_ROOT="$HOME/.pyenv"'
    local path_export_content='[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    local eval_init_content='eval "$(pyenv init -)"'
    
    if ! grep -Fxq "$pyenv_root_content" "$ZSH_CONFIG_PATH"; then
        echo "$pyenv_root_content" >> "$ZSH_CONFIG_PATH"
    fi
    
    if ! grep -Fxq "$path_export_content" "$ZSH_CONFIG_PATH"; then
        echo "$path_export_content" >> "$ZSH_CONFIG_PATH"
    fi
    
    if ! grep -Fxq "$eval_init_content" "$ZSH_CONFIG_PATH"; then
        echo "$eval_init_content" >> "$ZSH_CONFIG_PATH"
    fi
    
    echo "PYENV_ROOT added successfully."
}

# 主执行流程
init_zshrc
install_ssh_keys
install_nvm_and_node_versions
install_tnpm
install_python

echo ">>> Showing SSH public key content:"
cat "$SSH_PUBLIC_KEY_PATH"

echo ">>> .zshrc content:"
cat "$ZSH_CONFIG_PATH"

echo ">>> 通过 pkg 安装 brew >>> https://github.com/Homebrew/brew/releases"