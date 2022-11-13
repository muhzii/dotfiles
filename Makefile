define replace-with-symlink
	@rm -f ~/$1 && ln -s $(shell pwd)/$1 ~/$1
endef

all: system_install aur_install evscript_install user_install

system_install:
	@echo "Installing pacman packages..."
	@if ! grep -Fxq "[multilib]" /etc/pacman.conf; then \
		@echo "[multilib]"|sudo tee -a /etc/pacman.conf; \
		@echo "Include = /etc/pacman.d/mirrorlist"|sudo tee -a /etc/pacman.conf; \
	fi
	sudo pacman -Suu --noconfirm
	sudo pacman -S --noconfirm - < ./pkg/pacman-packages
	@sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $$(whoami)
	@echo "Installing rustup..."
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@source "$$HOME/.cargo/env" && rustup component add rls rust-analysis rust-src
	@echo "Installing datefudge..."
	@rm -rf repos && mkdir repos
	@git clone https://github.com/vvidovic/datefudge.git repos/datefudge
	@cd repos/datefudge && make && sudo make install

aur_install:
	@echo "Installing AUR packages"
	@gpg --recv-key AFF2A1415F6A3A38
	@gpg --recv-key 5E3C45D7B312C643
	@rm -rf repos && mkdir -p repos
	@while IFS= read -r line; do \
		git clone https://aur.archlinux.org/$$line.git repos/$$line; \
		(cd repos/$$line && yes|makepkg -sif); \
	done < ./pkg/pacman-aur-packages

evscript_install:
	@rm -rf repos && mkdir -p repos
	@git clone https://github.com/muhzii/evscript repos/evscript
	@cd repos/evscript && source "$$HOME/.cargo/env" && cargo build --release
	@cd repos/evscript && sudo install -Ss -o root -m 4755 target/release/evscript /usr/local/bin/evscript
	@sudo cp ./scripts/caps2esc-mapper.dyon /usr/local/share
	@sudo cp ./scripts/caps2esc-mapper.sh /usr/local/bin
	@sudo cp ./systemd/caps2esc-mapper@.service /usr/lib/systemd/system
	@sudo cp ./udev/00-keyboard-caps2esc-map.rules /etc/udev/rules.d

user_install: home_install vim_plug_install

home_install:
	@echo "Installing files in user's home directory..."
	$(call replace-with-symlink,.bashrc)
	$(call replace-with-symlink,.vimrc)
	$(call replace-with-symlink,.tmux.conf)
	@mkdir -p ~/.local/bin
	$(call replace-with-symlink,.local/bin/tat)
	@mkdir -p ~/.config/kitty
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
	@vim "+CocInstall $$(cat ./vim-coc-extensions | tr "\n" " " | head --bytes -1)"
