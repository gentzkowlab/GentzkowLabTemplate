#!/bin/bash

# Check if local_env.sh exists
if [ ! -f "local_env.sh" ]; then
    echo "We cannot find 'local_env.sh'. Please run 'bash setup.sh' to set up the environment."
    exit 1
fi

# Check if pandas is installed
if ! pip show pandas &> /dev/null; then
    echo "Pandas is not installed. Installing now..."
    pip install -q pandas
fi

# Check if numpy is installed
if ! pip show numpy &> /dev/null; then
    echo "Numpy is not installed. Installing now..."
    pip install -q numpy
fi

# Check if matplotlib is installed
if ! pip show matplotlib &> /dev/null; then
    echo "Matplotlib is not installed. Installing now..."
    pip install -q matplotlib
fi

# Check if statsmodels is installed
if ! pip show statsmodels &> /dev/null; then
    echo "Statsmodels is not installed. Installing now..."
    pip install -q statsmodels
fi

# Add other checks as needed

