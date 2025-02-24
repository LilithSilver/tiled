import qbs 1.0
import qbs.Probes as Probes
import qbs.File
import qbs.Environment
import qbs.FileInfo

TiledPlugin {
    Depends { name: "Qt"; submodules: ["widgets"] }

    condition: {
        if (qbs.targetOS.contains("windows"))
            return File.exists(Environment.getEnv("PYTHONHOME"));

        return pkgConfigPython3Embed.found || pkgConfigPython3.found;
    }

    Probes.PkgConfigProbe {
        id: pkgConfigPython3
        name: "python3"
    }

    Probes.PkgConfigProbe {
        id: pkgConfigPython3Embed
        name: "python3-embed"
    }

    PythonProbe {
        id: pythonDllProbe
        pythonDir: Environment.getEnv("PYTHONHOME")
    }

    Properties {
        condition: pkgConfigPython3Embed.found || pkgConfigPython3.found
        cpp.cxxFlags: {
            var flags = pkgConfigPython3Embed.found ? pkgConfigPython3Embed.cflags : pkgConfigPython3.cflags
            if (qbs.toolchain.contains("gcc") && !qbs.toolchain.contains("clang"))
                flags.push("-Wno-cast-function-type")
            return flags
        }
        cpp.dynamicLibraries: pkgConfigPython3Embed.found ? pkgConfigPython3Embed.libraries : pkgConfigPython3.libraries
        cpp.libraryPaths: pkgConfigPython3Embed.found ? pkgConfigPython3Embed.libraryPaths : pkgConfigPython3.libraryPaths
        cpp.linkerFlags: pkgConfigPython3Embed.found ? pkgConfigPython3Embed.linkerFlags : pkgConfigPython3.linkerFlags
    }

    Properties {
        condition: qbs.targetOS.contains("windows") && !qbs.toolchain.contains("mingw")
        cpp.includePaths: [Environment.getEnv("PYTHONHOME") + "/include"]
        cpp.libraryPaths: [Environment.getEnv("PYTHONHOME") + "/libs"]
        cpp.dynamicLibraries: ["python3"]
    }

    Properties {
        condition: qbs.targetOS.contains("windows") && qbs.toolchain.contains("mingw")
        cpp.includePaths: [Environment.getEnv("PYTHONHOME") + "/include"]
        cpp.libraryPaths: [Environment.getEnv("PYTHONHOME") + "/libs"]
        cpp.dynamicLibraries: [FileInfo.joinPaths(Environment.getEnv("PYTHONHOME"), pythonDllProbe.fileNamePrefix + ".dll")]
    }

    files: [
        "plugin.json",
        "pythonplugin.cpp",
        "pythonplugin.h",
        "pythonbind.cpp",
        "qtbinding.py",
        "tiledbinding.py",
    ]
}
