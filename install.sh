#!/bin/bash

echo "Installing NoTcl..."

if [ ! $HOME/bin/ ];
	# if you have no /home/you/bin, we make one to install notcl in
	# if you don't like that, and you have admin privileges,
	# you could just as well copy no.tcl to /usr/local/bin/notcl
	# or something, yourself (or anywhere in your $PATH),
	# chmod +x notcl, and good to go.
	then mkdir $HOME/bin
	$PATH=$PATH:/$HOME/bin/
	export PATH	
fi

echo "Moving files"

cp main.tcl $HOME/bin/notcl

echo "Configuring permissions"

cd $HOME/bin
chmod +x notcl

echo "Installation complete!"
echo "Thank you for using NoTcl"
echo "To run NoTcl, in terminal type notcl, or make an icon/menu item/short cut to $HOME/bin/notcl"
echo "Enjoy!"

exit
