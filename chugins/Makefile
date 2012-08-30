CFLAGS ?= -O3

CFLAGS += -m32
CPPFLAGS += -I/usr/include/chuck -D__LINUX_JACK__
LDFLAGS += -m32

CXXFLAGS += $(CFLAGS)

all : Clipper.chug

%.chug : %.o
	$(CXX) -shared $(LDFLAGS) -o $@ $^

clean:
	$(RM) *.chug *.o
