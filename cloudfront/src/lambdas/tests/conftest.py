import sys
import os
import warnings


TEST_BASE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../") # noqa

sys.path.append(TEST_BASE_PATH)

warnings.filterwarnings("default")
