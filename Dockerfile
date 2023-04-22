FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04 as build
USER root
RUN apt update && apt dist-upgrade -y && apt install --no-install-recommends -y python3-venv python3-pip coinor-cbc wget git && rm -rf /var/lib/apt/lists/*
RUN useradd -m user

USER user
WORKDIR /home/user
ENV PIP_NO_CACHE_DIR=1

RUN mkdir -p /home/user/.local/bin
ENV PATH="/home/user/.local/bin:${PATH}"

# upgrade pip
RUN pip install --upgrade pip

# install cupy
RUN pip install cupy-cuda11x

# install alpa
RUN pip install alpa && \
    pip install jaxlib==0.3.22+cuda113.cudnn820 -f https://alpa-projects.github.io/wheels.html

# install together_worker
RUN pip install together_worker

# intall transformers_port
RUN pip install 'transformers@git+https://github.com/togethercomputer/transformers_port'

# install pytorch
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu118

# install flash attention
RUN pip install flash-attn

# install dependencies for alpa examples
RUN pip install fastapi uvicorn omegaconf jinja2 einops

# install alpa examples
RUN git clone --depth=1 https://github.com/alpa-projects/alpa && \
    pip install alpa/examples && \
    rm -r alpa

# install sentencepiece, accelerate, bitsandbytes
RUN pip install sentencepiece accelerate bitsandbytes

COPY . /home/user/app
RUN pip install /home/user/app

FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04
USER root

COPY --from=build /home/user /home/user
RUN apt update && apt dist-upgrade -y && apt install -y python3-venv python3-pip coinor-cbc wget git && rm -rf /var/lib/apt/lists/*
RUN useradd -m user

USER user
ENV PYTHONUNBUFFERED=1
