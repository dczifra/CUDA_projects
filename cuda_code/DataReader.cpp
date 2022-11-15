#include <stdio.h>
#include <stdlib.h>

#include <iostream>

#include "DataReader.h"
#include "csv.h"

void DataReader::read(std::string filename) {
    // TODO: make this less hard-coded
    if(!filename.compare("heart.csv") ||
            !filename.compare("heart.csv")) {

        io::CSVReader<14> in(filename);
	in.read_header(io::ignore_extra_column, "age","sex","cp","trestbps","chol","fbs","restecg","thalach","exang","oldpeak","slope","ca","thal","target");
        double v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13;
        int y;
        while (in.read_row(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11,
			   v12, v13, y)) {
            data.push_back(v1);
            data.push_back(v2);
            data.push_back(v3);
            data.push_back(v4);
            data.push_back(v5);
            data.push_back(v6);
            data.push_back(v7);
            data.push_back(v8);
            data.push_back(v9);
            data.push_back(v10);
            data.push_back(v11);
            data.push_back(v12);
            data.push_back(v13);

            labels.push_back(y);
        }
        std::cout<<data.size()<<std::endl;

        n = 1025;
        p = 13;
    }
    else{
        std::cout<<"Could not find the input file"<<std::endl;
    }
}

int DataReader::get_n() {
    return p;
}

int DataReader::get_p() {
    return n;
}

double* DataReader::data_arr() {
    return &data[0];
}

int* DataReader::label_arr() {
    return &labels[0];
}
