DAEMON_NAME           = onvif_srvd
DAEMON_MAJOR_VERSION  = 1
DAEMON_MINOR_VERSION  = 1
DAEMON_PATCH_VERSION  = 0
DAEMON_PID_FILE_NAME  = $(DAEMON_NAME).pid
DAEMON_LOG_FILE_NAME  = $(DAEMON_NAME).log
DAEMON_NO_CHDIR       = 1
DAEMON_NO_CLOSE_STDIO = 0


GSOAP_VERSION     = 2.8.104
GSOAP_HASH        = 0199360d3f631720ad9846d96b08390c7ff8756d797239be1121b2a52ac0ffbe7df32b01444f8ea7a4aa1d836d9fa93cf5b2879708e93f7f07972fc6d4df92b1
GSOAP_INSTALL_DIR = ./gsoap-2.8
GSOAP_DIR         = $(GSOAP_INSTALL_DIR)/gsoap
GSOAP_CUSTOM_DIR  = $(GSOAP_DIR)/custom
GSOAP_PLUGIN_DIR  = $(GSOAP_DIR)/plugin
GSOAP_IMPORT_DIR  = $(GSOAP_DIR)/import
OPENSSL_DIR       = ./openssl
OPENSSL_VERSION   = 1.1.1s

SOAPCPP2          = $(GSOAP_DIR)/src/soapcpp2
WSDL2H            = $(GSOAP_DIR)/wsdl/wsdl2h
GSOAP_CONFIGURE   = --disable-c-locale


COMMON_DIR        = ./src
GENERATED_DIR     = ./generated


CXXFLAGS          = -DDAEMON_NAME='"$(DAEMON_NAME)"'
CXXFLAGS         += -DDAEMON_MAJOR_VERSION=$(DAEMON_MAJOR_VERSION)
CXXFLAGS         += -DDAEMON_MINOR_VERSION=$(DAEMON_MINOR_VERSION)
CXXFLAGS         += -DDAEMON_PATCH_VERSION=$(DAEMON_PATCH_VERSION)
CXXFLAGS         += -DDAEMON_PID_FILE_NAME='"$(DAEMON_PID_FILE_NAME)"'
CXXFLAGS         += -DDAEMON_LOG_FILE_NAME='"$(DAEMON_LOG_FILE_NAME)"'
CXXFLAGS         += -DDAEMON_NO_CHDIR=$(DAEMON_NO_CHDIR)
CXXFLAGS         += -DDAEMON_NO_CLOSE_STDIO=$(DAEMON_NO_CLOSE_STDIO)

CXXFLAGS         += -I$(COMMON_DIR)
CXXFLAGS         += -I$(GENERATED_DIR)
CXXFLAGS         += -I$(GSOAP_DIR) -I$(GSOAP_CUSTOM_DIR) -I$(GSOAP_PLUGIN_DIR) -I$(GSOAP_IMPORT_DIR)
CXXFLAGS         += -std=c++11 -Os -ffunction-sections -fdata-sections -Wall -pipe
CXXFLAGS         += -DWITH_NO_C_LOCALE -D_GLIBCXX_USE_NANOSLEEP

CXX              ?= g++





# To build a daemon with WS-Security support,
# call make with the WSSE_ON=1 parameter
# example:
# make WSSE_ON=1 all
ifdef WSSE_ON
CXXFLAGS        += -DWITH_OPENSSL -I$(OPENSSL_DIR)/include
LDFLAGS         += -Wl,--gc-sections openssl/libssl.a openssl/libcrypto.a -Llib -ldl -lpthread -lrt

WSSE_SOURCES     = $(GSOAP_PLUGIN_DIR)/wsseapi.c \
                   $(GSOAP_PLUGIN_DIR)/mecevp.c  \
                   $(GSOAP_PLUGIN_DIR)/smdevp.c  \
                   $(GSOAP_PLUGIN_DIR)/wsaapi.c

WSSE_IMPORT      = echo '\#import "wsse.h" ' >> $@
else
LDFLAGS          += -Wl,--gc-sections -Llib -ldl -lpthread -lrt
GSOAP_CONFIGURE += --disable-ssl
endif







SOAP_SRC = $(GSOAP_DIR)/stdsoap2.cpp            \
           $(GSOAP_DIR)/dom.cpp                 \
           $(GSOAP_CUSTOM_DIR)/duration.c       \
           $(GSOAP_CUSTOM_DIR)/struct_timeval.c



# We can't use wildcard func, this files will be generated
SOAP_SERVICE_SRC = $(GENERATED_DIR)/soapDeviceBindingService.cpp \
                   $(GENERATED_DIR)/soapMediaBindingService.cpp  \
                   $(GENERATED_DIR)/soapPTZBindingService.cpp



# Add your source files to the list.
# Supported *.c  *.cpp  *.S files.
# For other file types write a template rule for build, see below.
SOURCES  = $(COMMON_DIR)/daemon.c                         \
           $(COMMON_DIR)/$(DAEMON_NAME).cpp               \
           $(COMMON_DIR)/eth_dev_param.cpp                \
           $(COMMON_DIR)/ServiceContext.cpp               \
           $(COMMON_DIR)/ServiceDevice.cpp                \
           $(COMMON_DIR)/ServiceMedia.cpp                 \
           $(COMMON_DIR)/ServicePTZ.cpp                   \
           $(GENERATED_DIR)/soapC.cpp                     \
           $(SOAP_SRC)                                    \
           $(SOAP_SERVICE_SRC)                            \
           $(WSSE_SOURCES)






OBJECTS  := $(patsubst %.c,  %.o, $(SOURCES) )
OBJECTS  := $(patsubst %.cpp,%.o, $(OBJECTS) )
OBJECTS  := $(patsubst %.S,  %.o, $(OBJECTS) )


DEBUG_SUFFIX   = debug

DEBUG_OBJECTS := $(patsubst %.o, %_$(DEBUG_SUFFIX).o, $(OBJECTS) )




WSDL_FILES = $(wildcard wsdl/*.wsdl wsdl/*.xsd)




.PHONY: all
all: debug release



.PHONY: release
release: CXXFLAGS := -s  $(CXXFLAGS)
release: $(DAEMON_NAME)



.PHONY: debug
debug: DAEMON_NO_CLOSE_STDIO = 1
debug: CXXFLAGS := -DDEBUG  -g  $(CXXFLAGS)
debug: $(DAEMON_NAME)_$(DEBUG_SUFFIX)



# release
$(DAEMON_NAME): .depend $(OBJECTS)
	$(call build_bin, $(OBJECTS))


# debug
$(DAEMON_NAME)_$(DEBUG_SUFFIX): .depend $(DEBUG_OBJECTS)
	$(call build_bin, $(DEBUG_OBJECTS))



# Build release objects
%.o: %.c
	$(build_object)


%.o: %.cpp
	$(build_object)


%.o: %.S
	$(build_object)



# Build debug objects
%_$(DEBUG_SUFFIX).o: %.c
	$(build_object)


%_$(DEBUG_SUFFIX).o: %.cpp
	$(build_object)


%_$(DEBUG_SUFFIX).o: %.S
	$(build_object)



.PHONY: clean
clean:
	-@rm -f $(DAEMON_NAME)
	-@rm -f $(DAEMON_NAME)_$(DEBUG_SUFFIX)
	-@rm -f $(OBJECTS)
	-@rm -f $(DEBUG_OBJECTS)
	-@rm -f .depend
	-@rm -f -d -R $(GENERATED_DIR)
	-@rm -f *.*~



.PHONY: distclean
distclean: clean
	-@rm -f -d -R SDK
	-@rm -f -d -R $(GSOAP_INSTALL_DIR)
	-@rm -f RECV.log SENT.log TEST.log




.depend: $(GENERATED_DIR)/soapC.cpp
	-@rm -f .depend
	@echo "Generating dependencies..."
	@for src in $(SOURCES) ; do \
        echo "  [depend]  $$src" ; \
        $(CXX) $(CXXFLAGS) -MT ".depend $${src%.*}.o $${src%.*}_$(DEBUG_SUFFIX).o" -MM $$src >> .depend ; \
    done



ifeq "$(findstring $(MAKECMDGOALS),clean distclean)"  ""
    include $(wildcard .depend)
endif





# ---- gSOAP ----

$(GENERATED_DIR)/onvif.h:
	@$(build_openssl)
	@$(build_gsoap)
	@mkdir -p $(GENERATED_DIR)
	$(WSDL2H) -O4 -P -d -t ./wsdl/typemap.dat  -o $@  $(WSDL_FILES)
	$(WSSE_IMPORT)



$(GENERATED_DIR)/soapC.cpp: $(GENERATED_DIR)/onvif.h
	$(SOAPCPP2) -2 -j -L -x -S -d $(GENERATED_DIR) -I$(GSOAP_DIR):$(GSOAP_IMPORT_DIR) $<



# This targets is needed for parallel work of make
$(OBJECTS) $(DEBUG_OBJECTS) $(SOAP_SRC) $(SOAP_SERVICE_SRC) $(WSSE_SOURCES): $(GENERATED_DIR)/soapC.cpp




# Common commands
BUILD_ECHO = echo "\n  [build]  $@:"


define build_object
    @$(BUILD_ECHO)
    $(CXX) -c $< -o $@  $(CXXFLAGS)
endef



define build_bin
    @$(BUILD_ECHO)
    $(CXX)  $1 -o $@  $(CXXFLAGS) $(LDFLAGS)
    @echo "\n---- Compiled $@ ver $(DAEMON_MAJOR_VERSION).$(DAEMON_MINOR_VERSION).$(DAEMON_PATCH_VERSION) ----\n"
endef



define build_gsoap

    # get archive
    if [ ! -f SDK/gsoap.zip ]; then \
        mkdir -p SDK; \
        wget -O ./SDK/gsoap.zip.tmp \
        "https://src.fedoraproject.org/lookaside/extras/gsoap/gsoap_$(GSOAP_VERSION).zip/sha512/$(GSOAP_HASH)/gsoap_$(GSOAP_VERSION).zip" && \
        mv ./SDK/gsoap.zip.tmp ./SDK/gsoap.zip; \
    fi

    # unzip
    if [ ! -f $(GSOAP_INSTALL_DIR)/README.txt ]; then \
         unzip ./SDK/gsoap.zip; \
    fi

    # build
    if [ ! -f $(SOAPCPP2) ] || [ ! -f $(WSDL2H) ]; then \
         cd $(GSOAP_INSTALL_DIR); \
         unset CXX && ./configure $(GSOAP_CONFIGURE) && \
         make -j1; \
         cd ..;\
    fi
endef



define build_openssl

    # get archive
    if [ ! -f SDK/openssl-$(OPENSSL_VERSION).tar.gz ]; then \
        mkdir -p SDK; \
        wget -P ./SDK/ "https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz"; \
    fi

    # untar
    if [ ! -f openssl-$(OPENSSL_VERSION)/README ]; then \
        tar zxvf ./SDK/openssl-$(OPENSSL_VERSION).tar.gz; \
        ln -s ./openssl-$(OPENSSL_VERSION) ./openssl; \
    fi

    # build
    if [ ! -f openssl/libcrypto.so.${OPENSSL_VERSION:0:3} ] || [ ! -f openssl/libssl.so.${OPENSSL_VERSION:0:3} ]; then \
        cd openssl; \
        ./Configure linux-generic32 --cross-compile-prefix=arm-sonoff-linux-uclibcgnueabi- \
        CFLAGS="-Os -ffunction-sections -fdata-sections" \
        no-async no-shared no-weak-ssl-ciphers no-hw no-engine no-dso no-dtls no-srp no-sm2 no-psk no-tests && \
        make build_libs; \
        cd ..;\
    fi
endef



.PHONY: help
help:
	@echo "make [command]"
	@echo "command is:"
	@echo "   all       -  build daemon in release and debug mode"
	@echo "   debug     -  build in debug mode (#define DEBUG 1)"
	@echo "   release   -  build in release mode (strip)"
	@echo "   clean     -  remove all generated files"
	@echo "   distclean -  clean + remove all SDK files"
	@echo "   help      -  this help"

