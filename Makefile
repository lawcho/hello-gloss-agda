.PHONY: build clean

# What should the executable be called?
OUT=a.out

# What file is the agda 'main' function in? What does MAlonzo mangle that module/path to?
MAIN_AGDA_PATH=src/Hello-Gloss.agda
MAIN_HS_MODULE=MAlonzo.Code.HelloZ45ZGloss
MAIN_HS_PATH=MAlonzo/Code/HelloZ45ZGloss.hs

# What Haskell packages does the program depend on, and which versions should stack download?
HASKELL_DEPS=base text gloss
STACK_RESOLVER=lts-19.31

# What file changes should trigger a re-build?
WATCH=src/

# Where should the intermadiate Haskell files go?
HS_BUILD_DIR=_build/generated-hs/

build: $(OUT)
clean:
	git clean -fdx

# Extract Haskell code from agda
$(HS_BUILD_DIR)/$(MAIN_HS_PATH): $(MAIN_AGDA_PATH) $(shell find $(WATCH))
	agda -c $<  --ghc-dont-call-ghc --compile-dir=$(HS_BUILD_DIR)

STACK_FILE=$(HS_BUILD_DIR)/stack.yaml
HPACK_FILE=$(HS_BUILD_DIR)/package.yaml

# Setup haskell build config files
$(HPACK_FILE) $(STACK_FILE): Makefile
	mkdir -p $(HS_BUILD_DIR)
	echo "resolver: $(STACK_RESOLVER)"                   >  $(STACK_FILE)
	echo "executables:"                                  >  $(HPACK_FILE)
	echo "  exe:"                                        >> $(HPACK_FILE)
	echo "    main-is: $(MAIN_HS_PATH)"                  >> $(HPACK_FILE)
	echo "    ghc-options: -main-is $(MAIN_HS_MODULE)"   >> $(HPACK_FILE)
	echo "    source-dirs: ."                            >> $(HPACK_FILE)
	echo "    dependencies:"                             >> $(HPACK_FILE)
	for dep in $(HASKELL_DEPS); do echo "    - $$dep"    >> $(HPACK_FILE); done

# Build executable with stack
$(HS_BUILD_DIR)/exe: $(HPACK_FILE) $(STACK_FILE) $(HS_BUILD_DIR)/$(MAIN_HS_PATH)
	cd $(HS_BUILD_DIR); stack install --local-bin-path=.

# Copy executable + make runnable
$(OUT): $(HS_BUILD_DIR)/exe
	chmod +x $<
	cp $< $@
