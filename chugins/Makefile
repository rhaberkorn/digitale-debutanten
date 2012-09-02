CFLAGS ?= -O3

CFLAGS += -fPIC
CPPFLAGS += -I/usr/include/chuck -D__UNIX_JACK__ -D__LINUX_JACK__
CXXFLAGS += $(CFLAGS)

all : Clipper.chug GainMod.chug

%.chug : %.o
	$(CXX) -shared $(LDFLAGS) -o $@ $^

clean:
	$(RM) *.chug *.o
