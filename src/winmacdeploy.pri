isEmpty(TARGET_EXT) {
    win32 {
        TARGET_CUSTOM_EXT = .exe
    }
    macx {
        TARGET_CUSTOM_EXT = .app
    }
} else {
    TARGET_CUSTOM_EXT = $${TARGET_EXT}
}

win32: DEPLOY_COMMAND = windeployqt --no-system-d3d-compiler
macx: DEPLOY_COMMAND = macdeployqt
linux: DEPLOY_COMMAND = echo

win32 {
    COPY_COMMAND = copy
    QMAKE_DEL_FILE = del /s /f /q
}
else {
    COPY_COMMAND = cp
    QMAKE_DEL_FILE = rm -rf
}

CONFIG( release, debug|release ) {
    # deploy on release only
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/release/$${TARGET}$${TARGET_CUSTOM_EXT}))
    DEPLOY_DIR = $$shell_quote($$shell_path($${OUT_PWD}/../deploy))
    win32 | macx {
        QMAKE_CLEAN += $${DEPLOY_DIR}
        QMAKE_POST_LINK += $${DEPLOY_COMMAND} --dir $${DEPLOY_DIR} --qmldir $${PWD} $${DEPLOY_TARGET} &
        QMAKE_POST_LINK += $${COPY_COMMAND} $${DEPLOY_TARGET} $${DEPLOY_DIR}
    }
}
