#include <stdio.h>
#include <string.h>
#include <time.h>

extern "C"{

#include "external/data.h"
#include "external/tree.h"
#include "external/eval.h"
#include "external/forest.h"

const DecisionTreeNode **train_model_parallel(double **data,
    const RandomForestParameters *params,
    const struct dim *csv_dim,
    const ModelContext *ctx,
    unsigned int num_threads);

double validate(
    double **data,
    const RandomForestParameters *params,
    const struct dim *csv_dim,
    const unsigned int procnum)
{
    const ModelContext ctx = (const ModelContext){
        testingFoldIdx : 0 /* Fold to use for evaluation. */,
        rowsPerFold : csv_dim->rows / 1 /* Number of rows per fold. */
    };
    const DecisionTreeNode **random_forest = (const DecisionTreeNode **)train_model_parallel(
        data, params, csv_dim, &ctx, procnum);
    
    //const DecisionTreeNode **random_forest = (const DecisionTreeNode **)train_model(
    //    data, params, csv_dim, &ctx);

    double accuracy = eval_model(
        random_forest, data, params, csv_dim, &ctx);
    
    free_random_forest(&random_forest, params->n_estimators);

    return accuracy;
}

int main(int argc, char **argv){
    int num_threads = 10;
    size_t num_trees = 1000;
    // === Random seed ===
    //srand(0);
    srand(time(NULL));

    // === Read and parse DATA ===
    const char *file_name = "heart.csv";
    struct dim csv_dim;
    csv_dim = parse_csv_dims(file_name);
    // Allocate memory for the data coming from the .csv and read in the data.
    double *data = (double*)malloc(sizeof(double) * csv_dim.rows * csv_dim.cols);
    parse_csv(file_name, &data, csv_dim);

    // === Config random forest model ===
    const RandomForestParameters params = {
        n_estimators : num_trees /* Number of trees in the random forest model. */,
        max_depth : 7 /* Maximum depth of a tree in the model. */,
        min_samples_leaf : 3,
        max_features : 3
    };

    // Pivot the csv file data into a two dimensional array.
    double **pivoted_data;
    pivot_data(data, csv_dim, &pivoted_data);

    // === Train and validation ===
    clock_t begin_clock = clock();
    double accuracy = validate(pivoted_data, &params, &csv_dim, num_threads);
    clock_t end_clock = clock();

    printf("cross validation accuracy: %f%% (%ld%%)\n", (accuracy * 100), (long)(accuracy * 100));
    printf("(time taken: %fs)\n", (double)(end_clock - begin_clock) / CLOCKS_PER_SEC);

    // Free loaded csv file data.
    free(data);
    free(pivoted_data);
}
}