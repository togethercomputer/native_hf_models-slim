FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-devel as build
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

# install build dependencies for alpa
RUN pip install cmake lit

# install alpa
RUN git clone --recursive https://github.com/alpa-projects/alpa.git                                && \
    cd /home/user/alpa && pip install ".[dev]"                                                     && \
    cd /home/user/alpa/build_jaxlib                                                                && \
    python build/build.py --enable_cuda                                                               \
        --bazel_options=--override_repository=org_tensorflow=$(pwd)/../third_party/tensorflow-alpa && \
    pip install /home/user/alpa/build_jaxlib/dist/jaxlib*.whl                                      && \
    cd /home/user/alpa/examples && pip install .                                                   && \
    cd /home/user && rm -rf alpa

# install csm_llmserve
COPY --chown=user:user . /home/user/csm_llmserve
RUN cd /home/user/csm_llmserve && pip install .

# install together_worker
RUN pip install together_worker

# intall transformers_port
RUN pip install 'transformers@git+https://github.com/togethercomputer/transformers_port'

FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-runtime
USER root
RUN apt update && apt install --no-install-recommends -y coinor-cbc && rm -rf /var/lib/apt/lists/*

RUN useradd -m user
USER user
WORKDIR /home/user

ENV LD_LIBRARY_PATH /usr/local/cuda-11.7/compat:$LD_LIBRARY_PATH
ENV PATH /home/user/.local/bin:$PATH

COPY --from=build /home/user/.local /home/user/.local
