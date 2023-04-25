FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-devel
USER root
RUN apt update && apt install --no-install-recommends -y coinor-cbc git cmake && rm -rf /var/lib/apt/lists/*

RUN useradd -m user

USER user
WORKDIR /home/user

ENV LD_LIBRARY_PATH /usr/local/cuda-11.7/compat:$LD_LIBRARY_PATH

ENV PATH /home/user/.local/bin:$PATH

# upgrade pip
RUN pip install --upgrade pip

# install cupy
RUN pip install cupy-cuda11x

# install dependencies for alpa
RUN pip install fastapi uvicorn omegaconf jinja2 einops cmake lit

# install alpa
RUN git clone --recursive https://github.com/alpa-projects/alpa.git && \
    cd /home/user/alpa && \
    pip install ".[dev]" && \
    cd /home/user/alpa/build_jaxlib && \
    python build/build.py --enable_cuda --bazel_options=--override_repository=org_tensorflow=$(pwd)/../third_party/tensorflow-alpa && \
    cd /home/user/alpa/build_jaxlib/dist && \
    pip install . && \
    cd /home/user/alpa/examples && \
    pip . && \
    cd /home/user/ && \
    rm -rf alpa

# install together_worker
RUN pip install together_worker

# intall transformers_port
RUN pip install 'transformers@git+https://github.com/togethercomputer/transformers_port'

# install flash attention
RUN pip install flash-attn

# install sentencepiece, accelerate, bitsandbytes
RUN pip install sentencepiece accelerate bitsandbytes
