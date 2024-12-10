# Copyright 2024
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PYTHON_DIR := invocation_directory() + '/' + if os_family() == 'windows' { '.venv/Scripts' } else { 'venv/bin' }
PYTHON := PYTHON_DIR + if os_family() == 'windows' { '/python.exe' } else { '/python3' }

#

TOOL_CLI_LRELEASE := PYTHON_DIR + '/pyside6-lrelease'
TOOL_CLI_LUPDATE := PYTHON_DIR + '/pyside6-lupdate'
TOOL_CLI_RCC := PYTHON_DIR + '/pyside6-rcc'
TOOL_CLI_QML_TESTRUNNER := 'qmltestrunner'

#

export QT_QPA_PLATFORM := 'offscreen'
export QT_QUICK_CONTROLS_MATERIAL_VARIANT := 'Dense'
export QT_QUICK_CONTROLS_STYLE := 'Material'

#####      #####
##### Names #####
#####      #####

NAME_DIRECTORY_BUILD := 'build'
NAME_DIRECTORY_BUILD_HELPERS := 'build-aux'
NAME_DIRECTORY_PY_SOURCES := 'myapp'
NAME_DIRECTORY_PY_TESTS := 'test'
NAME_FILE_GENERATED_RESOURCES := 'generated_resources.py'
NAME_FILE_MAIN_ENTRY := 'main.py'
NAME_DIRECTORY_GENERATED_SOURCES := 'src'
NAME_DIRECTORY_EXE := 'portable'
NAME_DIRECTORY_INSTALLER := 'installer'
NAME_FILE_FREEZE_ENTRY := 'freeze.py'
NAME_FILE_ICON := 'icon.ico'


#####                     #####
##### Existing Directories #####
#####                     #####

DIRECTORY_ROOT := invocation_directory()
DIRECTORY_BUILD_HELPERS := DIRECTORY_ROOT + '/' + NAME_DIRECTORY_BUILD_HELPERS
DIRECTORY_DATA := DIRECTORY_ROOT + '/data'
DIRECTORY_I18N := DIRECTORY_ROOT + '/i18n'
DIRECTORY_PY_SOURCES := DIRECTORY_ROOT + '/' + NAME_DIRECTORY_PY_SOURCES
DIRECTORY_PY_TESTS := DIRECTORY_ROOT + '/' + NAME_DIRECTORY_PY_TESTS
DIRECTORY_QML_SOURCES := DIRECTORY_ROOT + '/qml'
DIRECTORY_QML_TESTS := DIRECTORY_ROOT + '/qml'

#####               #####
##### Existing Files #####
#####               #####

FILE_APP_ENTRY := DIRECTORY_ROOT + '/' + NAME_FILE_MAIN_ENTRY
FILE_FREEZE_ENTRY := DIRECTORY_ROOT + '/' + NAME_FILE_FREEZE_ENTRY
FILE_ICON := DIRECTORY_ROOT + '/' + NAME_FILE_ICON

#####                      #####
##### Generated Directories #####
#####                      #####

DIRECTORY_BUILD := DIRECTORY_ROOT + '/' + NAME_DIRECTORY_BUILD

#

DIRECTORY_BUILD_QRC_DATA := DIRECTORY_BUILD + '/qrc-data'
DIRECTORY_BUILD_QRC_I18N := DIRECTORY_BUILD + '/qrc-i18n'
DIRECTORY_BUILD_QRC_QML := DIRECTORY_BUILD + '/qrc-qml'
DIRECTORY_BUILD_RESOURCES := DIRECTORY_BUILD + '/resources'
DIRECTORY_BUILD_TRANSLATIONS := DIRECTORY_BUILD + '/translations'
DIRECTORY_BUILD_RELEASE := DIRECTORY_BUILD + '/release'
DIRECTORY_BUILD_SOURCES := DIRECTORY_BUILD_RELEASE + '/' + NAME_DIRECTORY_GENERATED_SOURCES
DIRECTORY_BUILD_PY := DIRECTORY_BUILD_SOURCES + '/' + NAME_DIRECTORY_PY_SOURCES
DIRECTORY_BUILD_EXE := DIRECTORY_BUILD_RELEASE + '/' + NAME_DIRECTORY_EXE
DIRECTORY_BUILD_INSTALLER := DIRECTORY_BUILD_RELEASE + '/' + NAME_DIRECTORY_INSTALLER
#####                #####
##### Generated Files #####
#####                #####

FILE_BUILD_QRC_DATA := DIRECTORY_BUILD_QRC_DATA + '/data.qrc'
FILE_BUILD_QRC_I18N := DIRECTORY_BUILD_QRC_I18N + '/i18n.qrc'
FILE_BUILD_QRC_I18N_JSON := DIRECTORY_BUILD_QRC_I18N + '/myapp.json'
FILE_BUILD_QRC_QML := DIRECTORY_BUILD_QRC_QML + '/qml.qrc'
FILE_BUILD_RESOURCES := DIRECTORY_BUILD_RESOURCES + '/' + NAME_FILE_GENERATED_RESOURCES
FILE_BUILD_TRANSLATIONS_JSON := DIRECTORY_BUILD_TRANSLATIONS + '/myapp.json'
FILE_PY_SOURCES_RESOURCES := DIRECTORY_PY_SOURCES + '/' + NAME_FILE_GENERATED_RESOURCES
FILE_PY_TEST_RESOURCES := DIRECTORY_PY_TESTS + '/' + NAME_FILE_GENERATED_RESOURCES

_default:
    @just --list

# Build installer file into release/installer
[group('build')]
build-installer: build
    @rm -rf \
        {{ DIRECTORY_BUILD_INSTALLER }}
    @echo '{{DIRECTORY_BUILD_INSTALLER}} has been removed .'
    @rm -rf \
        {{ DIRECTORY_BUILD_EXE}}
    @echo '{{DIRECTORY_BUILD_EXE}} has been removed .'
    

    @cd {{ DIRECTORY_BUILD_SOURCES }}; \
        {{ PYTHON }} \
            {{NAME_FILE_FREEZE_ENTRY}} \
            bdist_msi \
            --bdist-dir {{ DIRECTORY_BUILD_EXE}} \
            --dist-dir {{ DIRECTORY_BUILD_INSTALLER }} 

    @echo ''; \
        echo 'Please find the finished installer file in {{ DIRECTORY_BUILD_INSTALLER }}'

# Build executable file into release/Exe
[group('build')]
build-exe: build
    @rm -rf \
        {{ DIRECTORY_BUILD_EXE }}
    @echo '{{DIRECTORY_BUILD_EXE}} has been removed .'
    @mkdir -p \
        {{ DIRECTORY_BUILD_EXE }}
    @echo '{{DIRECTORY_BUILD_EXE}} has been created .'

    @cd {{ DIRECTORY_BUILD_SOURCES }}; \
        {{ PYTHON }} \
            {{NAME_FILE_FREEZE_ENTRY}} \
            build_exe \
            --build-exe {{ DIRECTORY_BUILD_EXE }} 

    @echo ''; \
        echo 'Please find the finished executable file in {{ DIRECTORY_BUILD_EXE }}'
# Build full project into release/Src
[group('build')]
build: _check-pyside-setup _clean-build _clean-develop _compile-resources
    @rm -rf \
        {{ DIRECTORY_BUILD_SOURCES }}
    @echo '{{DIRECTORY_BUILD_SOURCES}} has been removed .'

    @mkdir -p \
        {{ DIRECTORY_BUILD_PY }}
    @echo '{{DIRECTORY_BUILD_PY}} has been created .'

    @cp -r \
        {{ DIRECTORY_PY_SOURCES }}/. \
        {{ DIRECTORY_BUILD_PY }}
    @echo '{{DIRECTORY_PY_SOURCES}} has been copied to {{ DIRECTORY_BUILD_PY }} .'

    @cp \
        {{ FILE_BUILD_RESOURCES }} \
        {{ DIRECTORY_BUILD_PY }}
    @echo '{{FILE_BUILD_RESOURCES}} has been copied to {{ DIRECTORY_BUILD_PY }} .'
    
    @cp \
        {{ FILE_FREEZE_ENTRY }} \
        {{ DIRECTORY_BUILD_SOURCES }}
    @echo '{{FILE_FREEZE_ENTRY}} has been copied to {{ DIRECTORY_BUILD_SOURCES }} .'

    @cp \
        {{ FILE_ICON }} \
        {{ DIRECTORY_BUILD_SOURCES }}
    @echo '{{FILE_ICON}} has been copied to {{ DIRECTORY_BUILD_SOURCES }} .'
    
    @cp \
        {{ FILE_APP_ENTRY }} \
        {{ DIRECTORY_BUILD_SOURCES }}
    @echo '{{FILE_APP_ENTRY}} has been copied to {{ DIRECTORY_BUILD_SOURCES }} .'
    
    @echo ''; \
        echo 'Please find the finished project in {{ DIRECTORY_BUILD_SOURCES }}'
        
# Build and compile resources into source directory
[group('build')]
build-develop: _check-pyside-setup _clean-develop _compile-resources
    @# Generates resources and copies them into the source directory
    @# This allows to develop/debug the project normally

    @cp \
    	{{ FILE_BUILD_RESOURCES }} {{ DIRECTORY_PY_SOURCES }}

# Remove ALL generated files
[group('build')]
clean: _clean-build _clean-develop _clean-test

# Add new language
[group('i18n')]
add-translation locale: _check-pyside-setup _prepare-translation-extractions
    @cd {{ DIRECTORY_BUILD_TRANSLATIONS }}; \
        {{ TOOL_CLI_LUPDATE }} \
            -verbose \
            -source-language en_US \
            -target-language {{ locale }} \
            -ts {{ DIRECTORY_I18N }}/{{ locale }}.ts
    @echo ''
    @just update-translations

# Update *.ts files by traversing the source code
[group('i18n')]
update-translations: _check-pyside-setup _clean-develop _prepare-translation-extractions
    @# Traverses *.qml and *.py files to update translation files
    @# Requires translations in .py:   QCoreApplication.translate("context", "string")
    @# Requires translations in .qml:  qsTranslate("context", "string")

    @cd {{ DIRECTORY_BUILD_TRANSLATIONS }}; \
    	{{ TOOL_CLI_LUPDATE }} \
    		-locations none \
    		-project {{ FILE_BUILD_TRANSLATIONS_JSON }}
    @cp -r \
    	{{ DIRECTORY_BUILD_TRANSLATIONS }}/i18n/*.ts \
    	{{ DIRECTORY_I18N }}

# Run Python and QML tests
[group('test')]
test: test-python test-qml

# Run Python tests
[group('test')]
test-python: _check-pyside-setup _clean-test _compile-resources
    @cp \
      {{ FILE_BUILD_RESOURCES }} \
      {{ FILE_PY_TEST_RESOURCES }}
    @{{ PYTHON }} -m \
    pytest test

# Run QML tests
[group('test')]
test-qml: _check-qml-setup
    @{{ TOOL_CLI_QML_TESTRUNNER }} \
        -silent \
        -input {{ DIRECTORY_QML_TESTS }}

_clean-build:
    @rm -rf \
    	{{ DIRECTORY_BUILD }}

_clean-develop:
    @rm -rf \
    	{{ FILE_PY_SOURCES_RESOURCES }}

_clean-test:
    @rm -rf \
    	{{ FILE_PY_TEST_RESOURCES }}

_check-pyside-setup:
    @echo "Checking Python installation..."  
    @which {{ PYTHON }}  
    @echo "Checking lupdate tool..."  
    @which {{ TOOL_CLI_LUPDATE }}  
    @echo "Checking lrelease tool..."  
    @which {{ TOOL_CLI_LRELEASE }}  
    @echo "Checking rcc tool..."  
    @which {{ TOOL_CLI_RCC }}  
    @echo 'All checks completed.'  

_check-qml-setup:
    @which {{ TOOL_CLI_QML_TESTRUNNER }}
    @echo ''

_compile-resources: _generate-qrc-data _generate-qrc-i18n _generate-qrc-qml
    @rm -rf \
    	{{ DIRECTORY_BUILD_RESOURCES }}
    @mkdir -p \
     	{{ DIRECTORY_BUILD_RESOURCES }}
    @cp -r \
    	{{ DIRECTORY_BUILD_QRC_QML }}/. \
     	{{ DIRECTORY_BUILD_QRC_DATA }}/. \
     	{{ DIRECTORY_BUILD_QRC_I18N }}/. \
     	{{ DIRECTORY_BUILD_RESOURCES }}
    @{{ TOOL_CLI_RCC }} \
    	{{ DIRECTORY_BUILD_RESOURCES }}/data.qrc \
    	{{ DIRECTORY_BUILD_RESOURCES }}/i18n.qrc \
    	{{ DIRECTORY_BUILD_RESOURCES }}/qml.qrc \
    	-o {{ FILE_BUILD_RESOURCES }}

_generate-qrc-data:
    @rm -rf \
    	{{ DIRECTORY_BUILD_QRC_DATA }}
    @mkdir -p \
    	{{ DIRECTORY_BUILD_QRC_DATA }}
    @cp -r \
    	{{ DIRECTORY_DATA }} \
    	{{ DIRECTORY_BUILD_QRC_DATA }}
    @cd \
    	{{ DIRECTORY_BUILD_QRC_DATA }}/data; \
    		{{ TOOL_CLI_RCC }} \
    			--project | sed 's,<file>./,<file>data/,' > {{ FILE_BUILD_QRC_DATA }}

_generate-qrc-i18n:
    @rm -rf \
    	{{ DIRECTORY_BUILD_QRC_I18N }}
    @mkdir -p \
    	{{ DIRECTORY_BUILD_QRC_I18N }}
    @cp -r \
    	{{ DIRECTORY_I18N }} {{ DIRECTORY_BUILD_QRC_I18N }}
    @{{ DIRECTORY_BUILD_HELPERS }}/generate-lupdate-project-file.py \
    	--relative-to {{ DIRECTORY_BUILD_QRC_I18N }} \
    	--out-file {{ FILE_BUILD_QRC_I18N_JSON }}
    @cd \
    	{{ DIRECTORY_BUILD_QRC_I18N }}; \
    		{{ TOOL_CLI_LRELEASE }} \
    			-project {{ FILE_BUILD_QRC_I18N_JSON }}
    @cd \
    	{{ DIRECTORY_BUILD_QRC_I18N }}/i18n; \
    		rm \
    			{{ FILE_BUILD_QRC_I18N_JSON }} \
    			*.ts
    @cd \
    	{{ DIRECTORY_BUILD_QRC_I18N }}/i18n; \
    		{{ TOOL_CLI_RCC }} \
    			--project | sed 's,<file>./,<file>i18n/,' > {{ FILE_BUILD_QRC_I18N }}

_generate-qrc-qml:
    @rm -rf \
    	{{ DIRECTORY_BUILD_QRC_QML }}
    @mkdir -p \
    	{{ DIRECTORY_BUILD_QRC_QML }}
    @cp -r \
    	{{ DIRECTORY_QML_SOURCES }} \
    	{{ DIRECTORY_BUILD_QRC_QML }}
    @cd {{ DIRECTORY_BUILD_QRC_QML }}; \
        mkdir qt && mv qml qt
    @cd \
        {{ DIRECTORY_BUILD_QRC_QML }}; \
            {{ TOOL_CLI_RCC }} --project \
                | sed 's,<file>./,<file>,' \
                | grep -v "<file>qml.qrc</file>" > {{ FILE_BUILD_QRC_QML }}

_prepare-translation-extractions:
    @rm -rf \
    	{{ DIRECTORY_BUILD_TRANSLATIONS }}
    @mkdir -p \
    	{{ DIRECTORY_BUILD_TRANSLATIONS }}
    @cp -r \
    	{{ DIRECTORY_I18N }} \
    	{{ DIRECTORY_PY_SOURCES }} \
    	{{ DIRECTORY_QML_SOURCES }} \
    	{{ DIRECTORY_BUILD_TRANSLATIONS }}
    @{{ DIRECTORY_BUILD_HELPERS }}/generate-lupdate-project-file.py \
    	--relative-to {{ DIRECTORY_BUILD_TRANSLATIONS }} \
    	--out-file {{ FILE_BUILD_TRANSLATIONS_JSON }}
