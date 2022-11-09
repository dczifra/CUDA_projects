extern "C"{

#include <pthread.h>
#include "../external/forest.h"

struct ThreadArgs{
    
    unsigned int thread_id;
    unsigned int num_threads;
    unsigned int n_estimators;

    double **data;
    const struct dim *csv_dim;

    const ModelContext *ctx;
    const RandomForestParameters *params;
    const DecisionTreeNode **random_forest;
    long int nodeId;
};

struct Args{
    int* arr;
    ThreadArgs* args;
    int a,b;
};

void init_ThreadArgs(
    ThreadArgs* t,
    double **_data,
    const RandomForestParameters *_params,
    const struct dim *_csv_dim,
    const ModelContext *_ctx,
    unsigned int thread_id,
    unsigned int num_threads)
{
    t->data= _data;
    t->params=_params;
    t->csv_dim=_csv_dim;
    t->ctx=_ctx;
    t->nodeId = 5;
    t->thread_id = thread_id;
    t->num_threads = num_threads;
}

//Args args;
//int arr[10];
//arr[0]=1;
//arr[1]=10;
//args.a = 11;
//args.b = 12;
//args.arr = &arr[0];
//args.args = &(thread_args[i]);
//pthread_create(&(thread_ids[i]), NULL, thread_func2, &args);
void* thread_func2(void* _args){
    struct Args* t = (struct Args*) _args;
    printf("%d %d %d %d\n", t->a, t->b, t->arr[0], t->arr[1]);
    printf("%d\n",(unsigned int) t->args->nodeId);
    return NULL;
}

    
void* thread_func(void* _args){
    struct ThreadArgs* t_args = (struct ThreadArgs*) _args;
    //printf("Thread: %d %d %d\n", t_args->num_threads, t_args->thread_id, t_args->nodeId);
    for (size_t i = 0; i < t_args->n_estimators; ++i){
        if((i%t_args->num_threads) == t_args->thread_id){
            t_args->random_forest[i] = train_model_tree(t_args->data, t_args->params, t_args->csv_dim, &t_args->nodeId, t_args->ctx);
            printf("\rTree created %d", (int)i);
            fflush(stdout);
        }
    }
    //printf(" ==> Thread done\n");
    return NULL;
}

const DecisionTreeNode **train_model_parallel(double **data,
                                        const RandomForestParameters *params,
                                        const struct dim *csv_dim,
                                        const ModelContext *ctx,
                                        unsigned int num_threads)
{
    // === Create the array of trained trees ===
    const DecisionTreeNode **random_forest = (const DecisionTreeNode **)
        malloc(sizeof(DecisionTreeNode *) * params->n_estimators);

    pthread_t thread_ids[num_threads];
    ThreadArgs thread_args[num_threads];

    // === Train the trees parallel ===
    for (size_t i = 0; i < num_threads; ++i){
        // Init thread args
        init_ThreadArgs(&thread_args[i], data, params, csv_dim, ctx, i, num_threads);
        thread_args[i].random_forest = random_forest;
        thread_args[i].n_estimators = params->n_estimators;
        //printf("Loop: %d %d %d %d\n", i, thread_args[i].num_threads, thread_args[i].n_estimators, thread_args[i].nodeId);
        
        pthread_create(&(thread_ids[i]), NULL, thread_func, &thread_args[i]);
        //random_forest[i] = train_model_tree(data, params, csv_dim, &nodeId, ctx);
    }

    // === Join threads ===
    for(size_t thread_id = 0; thread_id < num_threads; ++thread_id){
        pthread_join(thread_ids[thread_id], NULL);
    }
    //pthread_exit(NULL);
    printf("\nThreads joined\n");

    return random_forest;
}
}