#!/usr/bin/xcrun make -f

prefix ?= /usr/local
bindir = $(prefix)/bin

SWIFT_VERSION = 5.1.3

build: clean
#It seens there is an error with swift complier if I set the configuration param to release...
	swift build -c release --disable-sandbox

clean:
	swift package clean

install: build
	install ".build/release/facepp-cli" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/facepp-cli"

init:
	- swiftenv install $(SWIFT_VERSION)
	swiftenv local $(SWIFT_VERSION)
ifeq ($(UNAME), Linux)
	cd /vagrant && \
	  git clone --recursive -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && \
	  cd swift-corelibs-libdispatch && \
	  sh ./autogen.sh && \
	  ./configure --with-swift-toolchain=/home/vagrant/swiftenv/versions/$(SWIFT_VERSION)/usr \
	    --prefix=/home/vagrant/swiftenv/versions/$(SWIFT_VERSION)/usr && \
	  make && make install
endif
	
distclean:
	rm -rf .build
	swift package clean	

.PHONY: build install uninstall distclean