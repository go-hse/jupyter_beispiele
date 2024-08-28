import sys
import nbformat
from nbconvert.preprocessors import ClearOutputPreprocessor

filepath = sys.argv[1]
print(filepath)

nb = nbformat.read(filepath, as_version=4)
ClearOutputPreprocessor().preprocess(nb, {}); 
nbformat.write(nb, filepath)
