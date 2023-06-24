# https://habr.com/ru/articles/155467/
# https://habr.com/ru/articles/461817/

cmake_minimum_required(VERSION 3.13)
project(pipe VERSION 0.1)
get_directory_property(IS_SUBPROJECT PARENT_DIRECTORY)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/)

# Опции cmake
option(ON_MAIN "Включить сборку исполняемого файла для тестирования" OFF)

add_compile_options(
    # -Werror

    -Wall
    -Wextra
    -Wpedantic

    -Wcast-align
    -Wcast-qual
    -Wconversion
    # -Wctor-dtor-privacy
    -Wenum-compare
    -Wfloat-equal
    # -Wnon-virtual-dtor
    # -Wold-style-cast
    # -Woverloaded-virtual
    -Wredundant-decls
    -Wsign-conversion
    # -Wsign-promo
)
# Off extension чтобы полностью соответствовать стандарту языка C++
if(NOT CMAKE_CXX_EXTENSIONS)
    set(CMAKE_CXX_EXTENSIONS OFF)
endif()

# for extern lib
# add_library(netutil STATIC IMPORTED)
# set_property(TARGET netutil PROPERTY
#              IMPORTED_LOCATION Binary/game_client/libnetutil.a)

set(SOURCE_LIB pipe.cpp)			# Установка переменной со списком исходников для библиотеки
add_library(pipe STATIC ${SOURCE_LIB})	# Создание статической библиотеки с именем foo


if (ON_MAIN)
    set(SOURCE_EXE pipe_main.c)		# Установка переменной со списком исходников для исполняемого файла
  add_executable(pipe_main ${SOURCE_EXE}) # Создает исполняемый файл с именем pipe_main
  target_link_libraries(pipe_main pipe)		# Линковка программы с библиотекой
endif()