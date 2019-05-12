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

win32:CONFIG( release, debug|release ) {
    # deploy on release only
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/release/$${TARGET}$${TARGET_CUSTOM_EXT}))

    defineReplace(deploycmds) {
        in = $$1
        dirs = $$eval($$in)
        cmd =
        for(dir, $$1) {
            cmd += windeployqt --no-system-d3d-compiler --no-angle --no-opengl-sw --dir $$shell_quote($$shell_path($${dir})) --qmldir $${PWD} $${DEPLOY_TARGET} &
            cmd += copy $${DEPLOY_TARGET} $$shell_quote($$shell_path($${dir})) &
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
    QMAKE_CLEAN += $$deployexecs(DEPLOY_DIRS)
    QMAKE_POST_LINK += $$deploycmds(DEPLOY_DIRS)
}

macx:CONFIG( release, debug|release ) {
    # deploy on release only
    DEPLOY_TARGET = $$shell_quote($$shell_path($${OUT_PWD}/$${TARGET}$${TARGET_CUSTOM_EXT}))

    defineReplace(deploycmds) {
        in = $$1
        dirs = $$eval($$in)
        cmd =
        for(dir, $$1) {
            cmd += macdeployqt $${DEPLOY_TARGET} -always-overwrite -qmldir=$$shell_quote($$shell_path($${PWD})) &&
            cmd += mkdir -p $$shell_quote($$shell_path($${dir})) &&
            cmd += cp -a $${DEPLOY_TARGET} $$shell_quote($$shell_path($${dir})) &&
        }
        cmd += echo
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
    QMAKE_CLEAN += $$deployexecs(DEPLOY_DIRS)
    QMAKE_POST_LINK += $$deploycmds(DEPLOY_DIRS)
}
