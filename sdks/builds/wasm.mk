#emcc has lots of bash'isms
SHELL:=/bin/bash

WASM_RUNTIME_CONFIGURE_FLAGS = \
	--cache-file=$(TOP)/sdks/builds/wasm-runtime.config.cache \
	--prefix=$(TOP)/sdks/out/wasm-runtime \
	--disable-mcs-build \
	--disable-nls \
	--disable-boehm \
	--disable-btls \
	--with-lazy-gc-thread-creation=yes \
	--with-libgc=none \
	--disable-executables \
	--disable-support-build \
	--disable-visibility-hidden \
	--enable-maintainer-mode	\
	--enable-minimal=ssa,com,jit,reflection_emit_save,reflection_emit,portability,assembly_remapping,attach,verifier,full_messages,appdomains,security,sgen_marksweep_conc,sgen_split_nursery,sgen_gc_bridge,logging,remoting,shared_perfcounters,sgen_debug_helpers,soft_debug,interpreter \
	--host=wasm32 \
	--enable-llvm-runtime \
	--with-bitcode=yes

$(TOP)/sdks/builds/toolchains/emsdk:
	git clone https://github.com/juj/emsdk.git $(TOP)/sdks/builds/toolchains/emsdk

.stamp-wasm-toolchain: | $(TOP)/sdks/builds/toolchains/emsdk
	cd $(TOP)/sdks/builds/toolchains/emsdk && ./emsdk install sdk-1.37.36-64bit
	cd $(TOP)/sdks/builds/toolchains/emsdk && ./emsdk activate --embedded sdk-1.37.36-64bit
	touch $@

.stamp-wasm-runtime-toolchain: .stamp-wasm-toolchain
	touch $@

.stamp-wasm-runtime-configure: $(TOP)/configure
	mkdir -p $(TOP)/sdks/builds/wasm-runtime
	cd $(TOP)/sdks/builds/wasm-runtime && source $(TOP)/sdks/builds/toolchains/emsdk/emsdk_env.sh && CFLAGS="-Os -g" emconfigure $(TOP)/configure $(WASM_RUNTIME_CONFIGURE_FLAGS)
	touch $@

build-custom-wasm-runtime:
	source $(TOP)/sdks/builds/toolchains/emsdk/emsdk_env.sh && make -C wasm-runtime

.PHONY: package-wasm-runtime
package-wasm-runtime:
	$(MAKE) -C $(TOP)/sdks/builds/wasm-runtime/mono install

.PHONY: clean-wasm
clean-wasm:
	rm -rf .stamp-wasm-runtime-toolchain $(TOP)/sdks/builds/toolchains/emsdk

.PHONY: clean-wasm-runtime
clean-wasm-runtime: clean-wasm
	rm -rf .stamp-wasm-runtime-configure $(TOP)/sdks/builds/wasm-runtime $(TOP)/sdks/builds/wasm-runtime.config.cache $(TOP)/sdks/out/wasm-runtime

TARGETS += wasm-runtime

UNAME := $(shell uname -s)
ifeq ($(UNAME),Linux)
	CROSS_HOST=i386-unknown-linux
endif
ifeq ($(UNAME),Darwin)
	CROSS_HOST=i386-apple-darwin10
endif

WASM_CROSS_CONFIGURE_FLAGS = \
	--cache-file=$(TOP)/sdks/builds/wasm-cross.config.cache \
	--prefix=$(TOP)/sdks/out/wasm-cross \
	--host=$(CROSS_HOST)	\
	--target=wasm32	\
	--disable-mcs-build \
	--disable-nls \
	--disable-boehm \
	--disable-btls \
	--disable-support-build \
	--enable-maintainer-mode	\
	--enable-llvm	\
	--enable-minimal=appdomains,com,remoting

.stamp-wasm-cross-toolchain: .stamp-wasm-toolchain
	touch $@

.stamp-wasm-cross-configure: $(TOP)/configure
	mkdir -p $(TOP)/sdks/builds/wasm-cross
	cd $(TOP)/sdks/builds/wasm-cross && CFLAGS="-g" $(TOP)/configure $(WASM_CROSS_CONFIGURE_FLAGS)
	touch $@

.PHONY: package-wasm-cross
package-wasm-cross:
	$(MAKE) -C $(TOP)/sdks/builds/wasm-cross/mono install

.PHONY: clean-wasm-cross
clean-wasm-cross: clean-wasm
	rm -rf .stamp-wasm-aot-toolchain .stamp-wasm-cross-configure $(TOP)/sdks/builds/wasm-cross $(TOP)/sdks/builds/wasm-cross.config.cache $(TOP)/sdks/out/wasm-cross

TARGETS += wasm-cross
