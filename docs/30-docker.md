# Docker

The recipe to build the docker image is in the `Dockerfile`

## build docker image

To build the image with with octave and SPM the `Dockerfile` just type :

`docker build -t cpp_spm:0.0.1 .`

This will create an image with the tag name `cpp_spm_octave:0.0.1`

## run docker image

The following code would start the docker image and would map 2 folders one for
`output` and one for `code` you want to run.

```bash
docker run -it --rm \
-v [output_folder]:/output \
-v [code_folder]:/code cpp_spm:0.0.1
```

To test it you can copy the `batch_download_run.m` file in the `code` folder on
your computer and then start running the docker and type:

```bash
cd /code # to change to the code folder inside the container (running the command 'ls' should show only batch_download_run.m )
octave --no-gui --eval batch_download_run # to run the batch_download_run script
```
