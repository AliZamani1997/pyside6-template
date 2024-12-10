from cx_Freeze import setup, Executable


directory_table = [
    ("ProgramMenuFolder", "TARGETDIR", "."),
    ("MyProgramMenu", "ProgramMenuFolder", "MYPROG~1|My Program"),
]

msi_data = {
    "Directory": directory_table,
    "ProgId": [
        ("Prog.Id", None, None, "This is a description", "IconId", None),
    ],
    # "Icon": [
    #     ("IconId", "icon.ico"),
    # ],
}

bdist_msi_options = {
    "add_to_path": True,
    "data": msi_data,
    "environment_variables": [
        ("E_MYAPP_VAR", "=-*MYAPP_VAR", "1", "TARGETDIR")
    ],
    "upgrade_code": "{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}",
}


build_exe_options = {
    "excludes": ["tkinter", "unittest"],
    "zip_include_packages": ["encodings", "PySide6", "shiboken6"],
    "include_msvcr": True
}
executables = [
    Executable(
        "main.py",
        copyright="Copyright (C) 2024 myApp",
        base="gui",
        # icon="icon.ico",
        shortcut_name="My Program Name",
        shortcut_dir="MyProgramMenu",
        target_name="MyApp.exe",
    )
]

setup(
    name="MyApp",
    version="0.1",
    description="My GUI application!",
    executables=executables,
    options={
        "build_exe": build_exe_options,
        "bdist_msi": bdist_msi_options,
    },
)