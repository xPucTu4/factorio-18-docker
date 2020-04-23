package main

import (
	"os"
	"os/user"
	"path/filepath"
	"strconv"
)

var myUser *user.User
var myGroup *user.Group

func main() {

	myUser,_ = user.Lookup("factorio")
	myGroup,_ = user.LookupGroup("users")

	filepath.Walk("/factorio/", changeMod)
}

func changeMod(path string, info os.FileInfo, _ error) error{
	myUid,_ := strconv.Atoi(myUser.Uid)
	myGid,_ := strconv.Atoi(myGroup.Gid)
	os.Chown(path, myUid, myGid)
	return nil
}
