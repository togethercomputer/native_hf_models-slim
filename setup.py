from setuptools import setup, find_packages

setup(
    name='csm_llmserve',
    version='0.0.1',
    url='https://github.com/togethercomputer/csm_llmserve',
    author='Together Computer',
    author_email='support@together.xyz',
    description='This package runs native HF models on the together computer',
    packages=find_packages(),    
    scripts=['bin/serves_local_nlp_model'],
    install_requires=['torch',
        'transformers',
        'together_worker',
        'loguru',
        'boto3',
        'sentencepiece'
        'accelerate'
        'bitsandbytes']
)
