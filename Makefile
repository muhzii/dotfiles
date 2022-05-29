define replace-with-symlink
	@rm ~/$1 && ln -s $(notdir $(shell pwd))/$1 ~/$1
endef

all: packages_install home_install vim_plug_intall

# NOTE: Only for Arch-Linux for now.
packages_install:
	@echo "Installing pacman packages..."
	sudo pacman -S - < ./pacman-packages

home_install:
	@echo "Installing files in home directory..."
	$(call replace-with-symlink,.bashrc)
	$(call replace-with-symlink,.vimrc)
	$(call replace-with-symlink,.tmux.conf)
	$(call replace-with-symlink,.local/bin/tat)
	$(call replace-with-symlink,.config/kitty/kitty.conf)
	$(call replace-with-symlink,.vim/coc-settings.json)

vim_plug_install:
	@echo "Installing Vim plugins.."
	@vim +PlugInstall +qa
	@vim +PlugUpdate +qa
	@vim +CocInstall $(cat ./vim-coc-extensions | tr "\n" " " | head --bytes -1) +qa
