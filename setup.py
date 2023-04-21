from setuptools import setup, find_packages

setup(
    name='native_hf_model',
    version='0.0.1',
    url='https://github.com/togethercomputer/native_hf_model',
    author='Together Computer',
    author_email='support@together.xyz',
    description='This package runs native HF models on the together computer',
    packages=find_packages(),    
    scripts=['bin/serve_local_nlp_model']
    install_requires=['torch',
        'transformers',
        'together_worker',
        'loguru',
        'boto3',
        'sentencepiece']
)
