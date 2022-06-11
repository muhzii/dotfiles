define replace-with-symlink
	@rm -f ~/$1 && ln -s $(shell pwd)/$1 ~/$1
endef

define caps_lock_esc_map_evscript
//! [events]
//! keys = ['ESC']
fn main() ~ evdevs, uinput {
    should_esc := false
    loop {
        evts := next_events(evdevs)
        for i {
            evt := evts[i]
            xcape(mut should_esc, evt, KEY_CAPSLOCK(), [KEY_ESC()])
        }
    }
}
endef

define evscript_launcher
#!/bin/sh

evdev=$$1

is_kbd=$$(ls -al /dev/input/by-path/ | grep $$evdev | grep kbd)
if [ ! -z "$$is_kbd" ]; then
	echo evscript -f $(shell echo ~/.local/share/caps_lock_esc_map.dyon) -d /dev/input/$$evdev | at now
fi
endef

all: packages_install home_install vim_plug_intall

packages_install: pacman_pkgs_install datefudge_install rustup_install

pacman_pkgs_install:
	@echo "Installing pacman packages..."
	sudo pacman -S - < ./pacman-packages
	@sudo systemctl enable at
	@sudo systemctl start at
	@sudo systemctl enable docker
	@sudo systemctl start docker

datefudge_install:
	@echo "Installing datefudge..."
	@git clone https://github.com/vvidovic/datefudge.git
	@cd datefudge && make && sudo make install
	@rm -rf datefudge

export caps_lock_esc_map_evscript
export evscript_launcher
rustup_install:
	@echo "Installing rustup..."
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	@rustup component add rls rust-analysis rust-src

evscript_install:
	@git clone https://github.com/myfreeweb/evscript
	@cd evscript && cargo build --release
	@cd evscript && sudo install -Ss -o root -m 4755 target/release/evscript /usr/local/bin/evscript
	@echo "$$caps_lock_esc_map_evscript" > ~/.local/share/caps_lock_esc_map.dyon
	@echo "$$evscript_launcher" > ~/.local/bin/evscript_launcher.sh
	@chmod +x ~/.local/bin/evscript_launcher.sh
	@echo 'ACTION=="add", KERNEL=="event*", RUN+="$(shell echo ~/.local/bin/evscript_launcher.sh) %k"' | \
		sudo tee /etc/udev/rules.d/00-keyboard-caps-lock-map.rules
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
