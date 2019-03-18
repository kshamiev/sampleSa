// Code generated by running "go generate" by utility db2struct: "https://github.com/webnice/d2s"; DO NOT EDIT.
// This file was generated at 18.03.2019 11:43:57 UTC
// Generator: db2struct (go get -u gopkg.in/webnice/d2s.v1/db2struct)

// The structure is based on the database table structure.
// Database: "sample"
// Table: "settings"

package settings // import "application/models/settings"

import (
	nul "gopkg.in/webnice/lin.v1/nl"
)

// settings Хранение настроек с типизированными значениями
type settings struct {
	ID           uint64      `db:"id"           gorm:"column:id;primary_key;          AUTO_INCREMENT;NOT NULL;DEFAULT NULL;precision:20;type:BIGINT(20) UNSIGNED"` // Уникальный идентификатор записи
	CreateAt     nul.Time    `db:"createAt"     gorm:"column:createAt;                NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время создания записи
	UpdateAt     nul.Time    `db:"updateAt"     gorm:"column:updateAt;                NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время обновления записи
	AccessAt     nul.Time    `db:"accessAt"     gorm:"column:accessAt;                NULL;DEFAULT NULL;type:DATETIME"                                           ` // Дата и время последнего доступа к записи
	Key          string      `db:"key"          gorm:"column:key;                     NOT NULL;DEFAULT NULL;size:255;type:VARCHAR(255)"                          ` // Ключ
	ValueString  nul.String  `db:"valueString"  gorm:"column:valueString;             NULL;DEFAULT NULL;size:4294967295;type:LONGTEXT"                           ` // Строковое значение
	ValueDate    nul.Time    `db:"valueDate"    gorm:"column:valueDate;               NULL;DEFAULT NULL;type:DATETIME"                                           ` // Значение даты и времени
	ValueUint    nul.Uint64  `db:"valueUint"    gorm:"column:valueUint;               NULL;DEFAULT NULL;precision:20;type:BIGINT(20) UNSIGNED"                   ` // Числовое unsigned значение
	ValueInt     nul.Int64   `db:"valueInt"     gorm:"column:valueInt;                NULL;DEFAULT NULL;precision:19;type:BIGINT(20)"                            ` // Числовое значение
	ValueDecimal nul.Float64 `db:"valueDecimal" gorm:"column:valueDecimal;            NULL;DEFAULT NULL;precision:16;scale:4;type:DECIMAL(16,4)"                 ` // Значение с плавающей точкой
	ValueFloat   nul.Float64 `db:"valueFloat"   gorm:"column:valueFloat;              NULL;DEFAULT NULL;precision:22;type:DOUBLE"                                ` // IEEE-754 64-bit floating-point number
	ValueBit     nul.Bool    `db:"valueBit"     gorm:"column:valueBit;                NULL;DEFAULT NULL;type:TINYINT(1)"                                         ` // Boolean value
	ValueBlob    nul.Bytes   `db:"valueBlob"    gorm:"column:valueBlob;               NULL;DEFAULT NULL;type:LONGBLOB"                                           ` // Blob value
}
