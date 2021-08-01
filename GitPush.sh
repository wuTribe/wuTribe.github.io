echo "Start submitting code to the local repository"
echo "The current directory is：$0"
git add *
echo;


echo "Commit the changes to the local repository"
echo "please enter the commit info...."
message=$1
now=$(date "+%Y-%m-%d %H:%M:%S")
echo $now
git commit -m "${now} ${message}"
echo;
 
echo "Commit the changes to the remote git server"
git push
echo;
 
echo "Batch execution complete!"
echo;