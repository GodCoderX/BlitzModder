ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = BlitzModder
BlitzModder_FILES = $(wildcard *.m) $(wildcard SVProgressHUD/*.m)
BlitzModder_FRAMEWORKS = UIKit CoreGraphics QuartzCore WebKit
#BlitzModder_PRIVATEFRAMEWORKS = CHDataStructures

export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk

before-package::
	@sh packager.sh
#after-install::
#	install.exec "uicache; killall -9 SpringBoard"
