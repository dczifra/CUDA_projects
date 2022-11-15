gcc -o bin/main main.c \
    external/data.c external/forest.c external/tree.c external/utils.c external/eval.c


export PATH=/usr/local/cuda-10.0/bin:/usr/local/cuda/lib64/:$PATH

#nvcc -o bin/cuda \
#    -O3 -lpthread -arch=sm_35  \
#    main.cu parallel/train.cu \
#    external/data.c external/forest.c external/tree.c external/utils.c external/eval.c


nvcc -o bin/GPU \
    -O3 -arch=sm_35  -lpthread -std=c++11\
    cuda_code/train.cu cuda_code/test.cu cuda_code/build_attribute_list.cu cuda_code/sample.cu cuda_code/split_point_find.cu cuda_code/split_lists.cu \
    cuda_code/main.cpp cuda_code/DecisionTree.cpp cuda_code/DataReader.cpp
