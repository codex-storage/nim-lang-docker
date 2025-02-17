# Nim lang Docker images

## Description

 At Codex, we are using [Nim](https://nim-lang.org) programming language. Some of our projects are using pre-compiled Nim in Docker for Docker images to simplify and speed up the builds.

 Also, we are using multi-arch Docker images and for that it is required to have multi-arch source images and we have the following issues with that
 - :hourglass_flowing_sand: [Make Nim docker images official?](https://forum.nim-lang.org/t/9983)
 - :hourglass_flowing_sand: [Provide official docker image #515](https://github.com/nim-lang/RFCs/issues/515)
 - :x: [moigagoo/nimage](https://github.com/moigagoo/nimage) - Only amd64, outdated
 - :scroll: [theAkito/docker-nim](https://github.com/theAkito/docker-nim) - License, outdated
 - :hammer_and_wrench: [arm support for Linux #23](https://github.com/nim-lang/choosenim/issues/23)

 Code in the repository provides a simple way to build multi-arch Docker images with a required Nim version. However, builds are triggered manually.

 We are using GitHub Actions and rely on [nimv](https://github.com/emizzle/nimv) for Nim installation.


## Build your own images

 1. Fork the repository.
 2. Add GitHub Actions secrets - `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`.
 3. Adjust workflow with your repository name.
 4. Run workflow and pass required [Nim version](https://github.com/nim-lang/Nim/tags).


## Build manually

 [Multi-platform builds](https://docs.docker.com/build/building/multi-platform/)


### On separate VMs

<details>
<summary>Build guide</summary>

### Build Docker images on separate VMs

 1. Run `amd64`(`cx32` ,`cpx31`) and `arm64`(`cax21`) VMs on Hetzner

 2. Install Docker

 3. Clone repository
    ```shell
    git clone
    ```

 4. Define variables
    ```shell
    repository="codexstorage/nim-lang"
    nim_version="2.0.14"
    ```

 5. Run the build on each VM
    ```shell
    docker build \
      --tag nim-lang:"${nim_version}" \
      --build-arg NIM_VERSION="${nim_version}" \
      --file Dockerfile .
    ```

 6. Login to DockerHub
    ```shell
    docker login -u <username>
    ```

 7. Push image and get the digest on each VM
    ```shell
    docker image tag nim-lang:"${nim_version}" "${repository}:${nim_version}"

    docker image push ${repository}:${nim_version}
    ```

    We will get a digest for each image and we need to define appropriate variables
    ```shell
    amd64="sha256:43c1ea16d34528b3f195e18ca21f69987a01daaf0ddd5d94b252d37ebace2f5c"
    arm64="sha256:4b4b3d6617c9bc698adefd0a27d1d18c5236016b92ee7ddc8c42311586568d91"
    ```

 8. Create a manifest list for multi-arch image and push it from on one of the VM
    ```shell
    docker buildx imagetools create \
      -t "${repository}:${nim_version}" \
      "${amd64}" \
      "${arm64}"
    ```

Duration
| Platform | Build        | Push        | Size    |
| -------- | ------------ | ----------- | ------- |
| `amd64`  | `8m20.221s`  | `1m17.620s` | `659MB` |
| `arm64`  | `10m20.591s` | `0m48.888s` | `676MB` |

TOTAL: ~ `11m09s`

</details>


### On a single VM

<details>
<summary>Build guide</summary>

### Build Docker images on a single VM

 1. Run `amd64`(`cx32` ,`cpx31`) VM on Hetzner

 2. Install Docker

 3. Clone repository
    ```shell
    git clone
    ```

 4. Define variables
    ```shell
    repository="codexstorage/nim-lang"
    nim_version="2.0.14"
    ```

 5. Create a custom builder
   ```shell
   docker buildx create \
   --name container-builder \
   --driver docker-container \
   --bootstrap --use
   ```

 6. Login to DockerHub
    ```shell
    docker login -u <username>
    ```

 7. Run the build for multiple platforms
    ```shell
    docker buildx build \
      --tag "${repository}:${nim_version}" \
      --build-arg NIM_VERSION="${nim_version}" \
      --platform linux/amd64,linux/arm64 \
      --push \
      --file Dockerfile .
    ```

Duration
| Platform | Build        | Push        | Size    |
| -------- | ------------ | ----------- | ------- |
| `amd64`  | `-`          | `-`         | `613MB` |
| `arm64`  | `13m55.177s` | `0m42.444s` | `425MB` |

TOTAL: ~ `14m35s`

</details>


## Known issues

 1. We are using [nimv](https://github.com/emizzle/nimv) which requires bash, so alpine images will not work.
