# CUDA_projects
* Random forest source code from https://github.com/andriidski/random-forests-c

# Build
```
./bin/build.sh
```

# Run
C part:
```
./bin/main
```
CUDA (parallel) part
```
./bin/cuda
```

# Documentation
The *main.c* source file contains a simple Random Forest implementation, where with the given
parameters 85% accuracy can be achieved.

In the *main.cu* and *parallel/train.cu* source files this implementation is modified, such that
each Random Forest tree is computed on a different thread.
In this way, the same accuracy can be achieved by #thread times faster.