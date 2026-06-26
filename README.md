# This repo is intended as an example installer
This repo is not intended to maintain parity with the [mdio-cpp](https://github.com/BrianMichell/mdio-cpp) repository.
It is largely a workaround for [this](https://github.com/google/tensorstore/issues/190) Tensorstore issue.

# Instructions
1. Clone this repo.
```bash
$ git clone https://github.com/BrianMichell/mdio-cpp-installer.git && cd mdio-cpp-installer
```
2. Select your installation directory.
3. Select a tag or branch from [mdio-cpp](https://github.com/BrianMichell/mdio-cpp) (defaults to update_tensorstore branch)
    - Adjust the number of jobs in `build_mdio.sh` to best fit your system.
4. Run the installer. This will generate a lot of output and could take some time.
```bash
$ ./install.sh [install_directory] [mdio_tag_or_branch]
```

NOTE: Peak memory usage was seen in excess of 20GB when using 8 cores during the build stage. Please ensure your system has sufficient memory.

# Linking

`INSTALLED_DIR` is the directory passed to `install.sh`. Two kinds of artifacts
are produced:

- `INSTALLED_DIR/lib` - aggregated shared libraries (`libtensorstore.so`,
  `libabsl.so`, and the third-party dependencies).
- `INSTALLED_DIR/lib/drivers` - static **registration** archives. Tensorstore
  registers drivers, codecs, kvstore backends, and context resources at
  static-init time, and those registrations do not survive a shared-library
  boundary ([Tensorstore #190](https://github.com/google/tensorstore/issues/190)),
  so the consuming binary must whole-archive them directly.

## Minimal example
```bash
g++ my_app.cc -std=c++17 -DMAX_NUM_SLICES=32 \
  -I$INSTALLED_DIR/include \
  -I$INSTALLED_DIR/include/tensorstore-src \
  -I$INSTALLED_DIR/include/absl-src \
  -I$INSTALLED_DIR/include/riegeli-src \
  -I$INSTALLED_DIR/include/nlohmann_json-src/include \
  -I$INSTALLED_DIR/include/nlohmann_json_schema_validator-src/src \
  -I$INSTALLED_DIR/include/half-src/include \
  -L$INSTALLED_DIR/lib -L$INSTALLED_DIR/lib/drivers \
  -Wl,-rpath,$INSTALLED_DIR/lib -Wl,-rpath,$INSTALLED_DIR/lib/drivers \
  -Wl,--whole-archive \
    -ltensorstore_driver_array \
    -ltensorstore_driver_auto \
    -ltensorstore_driver_json \
    -ltensorstore_driver_stack \
    -ltensorstore_driver_zarr_driver \
    -ltensorstore_driver_zarr_spec \
    -ltensorstore_driver_zarr_blosc_compressor \
    -ltensorstore_driver_zarr_bzip2_compressor \
    -ltensorstore_driver_zarr_zlib_compressor \
    -ltensorstore_driver_zarr_zstd_compressor \
    -ltensorstore_driver_zarr3_driver \
    -ltensorstore_driver_zarr3_codec_blosc \
    -ltensorstore_driver_zarr3_codec_bytes \
    -ltensorstore_driver_zarr3_codec_codec_chain_spec \
    -ltensorstore_driver_zarr3_codec_crc32c \
    -ltensorstore_driver_zarr3_codec_gzip \
    -ltensorstore_driver_zarr3_codec_sharding_indexed \
    -ltensorstore_driver_zarr3_codec_transpose \
    -ltensorstore_driver_zarr3_codec_zstd \
    -ltensorstore_internal_cache_cache_pool_resource \
    -ltensorstore_internal_data_copy_concurrency_resource \
    -ltensorstore_internal_file_io_concurrency_resource \
    -ltensorstore_internal_http_default_transport \
    -ltensorstore_internal_curl_curl_transport \
    -ltensorstore_kvstore_file \
    -ltensorstore_kvstore_file_file_resource \
    -ltensorstore_kvstore_gcs \
    -ltensorstore_kvstore_gcs_gcs_resource \
    -ltensorstore_kvstore_gcs_http \
    -ltensorstore_kvstore_gcs_http_gcs_resource \
    -ltensorstore_kvstore_s3 \
    -ltensorstore_kvstore_s3_aws_credentials_resource \
    -ltensorstore_kvstore_s3_s3_resource \
    -ltensorstore_kvstore \
    -ltensorstore_internal_cache_kvs_backed_chunk_cache \
    -ltensorstore_kvstore_zarr3_sharding_indexed \
  -Wl,--no-whole-archive \
  -lnlohmann_json_schema_validator \
  -ltensorstore \
  -labsl \
  -lblosc \
  -lbzip2 \
  -lzlib \
  -llz4 \
  -lsnappy \
  -lre2 \
  -lriegeli \
  -ltinyxml2 \
  -lzstd \
  -lbrotli \
  -lnghttp2 \
  -lcurl_lib \
  -lopenssl \
  -laws_libs \
  -lpthread -lm -ldl
```

Notes:
- The GCS (`kvstore_gcs*`) and S3 (`kvstore_s3*`) archives plus `tinyxml2`,
  `aws_libs`, `zstd`, `brotli`, `nghttp2`, and `curl_lib` are only needed for
  cloud object-store support; drop them for a file-only build.
- If you installed with `--curl`, an extra `libcurl.so` is produced; add `-lcurl`.

# Compiling
- This may be an incomplete list for compiling all components required for **MDIO**

## Includes
Headers are installed under `INSTALLED_DIR/include`. Each dependency keeps its
upstream source layout in a `<dep>-src/` subdirectory, so you must add an `-I`
for each one you use. For an **MDIO**/Tensorstore consumer the required set is:

- `INSTALLED_DIR/include` - `mdio/mdio.h` and the installed `nlohmann/json-schema.hpp`.
- `INSTALLED_DIR/include/tensorstore-src` - Tensorstore headers.
- `INSTALLED_DIR/include/absl-src` - Abseil headers.
- `INSTALLED_DIR/include/riegeli-src` - Riegeli headers.
- `INSTALLED_DIR/include/nlohmann_json-src/include` - nlohmann/json (note the extra `/include`).
- `INSTALLED_DIR/include/nlohmann_json_schema_validator-src/src` - `nlohmann/json-schema.hpp` (pulled in by `mdio/dataset.h`).
- `INSTALLED_DIR/include/half-src/include` - half-float headers (note the extra `/include`).

`gtest-src` should not be included.

## Slicing flag
MDIO has a compile time flag limiting the number of runtime defined slices the methods can expect before returning an error status. The default limit is set to 32, but must be set by the user explicitly when using the installed version.

`-DMAX_NUM_SLICES=32`

# Reinstalling
Please remove any **MDIO** artifacts such as cloned repositories or built files from the **MDIO_installer** directory.
