// Package img Пакет помогающий работать с графическими озображениями
// nolint: goimports
package img // import "application/modules/img"

//import "gopkg.in/webnice/debug.v1"
//import "gopkg.in/webnice/log.v2"
import (
	"bytes"
	"fmt"
	"image"
	"io"
	"os"
	stddebug "runtime/debug"
	"strings"

	// Регистрация поддерживаемых форматов графических изображений
	_ "application/modules/img/ico" // Расширение image для формата ico
	_ "golang.org/x/image/bmp"      // Расширение image для формата bmp
	_ "golang.org/x/image/tiff"     // Расширение image для формата tiff
	_ "image/gif"                   // Расширение image для формата gif
	_ "image/jpeg"                  // Расширение image для формата jpeg
	_ "image/png"                   // Расширение image для формата png
)

// ReadFrom Реализация интерфейса io.ReadFrom
// При вызове, графическое изображение перезаписывается данными из Reader
func (i *imgItem) ReadFrom(r io.Reader) (n int64, err error) {
	var im image.Image
	var tpe string
	var ok bool

	defer func() {
		if e := recover(); e != nil {
			err = fmt.Errorf("Panic recovery:\n%v\n%s", e.(error), string(stddebug.Stack()))
		}
	}()
	//switch r.(type) {
	//}
	if _, ok = r.(*bytes.Buffer); ok {
		n = int64(r.(*bytes.Buffer).Len())
	} else if _, ok = r.(*os.File); ok {
		if i.fileInfo, err = r.(*os.File).Stat(); err != nil {
			return
		}
		n = i.fileInfo.Size()
	}
	if im, tpe, err = image.Decode(r); err != nil {
		return
	}
	i.SetImage(im).
		SetType(Type(strings.ToLower(tpe))).
		SetConfig(image.Config{
			Width:      i.image.Bounds().Max.X,
			Height:     i.image.Bounds().Max.Y,
			ColorModel: i.image.ColorModel(),
		})

	return
}

// SetImage Загрузка объекта графического изображения из стандартного интерфейса image.Image
func (i *imgItem) SetImage(im image.Image) Image { i.image = im; return i }

// SetType Установка формата графического изображения
func (i *imgItem) SetType(t Type) Image { i.tpe = t; return i }
