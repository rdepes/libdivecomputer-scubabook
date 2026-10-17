cmake_minimum_required(VERSION 3.22)
project(sb-dive-computer C)

# LIBDC_SRC: a cópia de fonte do libdivecomputer (sem modificação; ver ../libdivecomputer/ORIGEM.md)
if(NOT LIBDC_SRC)
  set(LIBDC_SRC "${CMAKE_CURRENT_SOURCE_DIR}/../libdivecomputer")
endif()

# ---- libdivecomputer.so (LGPL-2.1): biblioteca COMPARTILHADA separada, trocável por outra versão ----
file(GLOB LIBDC_SOURCES "${LIBDC_SRC}/src/*.c")
list(FILTER LIBDC_SOURCES EXCLUDE REGEX "serial_win32\\.c$")
add_library(divecomputer SHARED ${LIBDC_SOURCES})
target_include_directories(divecomputer PUBLIC "${LIBDC_SRC}/include" PRIVATE "${LIBDC_SRC}/src")
# o que o configure da biblioteca detectaria no Android (bionic): sem libusb, hidapi, bluez e IrDA
target_compile_definitions(divecomputer PRIVATE
  HAVE_PTHREAD_H=1 HAVE_UNISTD_H=1 HAVE_SYS_PARAM_H=1 HAVE_SYS_SOCKET_H=1
  HAVE_LINUX_SERIAL_H=1 HAVE_STRUCT_TM_TM_GMTOFF=1 HAVE_STRERROR_R=1
  HAVE_LOCALTIME_R=1 HAVE_GMTIME_R=1 HAVE_TIMEGM=1 HAVE_CLOCK_GETTIME=1)
target_compile_options(divecomputer PRIVATE -O2 -w -fvisibility=default)
target_link_libraries(divecomputer log)

# ---- libsbdivecomputer.so: o JNI do ScubaBook, que só usa a API pública dc_* ----
# no repositório público de re-link só existe a biblioteca: o JNI fica de fora quando a fonte não está aqui
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp/sb_dive_computer.c")
  add_library(sbdivecomputer SHARED src/main/cpp/sb_dive_computer.c)
  target_compile_options(sbdivecomputer PRIVATE -O2 -Wall)
  target_link_libraries(sbdivecomputer divecomputer log)
endif()
