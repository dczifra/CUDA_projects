gcc -o bin/main main.c \
    external/data.c external/forest.c external/tree.c external/utils.c external/eval.c


export PATH=/usr/local/cuda-10.0/bin:/usr/local/cuda/lib64/:$PATH

nvcc -o bin/cuda \
    -O3 -std=c++11 -lpthread -arch=sm_35  \
    main.cu parallel/train.cu \
    external/data.c external/forest.c external/tree.c external/utils.c external/eval.c
