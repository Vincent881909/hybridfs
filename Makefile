CXX         := g++
CXX_FLAGS   := -Wall -Wextra -std=c++17 -D_FILE_OFFSET_BITS=64 -fsanitize=address -ggdb -I/usr/include/fuse3 -DFUSE_USE_VERSION=31
BIN         := bin
SRC         := src
INCLUDE     := include
LIBRARIES   := -L/usr/lib/aarch64-linux-gnu -lfuse3
EXECUTABLE  := hybridfs

MOUNTPOINT   := mntdir
METADATA_DIR := metadir
DATA_DIR     := datadir

SOURCES     := $(wildcard $(SRC)/*.cpp)
OBJECTS     := $(SOURCES:$(SRC)/%.cpp=$(BIN)/%.o)
DEPENDENCIES:= $(OBJECTS:.o=.d)

ROCKSDB_DIR := /home/parallels/Developer/rocksdb
ROCKSDB_LIB := $(ROCKSDB_DIR)/librocksdb.a
COMPRESSION_LIB := -lsnappy -lgflags -lz -lbz2 -llz4 -lzstd -lpthread -lrt -ldl

all: $(BIN)/$(EXECUTABLE)

run: $(BIN)/$(EXECUTABLE)
	./$< $(MOUNTPOINT) $(METADATA_DIR) $(DATA_DIR)

run_debug: $(BIN)/$(EXECUTABLE)_debug
	./$< $(MOUNTPOINT) $(METADATA_DIR) $(DATA_DIR)

$(BIN)/$(EXECUTABLE): $(OBJECTS) $(ROCKSDB_LIB)
	$(CXX) $(CXX_FLAGS) -I$(INCLUDE) $^ -o $@ $(LIBRARIES) $(COMPRESSION_LIB)

$(BIN)/$(EXECUTABLE)_debug: $(OBJECTS:.o=_debug.o) $(ROCKSDB_LIB)
	$(CXX) $(CXX_FLAGS) -DDEBUG -I$(INCLUDE) $^ -o $@ $(LIBRARIES) $(COMPRESSION_LIB)

-include $(DEPENDENCIES)

$(BIN)/%.o: $(SRC)/%.cpp
	$(CXX) $(CXX_FLAGS) -I$(INCLUDE) -MMD -MP -c $< -o $@

$(BIN)/%_debug.o: $(SRC)/%.cpp
	$(CXX) $(CXX_FLAGS) -DDEBUG -I$(INCLUDE) -MMD -MP -c $< -o $@

clean:
	-rm -f $(BIN)/*.o $(BIN)/*_debug.o $(BIN)/$(EXECUTABLE) $(BIN)/$(EXECUTABLE)_debug $(DEPENDENCIES) $(ROCKSDB_LIB)

$(ROCKSDB_LIB):
	cd $(ROCKSDB_DIR) && $(MAKE) static_lib

.PHONY: benchmark1 benchmark2 benchmark3 benchmark4 benchmark5 all_benchmarks
benchmark1:
	sudo filebench -f workloads/deletefiles.f

benchmark2:
	sudo filebench -f workloads/listdirs.f

benchmark3:
	sudo filebench -f workloads/statfiles.f

benchmark4:
	sudo filebench -f workloads/makedirs.f

benchmark5:
	sudo filebench -f workloads/removedirs.f

all_benchmarks: benchmark1 benchmark2 benchmark3 benchmark4 benchmark5
