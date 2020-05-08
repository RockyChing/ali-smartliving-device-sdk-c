#
# Makefile for the project
#
# Author: RockyChing <zdh1021680772@163.com>

TARGET = ali_iot

SDK_VERSION := 1.3.0
SDK_SUMMARY := IoT Connectivity Devkit Running on Embedded Devices for Alibaba Cloud

ROOT_DIR := .
CONFIG_HOST := y

SRCDIRS  := .
SRCFIXS  := .c


ALI_DEFINES += \
    -D_PLATFORM_IS_LINUX_ \
    -D__UBUNTU_SDK_DEMO__ \

ALI_DEFINES += \
    -DFORCE_SSL_VERIFY \
    -DCOAP_SERV_MULTITHREAD \
    -DCOAP_SERV_MULTITHREAD \

ALI_DEFINES += \
    -DWITH_MQTT_DYN_BUF=1 \
    -DWITH_MEM_STATS=1 \
    -DWITH_MEM_STATS_PER_MODULE=1 \
    -DWITH_MQTT_JSON_FLOW=1 \
    -DWITH_MQTT_ZIP_TOPIC=1 \
    -DWITH_MQTT_SUB_SHORTCUT=1

ALI_DEFINES += \
    -DCONFIG_HTTP_AUTH_TIMEOUT=5000 \
    -DCONFIG_MID_HTTP_TIMEOUT=5000 \
    -DCONFIG_GUIDER_AUTH_TIMEOUT=10000 \
    -DCONFIG_MQTT_RX_MAXLEN=5000 \
    -DCONFIG_MBEDTLS_DEBUG_LEVEL=0 \

# ALI debug defines
ALI_DEFINES += \
    -DVERSION_REPORT_DEBUG

#####################################################################
# Process dependencies of configurations
#
# FEATURE_WIFI_PROVISION_ENABLED
# ALI_DEFINES += -DWIFI_PROVISION_ENABLED

# FEATURE_DEV_BIND_ENABLED
# ALI_DEFINES += -DDEV_BIND_ENABLED

# FEATURE_ALCS_ENABLED
# ALI_DEFINES += -DALCS_ENABLED

# FEATURE_COAP_COMM_ENABLED
# ALI_DEFINES += -DCOAP_COMM_ENABLED

# FEATURE_DEVICE_MODEL_GATEWAY
# ALI_DEFINES += -DDEVICE_MODEL_GATEWAY

# FEATURE_HTTP2_COMM_ENABLED
# ALI_DEFINES += -DHTTP2_COMM_ENABLED

# FEATURE_HTTP_COMM_ENABLED
ALI_DEFINES += -DHTTP_COMM_ENABLED

# FEATURE_MQTT_COMM_ENABLED
ALI_DEFINES += -DMQTT_COMM_ENABLED

# FEATURE_MQTT_DIRECT
ALI_DEFINES += -DMQTT_DIRECT

# FEATURE_MQTT_SHADOW
# ALI_DEFINES += -DMQTT_SHADOW

# FEATURE_OTA_ENABLED
# ALI_DEFINES += -DOTA_ENABLED

# FEATURE_DEVICE_MODEL_ENABLED
# ALI_DEFINES += -DDEVICE_MODEL_ENABLED

# FEATURE_SUPPORT_ITLS
# ALI_DEFINES += -DSUPPORT_ITLS

# FEATURE_SUPPORT_TLS
ALI_DEFINES += -DSUPPORT_TLS

ALI_INCLUDES += -I$(ROOT_DIR)/include \
   -I$(ROOT_DIR)/include/exports \
   -I$(ROOT_DIR)/include/imports \
   -I$(ROOT_DIR)/examples \
   -I$(ROOT_DIR)/src/infra/utils/misc \
   -I$(ROOT_DIR)/src/infra/utils \
   -I$(ROOT_DIR)/src/infra/log \
   -I$(ROOT_DIR)/src/infra/utils/digest \
   -I$(ROOT_DIR)/src/infra/system \
   -I$(ROOT_DIR)/src/ref-impl/hal/os/linux \
   -I$(ROOT_DIR)/src/ref-impl/tls/include \
   -I$(ROOT_DIR)/src/ref-impl/hal \
   -I$(ROOT_DIR)/src/infra/system \
   -I$(ROOT_DIR)/src/protocol/mqtt \
   -I$(ROOT_DIR)/src/protocol/mqtt \
   -I$(ROOT_DIR)/src/protocol/mqtt/client \

# APP entry
ALI_SRC_DIRS += $(ROOT_DIR)/examples
ALI_SRC_DIRS += $(ROOT_DIR)/examples/http


ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/utils
ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/utils/digest
ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/utils/misc
ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/log
ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/system
ALI_SRC_DIRS += $(ROOT_DIR)/src/infra/system/facility

ALI_SRC_DIRS += $(ROOT_DIR)/src/ref-impl/hal/os/linux
ALI_SRC_DIRS += $(ROOT_DIR)/src/ref-impl/hal/ssl/mbedtls
ALI_SRC_DIRS += $(ROOT_DIR)/src/ref-impl/tls/library

ALI_SRC_DIRS += $(ROOT_DIR)/src/sdk-impl

# FEATURE_HTTP_COMM_ENABLED
ALI_SRC_DIRS += $(ROOT_DIR)/src/protocol/http
# FEATURE_MQTT_COMM_ENABLED
ALI_SRC_DIRS += $(ROOT_DIR)/src/protocol/mqtt
ALI_SRC_DIRS += $(ROOT_DIR)/src/protocol/mqtt/client


SRCDIRS += $(ALI_SRC_DIRS)
SRCS := $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCFIXS))))
OBJS := $(patsubst %.c,%.o,$(SRCS))

# for debug
# $(warning source list $(SRCS))
# for debug
# $(warning objs list $(OBJS))

ifeq ($(CONFIG_HOST), n)
ifeq ($(CROSS_COMPILE), )
$(error "NO CROSS_COMPILE SPECIFIED!")
endif
endif

CC = $(CROSS_COMPILE)gcc
CPLUSPLUS = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)ld
AR = $(CROSS_COMPILE)ar cr
STRIP = $(CROSS_COMPILE)strip

# -Werror
CFLAGS = -O2 -Wall -Wno-unused-function
LIBS  := -lpthread -lrt -lm


LDFLAG += -Wl,-gc-sections
ifeq ($(CONFIG_HOST), n)
CFLAGS += -I$(OPENSSL_HDR_PATH)
CFLAGS += -mcpu=cortex-a35
LIBS += -L./lib -lmsmart
endif

CFLAGS += $(ALI_INCLUDES)
CFLAGS += $(ALI_DEFINES)


$(TARGET): $(OBJS)
	$(CC) $(LDFLAG) -o $@ $^ $(LIBS)
	$(STRIP) $@

# $(CPLUSPLUS) -c $(CFLAGS) -fpermissive -o $@ $<
%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

all: $(TARGET)

clean:
	rm -rf $(TARGET) $(OBJS) *.a *~

