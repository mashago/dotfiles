
setup ftp user,pwd,marco in .netrc

command line connect ftp:
ftp -p $MY_HOST

ftp run marco
echo "$ MY_MARCO_NAME" | ftp -p $MY_HOST

