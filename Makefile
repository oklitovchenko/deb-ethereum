.PHONY: all build build-geth build-bsc build-polygon build-solc clean

ifndef ($(HOME))
    export HOME = /root
endif
export GOROOT = /usr/lib/go-1.16
export PATH := $(GOROOT)/bin:$(PATH)

all: clean
	$(MAKE) build

build: build-geth build-bsc build-polygon
	$(MAKE) -j2 build-solc

build-geth:
	mkdir geth-build
	$(MAKE) -C go-ethereum all
	cp $(PWD)/go-ethereum/build/bin/* $(PWD)/geth-build/

build-bsc:
	mkdir bsc-build
	$(MAKE) -C bsc all
	for f in $(PWD)/bsc/build/bin/*; do \
        n=`echo "$$f" | rev | cut -d'/' -f1 | rev`; \
        cp "$$f" "$(PWD)/bsc-build/bsc-$$n" || exit 1; \
    done

build-polygon:
	mkdir polygon-build
	$(MAKE) -C polygon all
	for f in $(PWD)/polygon/build/bin/*; do \
        n=`echo "$$f" | rev | cut -d'/' -f1 | rev`; \
        cp "$$f" "$(PWD)/polygon-build/polygon-$$n" || exit 1; \
    done

build-solc:
	mkdir solc-build
	echo "e5eed63a3e83d698d8657309fd371248945a1cda" > solidity/commit_hash.txt
	cd solc-build; cmake ../solidity; $(MAKE)

clean:
	rm -rf *-build
	rm -rf go-ethereum/build/bin
	rm -rf bsc/build/bin
	rm -rf polygon/build/bin
	cd go-ethereum; $(MAKE) clean
	cd bsc; $(MAKE) clean
	cd polygon; $(MAKE) clean
	cmake --build ./solidity --target clean || true
	rm -f solidity/commit_hash.txt