# This repo is intended as an example installer
This repo is not intended to maintain parity with the [mdio-cpp](https://github.com/TGSAI/mdio-cpp) repository.
It is largely a workaround for [this](https://github.com/google/tensorstore/issues/190) Tensorstore issue.

# Instructions
1. Clone this repo.
```bash
$ git clone https://github.com/BrianMichell/mdio-cpp-installer.git && git checkout IntelLLVM && cd mdio-cpp-installer
```
2. Select your installation directory.
3. Select a tag or branch from [mdio-cpp](https://github.com/TGSAI/mdio-cpp/releases)
    - Adjust the number of jobs in `build_mdio.sh` to best fit your system. 
4. Run the installer. This will generate a lot of output and could take some time.
```bash
$ ./install.sh [install_directory] [mdio_tag]
```

NOTE: Peak memory usage was seen in excess of 20GB when using 8 cores during the build stage. Please ensure your system has sufficient memory.

# Linking
- This may be an incomplete list for linking all components required for **MDIO**.
- It is expected that CURL is already installed on the system, so it will not be built and instead linked with `CURL_DIR`.
- `INSTALLED_DIR` is expected to be the same directory used from `install.sh`.
```
-Wl,-rpath,$(INSTALLED_DIR)/lib/drivers,-rpath,$(INSTALLED_DIR)/lib,--whole-archive,-L$(INSTALLED_DIR)/lib/drivers,-L$(INSTALLED_DIR)/lib,-lnlohmann_json_schema_validator,-ltensorstore_driver_zarr_bzip2_compressor,-ltensorstore_driver_zarr_driver,-ltensorstore_driver_zarr_spec,-ltensorstore_driver_zarr_zlib_compressor,-ltensorstore_driver_zarr_zstd_compressor,-ltensorstore_driver_zarr_blosc_compressor,-ltensorstore_kvstore_gcs_http,-ltensorstore_kvstore_gcs_gcs_resource,-ltensorstore_kvstore_gcs_validate,-ltensorstore_kvstore_gcs_http_gcs_resource,-ltensorstore_driver_json,-ltensorstore_internal_cache_cache_pool_resource,-ltensorstore_internal_data_copy_concurrency_resource,-ltensorstore_kvstore_file,-ltensorstore_internal_file_io_concurrency_resource,-ltensorstore_internal_cache_kvs_backed_chunk_cache,-labsl,-lblosc,-lre2,-ltensorstore,-lriegeli,$(CURL_DIR)/libcurl.so,-lopenssl
```

# Compiling
- This may be an incomplete list for compiling all components required for **MDIO**

## Includes
- Be sure your compile is aware of all the `INSTALLED_DIR/include` directories.
- Special cases are `nlohmann_json-src`, `half-src`, and `gtest-src`.
    - The `nlohmann_json-src` and `half-src` directories have an aditional `/include` directory.
        - `INSTALLED_DIR/include/nlohmann_json-src/include`
        - `INSTALLED_DIR/include/half-src/include`
    - `gtest-src` should not be included.

## Slicing flag
MDIO has a compile time flag limiting the number of runtime defined slices the methods can expect before returning an error status. The default limit is set to 32, but must be set by the user explicitly when using the installed version.

`-DMAX_NUM_SLICES=32`

# Reinstalling
Please remove any **MDIO** artifacts such as cloned repositories or built files from the **MDIO_installer** directory.