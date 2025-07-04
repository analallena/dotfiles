#pushd $HOME > /dev/null
echo "Adding files"
ln -s $HOME/ws/personal/dotfiles/shell/DOTbash_profile $HOME/.bash_profile
ln -s $HOME/ws/personal/dotfiles/shell/DOTinputrc $HOME/.inputrc
ln -s $HOME//ws/personal/dotfiles/git/DOTgitconfig $HOME/.gitconfig
ln -s $HOME/ws/personal/dotfiles/shell/DOTbashrc $HOME/.bashrc
#popd > /dev/null