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
}
else {
    COPY_COMMAND = cp
}

CONFIG( debug, debug|release ) {
    # debug
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/debug/$${TARGET}$${TARGET_CUSTOM_EXT}))
    DEPLOY_DIR = $$shell_quote($$shell_path($${OUT_PWD}/debug/deploy))
} else {
    # release
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/release/$${TARGET}$${TARGET_CUSTOM_EXT}))
    DEPLOY_DIR = $$shell_quote($$shell_path($${OUT_PWD}/release/deploy))
}

win32 | macx {
    QMAKE_POST_LINK += $${DEPLOY_COMMAND} --dir $${DEPLOY_DIR} --qmldir $${PWD} $${DEPLOY_TARGET} &
    QMAKE_POST_LINK += $${COPY_COMMAND} $${DEPLOY_TARGET} $${DEPLOY_DIR}
}