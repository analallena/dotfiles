#pushd $HOME > /dev/null
echo "Adding files"
ln -s $HOME/ws/personal/dotfiles/shell/DOTbash_profile .bash_profile
ln -s $HOME/ws/personal/dotfiles/shell/DOTinputrc .inputrc
ln -s $HOME//ws/personal/dotfiles/git/DOTgitconfig .gitconfig
ln -s $HOME/ws/personal/dotfiles/shell/DOTbashrc .bashrc
#popd > /dev/null