FROM rocker/shiny-verse:4.0.2
#FROM rocker/rstudio

LABEL maintainer="Andres Quintero andres.quintero@bioquant.uni-heidelberg.de"

#RUN install2.r --error \
#    devtools


# from the tensorflow dockerfile: 
ARG USE_PYTHON_3_NOT_2=True
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8


# Install TensorFlow2
RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    libbz2-dev \
    liblzma-dev \
    git

RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which ${PYTHON}) /usr/local/bin/python 
RUN ${PIP} install tensorflow==2.2.0


# Download and install library
RUN R -e "install.packages(c('shinydashboard', 'shinyWidgets', 'shinyjs', 'RColorBrewer', 'cowplot', 'viridis'))"
RUN R -e "devtools::install_github('jokergoo/ComplexHeatmap')"
RUN R -e "devtools::install_github('hdsu-bioquant/ButcheR' )"



# copy the app to the image COPY shinyapps /srv/shiny-server/
RUN git clone https://github.com/hdsu-bioquant/ShinyButcheR.git
RUN mv ShinyButcheR/* /srv/shiny-server/
COPY .localtf /srv/shiny-server/

RUN chmod -R 755 /srv/shiny-server/


