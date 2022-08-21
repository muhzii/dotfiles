define replace-with-symlink
	@rm -f ~/$1 && ln -s $(shell pwd)/$1 ~/$1
endef

all: packages_install home_install vim_plug_intall

packages_install: pacman_pkgs_install datefudge_install rustup_install

pacman_pkgs_install:
	@echo "Installing pacman packages..."
	sudo pacman -S - < ./pacman-packages
	@sudo systemctl enable docker
	@sudo systemctl start docker

datefudge_install:
	@echo "Installing datefudge..."
	@git clone https://github.com/vvidovic/datefudge.git
	@cd datefudge && make && sudo make install
	@rm -rf datefudge

rustup_install:
	@echo "Installing rustup..."
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	@rustup component add rls rust-analysis rust-src

evscript_install:
	@git clone https://github.com/muhzii/evscript
	@cd evscript && cargo build --release
	@cd evscript && sudo install -Ss -o root -m 4755 target/release/evscript /usr/local/bin/evscript
	@sudo cp ./scripts/caps2esc-mapper.dyon /usr/local/share
	@sudo cp ./scripts/caps2esc-mapper.sh /usr/local/bin
	@sudo cp ./systemd/caps2esc-mapper@.service /usr/lib/systemd/system
	@sudo cp ./udev/00-keyboard-caps2esc-map.rules /etc/udev/rules.d
	@rm -rf evscript

home_install:
	@echo "Installing files in user's home directory..."
	$(call replace-with-symlink,.bashrc)
	$(call replace-with-symlink,.vimrc)
	$(call replace-with-symlink,.tmux.conf)
	@mkdir -p ~/.local/bin
	$(call replace-with-symlink,.local/bin/tat)
	$(call replace-with-symlink,.config/kitty/kitty.conf)
	@mkdir -p ~/.vim
	$(call replace-with-symlink,.vim/coc-settings.json)
	@cp -r ./.vim/colors ~/.vim/

vim_plug_install:
	@echo "Installing Vim plugins.."
	@cp -r ./.vim/plugin ~/.vim
	@curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@vim +PlugInstall +qa
	@vim +PlugUpdate +qa
	@vim "+CocInstall $(cat ./vim-coc-extensions | tr "\n" " " | head --bytes -1)"
