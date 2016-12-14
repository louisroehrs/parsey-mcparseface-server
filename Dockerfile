FROM java:8

ENV SYNTAXNETDIR=/opt/tensorflow PATH=$PATH:/root/bin

RUN mkdir -p $SYNTAXNETDIR \
    && cd $SYNTAXNETDIR \
    && apt-get update \
    && apt-get install git zlib1g-dev file swig python2.7 python-dev python-pip python-mock -y \
    && pip install --upgrade pip \
    && pip install -U protobuf==3.0.0 \
    && pip install asciitree \
    && pip install numpy \
    && wget https://github.com/bazelbuild/bazel/releases/download/0.3.1/bazel-0.3.1-installer-linux-x86_64.sh \
    && chmod +x bazel-0.3.1-installer-linux-x86_64.sh \
    && ./bazel-0.3.1-installer-linux-x86_64.sh --user \
    && git clone --recursive https://github.com/louisroehrs/models.git \
    && git clone --recursive https://github.com/louisroehrs/parsey-mcparseface-server.git \
    && cd $SYNTAXNETDIR/models/syntaxnet/tensorflow \
    && echo "\n\n\n\n" | ./configure \
    && apt-get autoremove -y \
    && apt-get clean

RUN cd $SYNTAXNETDIR/models/syntaxnet \
    && bazel --output_user_root=bazel_root test --genrule_strategy=standalone syntaxnet/... util/utf8/...

WORKDIR $SYNTAXNETDIR/models/syntaxnet

RUN [ "sh", "-c", "echo 'Bob brought the pizza to Alice.' | syntaxnet/demo.sh" ]

RUN pip install	flask && pip install multiprocessing
RUN cd $SYNTAXNETDIR && ls -al ./models/syntaxnet/bazel-bin && ls -al /opt/tensorflow/models/syntaxnet/bazel_root/5b21cea144c0077ae150bf0330ff61a0/execroot/syntaxnet/bazel-out/local-opt/bin/syntaxnet


RUN ls -al $SYNTAXNETDIR/models/syntaxnet/bazel-bin/syntaxnet/

## RUN $SYNTAXNETDIR/models/syntaxnet/bazel-bin/syntaxnet/parser_eval --input=stdin    --output=stdout-conll    --hidden_layer_sizes=64    --arg_prefix=brain_tagger    --graph_builder=structured    --task_context=syntaxnet/models/parsey_mcparseface/context.pbtxt    --model_path=syntaxnet/models/parsey_mcparseface/tagger-params    --slim_model    --batch_size=1024    --alsologtostderr

CMD    cd   $SYNTAXNETDIR/parsey-mcparseface-server && git pull origin   master && git checkout master  && cd $SYNTAXNETDIR && cp $SYNTAXNETDIR/parsey-mcparseface-server/* .   && cat server.py && python -m server   parser.py

