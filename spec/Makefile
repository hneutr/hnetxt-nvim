SPEC=

RUN=nvim --headless -u spec.vim

.PHONY: all nvim test prepare

prepare:
	git submodule update --depth 1 --init
	luarocks install luacheck --local

nvim:
	@nvim --noplugin -u spec.vim

test:
ifeq ($(strip $(SPEC)),) # a.k.a. $(SPEC) is empty
	@$(RUN) -c "PlenaryBustedDirectory tests/ { minimal_init = 'spec.vim' }"
else
	@$(RUN) -c "PlenaryBustedFile $(SPEC)"
endif

all: prepare test
