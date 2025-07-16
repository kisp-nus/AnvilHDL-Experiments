VERILATOR_FLAGS ?= --top $(MODULE_NAME) -j 1
ANVILC ?= anvil
ANVIL_SRC_FILES=$(wildcard *.anvil)
ANVIL_HEADER_FILES=$(wildcard *.anvilh)
ANVIL_SV_TARGETS=$(patsubst %.anvil,../%.anvil.sv,$(ANVIL_SRC_FILES))
FLIST_FILE=../anvil.Flist

all: $(ANVIL_SV_TARGETS) $(FLIST_FILE)

.PHONY: run clean

ifdef LTOFF
    ANVIL_FLAGS ?= -disable-lt-checks
else
    ANVIL_FLAGS ?=
endif
ifdef VERBOSE
	ANVIL_FLAGS += -verbose
endif
	

build-%:%.anvil $(ANVIL_HEADER_FILES)
	$(ANVILC) $(ANVIL_FLAGS) $< > ../$<.sv
$(ANVIL_SV_TARGETS):../%.anvil.sv:%.anvil $(ANVIL_HEADER_FILES)
	$(ANVILC) $$(sed -n 's/.*anvil-flags:\(.*\)$$/\1/p' $<) $(ANVIL_FLAGS) $< > $@

$(FLIST_FILE):$(ANVIL_SRC_FILES)
	echo > $@
	for sv_file in $(ANVIL_SV_TARGETS); do \
		echo '$${CVA6_REPO_DIR}/core/anvil_build/'$${sv_file} >> $@; \
	done

clean:
	rm -rf $(ANVIL_SV_TARGETS) $(FLIST_FILE)
