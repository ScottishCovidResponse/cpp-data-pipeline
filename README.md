
# C++ bindings for Python Data Pipeline API
[![SCRC C++ API (Linux)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_ubuntu.yml/badge.svg)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_ubuntu.yml)[![SCRC C++ API (macOS)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_mac.yml/badge.svg)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_mac.yml)[![SCRC C++ API (Windows)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_windows.yml/badge.svg)](https://github.com/ScottishCovidResponse/cpp-data-pipeline/actions/workflows/scrc_cpp_api_windows.yml)

[![codecov](https://codecov.io/gh/ScottishCovidResponse/cpp-data-pipeline/branch/master/graph/badge.svg?token=BNP8U30HVS)](https://codecov.io/gh/ScottishCovidResponse/cpp-data-pipeline)

This directory contains C++ bindings for the Python data pipeline API.

(See [DiRAC CSD3](#DiRAC_CSD3) for specific notes on installing on that machine.)

## Requirements

- Python 3.7 or greater with a working python3-config

- Create and activate a virtual environment for the required packages from the top-level repository directory:
  ```
  python3 -m venv .venv
  source .venv/bin/activate
  ```

- CMake will fetch and install all other requirements.

## Building the C++ wrapper library

```
cmake . -Bbuild
cmake --build build
```

## Run the C++ wrapper tests
The test binary can be found in the `build` folder after the build has completed:
```bash
./build/bin/datapipeline-tests
```

## Usage

Where possible the usage of the API in C++ mirrors that of Python however there are a few exceptions.

### Reading and Writing Distributions

Note that the procedure to read distributions is different to writing them. Due to the differences between C++ and Python, the retrieval method
converts the Python `scipy.stats` object to a simple class `Distribution` from which parameters can be extracted. The reason for this wrapper class is that some variables exist within the `kwargs` member of the `scipy.stats` object, whereas others exist within `args`, the class unpacks these to be a single set in a way that varies depending on the type of distribution received.

To retrieve a parameter that is a single value (i.e. not an array) use the `getParameter(<param_name>)` method:

```C++
DataPipeline* dat_pipe = new DataPipeline("/path/to/config.yaml", github_uri, version);

// Retrieve the parameter 'k' from the Gamma distribution 'example-distribution'
const double k = dat_pipe->read_distribution("parameter", "example-distribution").getParameter("k");
```

for parameters which are an array, use `getArrayParameter(<param_name>)` which returns a `std::vector<double>`:

```C++
// Retrieve the parameter 'p' from the Multinomial distribution 'example-distribution'
const std::vector<double> dat_pipe->read_distribution("parameter", "example-distribution").getArrayParameter("p");
```

Writing distributions is easy, the following functions return `pybind11::object`s which are then handed to the API:

```C++
Gamma(double k, double theta);

Normal(double mu, double sigma);

Poisson(double lambda);

Multinomial(double n, std::vector<double> p);

Uniform(double a, double b);

Beta(double alpha, double beta);

Binomial(int n, double p);
```

for example, to write a Poisson distribution named "my_dist":

```C++
dat_pipe->write_distribution("distribution", "my_dist", Poisson(5));
```

### Reading and Writing Parameters

Parameters are read and written in a manner identical to the Python API:

```C++
dat_pipe->read_estimate("parameter", "example-estimate");
dat_pipe->write_estimate("output-parameter", "example-estimate", 1.0);
```

### Reading and Writing Tables

Tables are read into a `Table` object which is a set of STL vectors representing columns. The columns can then be retrieved:

```C++
Table table = pDataPipeline_->read_table("object", "example-table");

std::vector<long> col_a = table.get_column<long>("a");
```

Tables are assembled using STL vectors also:

```C++
Table table;
const std::vector<std::string> _alpha = {"A", "B", "C", "D", "E", "F"};
const std::vector<double> _numero = {0.5, 2.2, 3.4, 4.6, 5.2, 6.1};
const std::vector<int> _id = {0,1,2,3,4,5};
table.add_column("ALPHA", _alpha);
table.add_column("NUMERO", _numero);
table.add_column("ID", _id);
pDataPipeline_->write_table("output-table", "example-table", table);
```

## Machine-specific notes

### DiRAC CSD3

Follow the above instructions, but be sure to run
```
module load python/3.7
```
first. The default python does not have python3-config, which is required for the compilation.

## Developer notes

- We have not been successful in running with Conda. The problem
  appears to be related to the provided Python being compiled with a
  different compiler than is used to build the C++ bindings.
