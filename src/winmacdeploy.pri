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

CONFIG( release, debug|release ) {
    # deploy on release only
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/release/$${TARGET}$${TARGET_CUSTOM_EXT}))

    defineReplace(deploycmds) {
        in = $$1
        dirs = $$eval($$in)
        cmd =
        for(dir, $$1) {
            cmd += $${DEPLOY_COMMAND} --dir $$shell_quote($$shell_path($${dir})) --qmldir $${PWD} $${DEPLOY_TARGET} &&
            cmd += $${COPY_COMMAND} $${DEPLOY_TARGET} $$shell_quote($$shell_path($${dir})) &&
            win32: cmd += $${COPY_COMMAND} $$shell_quote($$shell_path($${PWD}/../deploy/D3DCompiler_43.dll)) $$shell_quote($$shell_path($${dir})) &
        }
        return($$cmd)
    }

    defineReplace(deployexecs) {
        in = $$1
        dirs = $$eval($$in)
        execs =
        for(dir, $$1) {
            execs += $${dir}/$${TARGET}$${TARGET_CUSTOM_EXT}
        }
        return($$execs)
    }
    win32 | macx {
        QMAKE_CLEAN += $$deployexecs(DEPLOY_DIRS)
        QMAKE_POST_LINK += $$deploycmds(DEPLOY_DIRS)
    }
}
