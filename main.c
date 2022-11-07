#include <stdio.h>
#include <string.h>
#include <time.h>

#include "external/data.h"
#include "external/tree.h"
#include "external/eval.h"
#include "external/forest.h"

//#include "eval/eval.h"
//#include "utils/argparse.h"
//#include "utils/data.h"
//#include "utils/utils.h"

int main(int argc, char **argv){
    // === Random seed ===
    srand(0);
    //srand(time(NULL));

    // === Read csv file ===
    const char *file_name = "heart.csv";
    struct dim csv_dim;
    csv_dim = parse_csv_dims(file_name);
    // Allocate memory for the data coming from the .csv and read in the data.
    double *data = malloc(sizeof(double) * csv_dim.rows * csv_dim.cols);
    parse_csv(file_name, &data, csv_dim);

    const int k_folds = 1;
    // === Config random forest model ===
    const RandomForestParameters params = {
        n_estimators : 1000 /* Number of trees in the random forest model. */,
        max_depth : 7 /* Maximum depth of a tree in the model. */,
        min_samples_leaf : 3,
        max_features : 3
    };

    // Pivot the csv file data into a two dimensional array.
    double **pivoted_data;
    pivot_data(data, csv_dim, &pivoted_data);

    // Start the clock for timing.
    clock_t begin_clock = clock();

    double cv_accuracy = cross_validate(pivoted_data, &params, &csv_dim, k_folds);
    printf("cross validation accuracy: %f%% (%ld%%)\n",
           (cv_accuracy * 100),
           (long)(cv_accuracy * 100));

    // Record and output the time taken to run.
    clock_t end_clock = clock();
    printf("(time taken: %fs)\n", (double)(end_clock - begin_clock) / CLOCKS_PER_SEC);

    // Free loaded csv file data.
    free(data);
    free(pivoted_data);
}