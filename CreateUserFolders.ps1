$users = import-csv users.csv

ForEach ($user in $users)
{

    $username=($user.username)
    $path = "C:\Users\mburns\Desktop\New folder\"
    New-Item -Path $path -name $username -ItemType "directory"

}
