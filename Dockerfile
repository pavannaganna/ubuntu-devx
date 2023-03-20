FROM ubuntu:22.04


WORKDIR /var/init/setup
RUN apt-get update
RUN apt-get install -y \
	wget \
	lsb-release \
	wget \
	software-properties-common \
	gnupg \
	curl \
	unzip \
	zsh
# Setting Up nodejs
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh

# Setting up clang++ and llvm tools
RUN wget -O llvm.sh https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh && ./llvm.sh 15 all
RUN ln -s /usr/bin/clang++-15 /usr/bin/clang++
RUN ln -s /usr/bin/clang-15 /usr/bin/clang
RUN ln -s /usr/bin/clangd-15 /usr/bin/clangd
RUN ln -s /usr/bin/clang-format-15 /usr/bin/clang-format

# Install nodejs and npm
RUN apt-get install -y nodejs

# Install Language Servers
RUN apt-get install -y git ccls
RUN apt-get install -y pip

WORKDIR /opt
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
	chmod u+x nvim.appimage && \
	./nvim.appimage --appimage-extract && \
	ln -s /opt/squashfs-root/AppRun /usr/bin/nvim && \
	rm nvim.appimage


# Add developer user
RUN useradd -m -s /usr/bin/zsh developer

WORKDIR /home/developer

USER developer
RUN pip install pyright

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN mkdir /home/developer/.oh-my-zsh/cache/completions

RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
	~/.local/share/nvim/site/pack/packer/start/packer.nvim

COPY nvim .config/nvim
COPY zsh  .config/zsh
RUN rm .zshrc && ln -s .config/zsh/.zshrc .zshrc

# Setup NVIM with all plugins
RUN chmod 777 /home/developer
RUN nvim -E -s -u /home/developer/.config/nvim +PackerUpdate +qa

ENTRYPOINT /usr/bin/zsh
