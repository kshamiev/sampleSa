## Simple projects tooling for every day
## (c)Alex Geer <monoflash@gmail.com>
## Makefile version: 2018.12.17

## Project name and source directory path
DIR         := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

## Creating .env file from template, if file not exists
ifeq ("$(wildcard $(DIR)/.env)","")
  RSP1      := $(shell cp -v $(DIR)/.example_env $(DIR)/.env)
endif
## Creating .prj file from template, if file not exists
ifeq ("$(wildcard $(DIR)/.prj)","")
  RSP2      := $(shell cp -v $(DIR)/.example_prj $(DIR)/.prj)
endif
include $(DIR)/.env
include $(DIR)/.prj

APP         := $(PROJECT_NAME)
GOPATH      := $(DIR):$(GOPATH)
DATE        := $(shell date -u +%Y%m%d.%H%M%S.%Z)
LDFLAGS      = -X main.build=$(DATE)
GOGENERATE   = $(shell if [ -f .gogenerate ]; then cat .gogenerate; fi)
TESTPACKETS  = $(shell if [ -f .testpackages ]; then cat .testpackages; fi)
BENCHPACKETS = $(shell if [ -f .benchpackages ]; then cat .benchpackages; fi)
GO111MODULE ?= $(GO111MODULE:off)

PRJ01       := $(APP)
BIN01       := $(DIR)/bin/$(PRJ01)
VER01       := $(shell ${BIN01} version 2>/dev/null)
VERN01      := $(shell echo "$(VER01)" | awk -F '-' '{ print $$1 }' )
VERB01      := $(shell echo "$(VER01)" | awk -F 'build.' '{ print $$2 }' )
PIDF01      := $(DIR)/run/$(PRJ01).pid
PIDN01       = $(shell if [ -f $(PIDF01) ]; then  cat $(PIDF01); fi)

default: help

## Dependences manager
dep-init:
	@for dir in ${PROJECT_FOLDERS}; do \
	  if [ ! -d "${DIR}/$${dir}" ]; then \
		  mkdir -p "${DIR}/$${dir}"; \
		fi; \
	done
	@if [ ! -f ${DIR}/src/go.mod ]; then \
        cd ${DIR}/src; GO111MODULE="on" GOPATH="$(DIR)" go mod init ${PRJ01}; \
  fi
.PHONY: dep-init
dep: dep-init
	@cd ${DIR}/src; GO111MODULE="on" GOPATH="$(DIR)" go mod download
	@cd ${DIR}/src; GO111MODULE="on" GOPATH="$(DIR)" go get -u
	@cd ${DIR}/src; GO111MODULE="on" GOPATH="$(DIR)" go mod tidy
	@cd ${DIR}/src; GO111MODULE="on" GOPATH="$(DIR)" go mod vendor
.PHONY: dep

## Code generation (run only during development)
# All generating files are included in a .gogenerate file
gen: dep-init
	@for PKGNAME in $(GOGENERATE); do GOPATH="$(DIR)" go generate $${PKGNAME}; done
.PHONY: gen

## Build project
build:
	@GO111MODULE="off" GOPATH="$(DIR)" go build -i \
	-o ${BIN01} \
	-gcflags "all=-N -l" \
	-ldflags "${LDFLAGS}" \
	-pkgdir ${DIR}/pkg \
	${PRJ01}
.PHONY: build

## Run application in development mode
dev: clear
	${BIN01} --debug daemon
.PHONY: dev

## Run application in production mode
run:
	${BIN01} daemon
.PHONY: run

## Kill process and remove pid file
kill:
	@if [ ! "$(PIDN01)x" == "x" ]; then \
		kill -KILL "$(PIDN01)" 2>/dev/null; \
		if [ $$? -ne 0 ]; then echo "No such process ID: $(PIDN01)"; fi; \
	fi
	@rm "$(PIDF01)" 2>/dev/null; true
.PHONY: kill

## Getting application version
version: v
v:
	@${BIN01} version
.PHONY: version
.PHONY: v

## RPM build openSUSE linux version
RPMBUILD_OS ?= $(RPMBUILD_OS:leap)
RPMBUILD_OS ?= $(RPMBUILD_OS:tumbleweed)
## Creating RPM package
rpm:
	@mkdir -p ${DIR}/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}; true
	## Copying the content needed to build the RPM package
	# File descriptions are contained in the .rpm file
	@for item in $(RPM_BUILD_SOURCE); do\
		SRC=`echo $${item} | awk -F':' '{print $$1}'`; \
		DST=`echo $${item} | awk -F':' '{print $$2}'`; \
		cp -v ${DIR}/$${SRC} ${DIR}/rpmbuild/$${DST}; \
	done
	## Execution of data preparation commands for build an RPM package
	# Command descriptions are contained in the .rpm file
	@for cmd in $(RPM_BUILD_COMMANDS); do\
		cd ${DIR}; sh -v -c "$${cmd}"; \
	done
	## Cutting off the old %changelog section from spec file
	@mv ${DIR}/rpmbuild/SPECS/${PRJ01}.spec ${DIR}/rpmbuild/SPECS/src.spec
	@sed '/%changelog/,$$d' ${DIR}/rpmbuild/SPECS/src.spec | sed -e :a -e '/^\n*$$/{$$d;N;};/\n$$/ba' > ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	@echo "\n" >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	## Adding a new %changelog section with comments from git commits
	@echo '%changelog' >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	@echo "* `LC_ALL=en_EN.utf8 date -u '+%a %b %d %Y'` version: %{_app_version_number} build: %{_app_version_build}" >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	@echo "- make rpm at `LC_ALL=en_EN.utf8 date -u`. Application version: %{_app_version_number} build: %{_app_version_build}\n" >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	@git log \
		--format="* %cd %aN <%aE>%n- (%h) %s%d%n" \
		--date="format:%a %b %d %Y" | sed 's/[0-9]+:[0-9]+:[0-9]+ //' | sed -e :a -e '/^\n*$$/{$$d;N;};/\n$$/ba' >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	## Adding the content of old %changelog section to the end of the new %changelog section
	@echo "" >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
	@sed '/%changelog/,$$!d' ${DIR}/rpmbuild/SPECS/src.spec | sed 1,1d >> ${DIR}/rpmbuild/SPECS/${PRJ01}.spec && rm ${DIR}/rpmbuild/SPECS/src.spec
	## Build the RPM package
	@RPMBUILD_OS="${RPMBUILD_OS}" rpmbuild \
		--define "_topdir ${DIR}/rpmbuild" \
    	--define "_app_version_number $(VERN01)" \
    	--define "_app_version_build $(VERB01)" \
    	-bb ${DIR}/rpmbuild/SPECS/${PRJ01}.spec
.PHONY: rpm

## Migration tools for all databases
# Please see files .env and .env_example, for setup access to databases
####################################
COMMANDS  = up create down status redo version
MTARGETS := $(shell \
for cmd in $(COMMANDS); do \
	for drv in $(MIGRATIONS); do \
		echo "m-$${drv}-$${cmd}"; \
	done; \
done)
## Migration tools create directory
migration-mkdir:
	@for dir in $$(echo $(MIGRATIONS)); do \
		mkdir -p "$(DIR)/migrations/$${dir}"; true; \
	done
.PHONY: migration-mkdir
## Migration tools gets data from env
MIGRATION_DIR  = ${$(shell echo $(shell echo "${@}" | sed -e 's/^m-\(.*\)-\(.*\)$$/\1/') | awk '{print "GOOSE_DIR_"toupper($0)}')}
MIGRATION_DRV  = ${$(shell echo $(shell echo "${@}" | sed -e 's/^m-\(.*\)-\(.*\)$$/\1/') | awk '{print "GOOSE_DRV_"toupper($0)}')}
MIGRATION_DSN  = ${$(shell echo $(shell echo "${@}" | sed -e 's/^m-\(.*\)-\(.*\)$$/\1/') | awk '{print "GOOSE_DSN_"toupper($0)}')}
MIGRATION_CMD  = $(shell echo $(shell echo "${@}" | sed -e 's/^m-\(.*\)-\(.*\)$$/\2/'))
MIGRATION_TMP := $(shell mktemp)
## Migration tools targets
migration-commands: $(MTARGETS)
$(MTARGETS): migration-mkdir
	@if [ "$(MIGRATION_CMD)" == "create" ]; then\
		read -p "Введите название миграции: " MGRNAME && \
		if [ "$${MGRNAME}" == "" ]; then MGRNAME="new"; fi && \
		echo "$${MGRNAME}" > "$(MIGRATION_TMP)"; \
	fi
	@if ([ ! "`cat $(MIGRATION_TMP)`" = "" ]) && ([ "$(MIGRATION_CMD)" == "create" ]); then\
		GOOSE_DIR="$(MIGRATION_DIR)" GOOSE_DRV="$(MIGRATION_DRV)" GOOSE_DSN="$(MIGRATION_DSN)" gsmigrate $(MIGRATION_CMD) "`cat $(MIGRATION_TMP)`"; \
	else \
		GOOSE_DIR="$(MIGRATION_DIR)" GOOSE_DRV="$(MIGRATION_DRV)" GOOSE_DSN="$(MIGRATION_DSN)" gsmigrate $(MIGRATION_CMD); \
	fi
	@if [ -f "$(MIGRATION_TMP)" ]; then rm "$(MIGRATION_TMP)"; fi
.PHONY: migration-commands $(MTARGETS)
####################################

## Testing one or multiple packages as well as applications with reporting on the percentage of test coverage
# All testing files are included in a .testpackages file
test:
	@echo "mode: set" > $(DIR)/log/coverage.log
	@for PACKET in $(TESTPACKETS); do \
		touch coverage-tmp.log; \
		GOPATH=${GOPATH} go test -v -covermode=count -coverprofile=$(DIR)/log/coverage-tmp.log $$PACKET; \
		if [ "$$?" -ne "0" ]; then exit $$?; fi; \
		tail -n +2 $(DIR)/log/coverage-tmp.log | sort -r | awk '{if($$1 != last) {print $$0;last=$$1}}' >> $(DIR)/log/coverage.log; \
		rm -f $(DIR)/log/coverage-tmp.log; true; \
	done
.PHONY: test

## Displaying in the browser coverage of tested code, on the html report (run only during development)
cover: test
	@GOPATH=${GOPATH} go tool cover -html=$(DIR)/log/coverage.log
.PHONY: cover

## Performance testing
# All testing files are included in a .benchpackages file
bench:
	@for PACKET in $(BENCHPACKETS); do GOPATH=${GOPATH} go test -race -bench=. -benchmem $$PACKET; done
.PHONY: bench

## Code quality testing
# https://github.com/alecthomas/gometalinter/
# install: curl -L https://git.io/vp6lP | sh
lint:
	@gometalinter \
	--vendor \
	--deadline=15m \
	--cyclo-over=20 \
	--line-length=120 \
	--warn-unmatched-nolint \
	--disable=aligncheck \
	--enable=test \
	--enable=goimports \
	--enable=gosimple \
	--enable=misspell \
	--enable=unused \
	--enable=megacheck \
	--skip=src/vendor \
	--linter="vet:go tool vet -printfuncs=Infof,Debugf,Warningf,Errorf:PATH:LINE:MESSAGE" \
	src/...
.PHONY: lint

## Cleaning console screen
clear:
	clear
.PHONY: clear

## Clearing project temporary files
clean:
	@GOPATH="$(DIR)" go clean -cache
	@chown -R `whoami` ${DIR}/pkg/; true
	@chmod -R 0777 ${DIR}/pkg/; true
	@rm -rf ${DIR}/bin/*; true
	@rm -rf ${DIR}/pkg/*; true
	@rm -rf ${DIR}/run/*.pid; true
	@rm -rf ${DIR}/log/*.log; true
	@rm -rf ${DIR}/rpmbuild; true
	@rm -rf ${DIR}/*.log; true
.PHONY: clean

## Help for main targets
help:
	@echo "Usage: make [target]"
	@echo "  target is:"
	@echo "    dep                  - Загрузка и одновление зависимостей проекта"
	@echo "    gen                  - Кодогенерация с использованием go generate"
	@echo "    build                - Компиляция приложения"
	@echo "    run                  - Запуск приложения в продакшн режиме"
	@echo "    dev                  - Запуск приложения в режиме разработки"
	@echo "    kill                 - Отправка приложению сигнала kill -HUP, используется в случае зависания"
	@echo "    m-[driver]-[command] - Работа с миграциями базы данных"
	@echo "                           Используемые базы данных (driver) описываются в файле .env"
	@echo "                           Доступные драйвера баз данных: mysql clickhouse sqlite3 postgres redshift tidb"
	@echo "                           Доступные команды: up, down, create, status, redo, version"
	@echo "                           Пример команд при включённой базе данных mysql:"
	@echo "                             make m-mysql-up      - примернение миграций до самой последней версии"
	@echo "                             make m-mysql-down    - отмена последней миграции"
	@echo "                             make m-mysql-create  - создание нового файла миграции"
	@echo "                             make m-mysql-status  - статус всех миграций базы данных"
	@echo "                             make m-mysql-redo    - отмена и повторное применение последней миграции"
	@echo "                             make m-mysql-version - отображение версии базы данных (применённой миграции)"
	@echo "                           Подробная информаци по командам доступна в документации утилиты gsmigrate"
	@echo "    version              - Вывод на экран версии приложения"
	@echo "    rpm                  - Создание RPM пакета"
	@echo "    bench                - Запуск тестов производительности проекта"
	@echo "    test                 - Запуск тестов проекта"
	@echo "    cover                - Запуск тестов проекта с отображением процента покрытия кода тестами"
	@echo "    lint                 - Запуск проверки кода с помощью gometalinter"
	@echo "    clean                - Очистка папки проекта от временных файлов"
.PHONY: help
