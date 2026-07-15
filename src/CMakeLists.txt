cmake_minimum_required(VERSION 3.14)
project(auto-apps VERSION 0.1.0 LANGUAGES CXX)

include(GNUInstallDirs)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(auto-app main.cpp)

install(
    TARGETS auto-app
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT bin
)
