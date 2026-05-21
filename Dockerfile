#Copyright 2020 Division of Medical Image Computing, German Cancer Research Center (DKFZ), Heidelberg, Germany
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

FROM nvcr.io/nvidia/pytorch:25.04-py3

ARG env_det_num_threads=6
ARG env_det_verbose=1

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    OMP_NUM_THREADS=1 \
    det_num_threads=${env_det_num_threads} \
    det_verbose=${env_det_verbose} \
    det_data=/opt/data \
    det_models=/opt/models \
    CUDA_HOME=/usr/local/cuda \
    PATH=/usr/local/cuda/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH \
    FORCE_CUDA=1

RUN apt-get update && apt-get install -y \
    python3-dev \
    build-essential \
    cmake \
    g++ \
    gcc \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade pip setuptools wheel scikit-build

WORKDIR /opt/code/nndet
COPY . .

RUN mkdir -p ${det_data} ${det_models}

RUN pip install --no-cache-dir -r requirements.txt \
  && pip install --no-cache-dir hydra-core --upgrade --pre \
  && pip install --no-cache-dir git+https://github.com/mibaumgartner/pytorch_model_summary.git

# --no-build-isolation ensures torch is on sys.path during setup.py / CUDA ext build
RUN pip install --no-cache-dir --no-build-isolation -v -e .
