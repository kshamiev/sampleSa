// Code generated by running "go generate" by utility db2struct: "https://github.com/webnice/d2s"; DO NOT EDIT.
// This file was generated at 18.03.2019 11:43:57 UTC
// Generator: db2struct (go get -u gopkg.in/webnice/d2s.v1/db2struct)

// The structure is based on the database table structure.
// Database: "sample"
// Table: "myitem"

package types // import "application/models/myitem/types"

import (
	"time"

	nul "gopkg.in/webnice/lin.v1/nl"
)

// Myitem Какая-то сущность бизнес логики
type Myitem struct {
	ID       uint64    `db:"id"       gorm:"column:id;primary_key;      AUTO_INCREMENT;NOT NULL;DEFAULT NULL;precision:20;type:BIGINT(20) UNSIGNED"` // Уникальный идентификатор записи
	CreateAt nul.Time  `db:"createAt" gorm:"column:createAt;            NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время создания записи
	UpdateAt nul.Time  `db:"updateAt" gorm:"column:updateAt;            NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время обновления записи
	DeleteAt nul.Time  `db:"deleteAt" gorm:"column:deleteAt;            NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время удаления записи (пометка на удаление)
	AccessAt nul.Time  `db:"accessAt" gorm:"column:accessAt;            NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время последнего доступа к записи
	Date     time.Time `db:"date"     gorm:"column:date;                NOT NULL;DEFAULT NULL;type:DATETIME"                                       ` // Любая дата и время
	Number   int64     `db:"number"   gorm:"column:number;              NOT NULL;DEFAULT '0';precision:19;type:BIGINT(20)"                         ` // Любое число
	Text     string    `db:"text"     gorm:"column:text;                NOT NULL;DEFAULT NULL;size:255;type:TINYTEXT"                              ` // Любая строка
}