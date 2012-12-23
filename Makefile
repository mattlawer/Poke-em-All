include theos/makefiles/common.mk

TWEAK_NAME = Pokeemall
Pokeemall_FILES = Tweak.xm
Pokeemall_FRAMEWORKS = UIKit CoreData

include $(THEOS_MAKE_PATH)/tweak.mk
