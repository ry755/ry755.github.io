GEN_HTML = \
	index.html \
	retrochallenge/index.html \
	fox32/index.html

all: $(GEN_HTML)

%.html: %.tm.html
	awk -f preprocessor/preprocessor.awk < $< > $@

index.html: index.tm.html sidebar.sn.html
retrochallenge/index.html: retrochallenge/index.tm.html sidebar.sn.html
fox32/index.html: fox32/index.tm.html sidebar.sn.html

clean:
	rm -rf $(GEN_HTML)
