.PHONY: all build-geth build-bsc build-polygon build-solc clean

ifndef ($(HOME))
    export HOME = /tmp
endif

all:
	clean
	$(MAKE) build-geth build-bsc build-polygon
	$(MAKE) build-solc

build-geth:
	mkdir geth-build
	$(MAKE) -C go-ethereum all
	cp go-ethereum/build/bin/* geth-build/

build-bsc:
	mkdir bsc-build
	$(MAKE) -C bsc all
	for f in bsc/build/bin/*; do \
        n=`echo "$$f" | rev | cut -d'/' -f1 | rev`; \
        cp -- "$$f" "bsc-build/bsc-$$n"; \
    done

build-polygon:
	mkdir polygon-build
	$(MAKE) -C polygon all
	for f in polygon/build/bin/*; do \
            n=`echo "$$f" | rev | cut -d'/' -f1 | rev`; \
            cp -- "$$f" "polygon-build/polygon-$$n"; \
        done

build-solc:
	mkdir solc-build
	cd solc-build; \
	    cmake ../solidity -DUSE_CVC4=OFF -DUSE_Z3=OFF; \
	    $(MAKE)

clean:
	rm -rf *-build
	rm -rf go-ethereum/build/bin
	rm -rf bsc/build/bin
	rm -rf polygon/build/bin
	cd go-ethereum; $(MAKE) clean
	cd bsc; $(MAKE) clean
	cd polygon; $(MAKE) clean
	cmake --build ./solidity --target clean || true
