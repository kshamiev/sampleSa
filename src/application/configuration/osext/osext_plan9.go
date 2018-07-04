package osext // import "application/configuration/osext"

//import "gopkg.in/webnice/debug.v1"
//import "gopkg.in/webnice/log.v2"
import (
	"os"
	"strconv"
	"syscall"
)

func executable() (string, error) {
	f, err := os.Open("/proc/" + strconv.Itoa(os.Getpid()) + "/text")
	if err != nil {
		return "", err
	}
	defer f.Close()
	return syscall.Fd2path(int(f.Fd()))
}
