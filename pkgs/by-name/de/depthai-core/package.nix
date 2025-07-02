{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  writeTextFile,
  backward-cpp,
  bzip2,
  catch2,
  cpr,
  curl,
  fp16,
  ghc_filesystem,
  libarchive,
  libnop,
  libusb1,
  nlohmann_json,
  opencv,
  pkg-config,
  python3,
  spdlog,
  xlink,
  xz,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "depthai-core";
  version = "2.30.0";

  src = fetchFromGitHub {
    owner = "luxonis";
    repo = "depthai-core";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-UWu9vtyLZsDetxIJkLJKa5BhQ5O1xli/HD3HT1tLuvM=";
    fetchSubmodules = true;
  };

  buildInputs = [
    backward-cpp
    bzip2.dev
    catch2
    cpr
    curl
    ghc_filesystem
    libarchive
    libusb1
    nlohmann_json
    opencv
    opencv.cxxdev
    spdlog
    xlink
    xz
    zlib
    python3
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];
  propagatedBuildInputs = [
    libnop
  ];

  patches = [./cmake_deps.patch];

  cmakeFlags =
    let
      inherit (lib) cmakeBool cmakeFeature concatStringsSep;
        assetFetcher = callPackage ./fetch-depthai-assets.nix { };
        ext = ".tar.xz";
        # from cmake/Depthai/DepthaiDeviceSideConfig.cmake and cmake/DepthaiDownloader.cmake
        firmwareBasename = "depthai-device-fwp";
        firmware = assetFetcher {
          inherit ext;
          subDir = "luxonis-myriad-snapshot-local/depthai-device-side";
          basename = firmwareBasename;
          rev = "a62b2ccb0bc493c2fb41694cb81c08887be24c52";
          sha256 = "sha256-njwp9WIq0OyEIsHx4hoHhbRAr+W3tl/PnmQ77OBgbZc=";
        };

        # from cmake/DepthaiBootloaderDownloader.cmake and cmake/Depthai/DepthaiBootloaderConfig.cmake
        bootloaderBasename = "depthai-bootloader-fwp";
        bootloader = assetFetcher {
          inherit ext;
          subDir = "luxonis-myriad-release-local/depthai-bootloader";
          basename = bootloaderBasename;
          rev = "0.0.28";
          sha256 = "sha256-5xQ7vj0BLt2dgZQKC+Ug6BVkcIt7TsebBx1wF1i7gow=";
        };
    in
    [
      (cmakeBool "HUNTER_ENABLED" false)
      (cmakeBool "DEPTHAI_ENABLE_BACKWARD" false)
      (cmakeFeature "FP16_DIR"
        (toString writeTextFile {
                name = "FP16Config";
                text = ''
                  if(NOT TARGET FP16::fp16)
                    add_library(FP16::fp16 INTERFACE IMPORTED)
                    target_include_directories(FP16::fp16 INTERFACE "${fp16}/include")
                  endif()
                '';
                destination = "/FP16Config.cmake";
              }
        )
      )
      (cmakeFeature "libnop_DIR"
        (toString writeTextFile {
              name = "libnop-config";
              text = ''
                add_library(libnop INTERFACE IMPORTED)
                target_include_directories(libnop INTERFACE "${libnop}/include")
              '';
              destination = "/libnopConfig.cmake";
        })
      )
      (cmakeBool "DEPTHAI_ENABLE_CURL" false) # only used for telemetry and zoo
      (cmakeBool "CMAKE_SKIP_INSTALL_ALL_DEPENDENCY" true)
      (cmakeFeature "CMAKE_INSTALL_PREFIX" "${placeholder "out"}")
      (cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
      (cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
      (cmakeBool "BUILD_SHARED_LIBS" true)
      (cmakeBool "CMAKE_FIND_NO_INSTALL_PREFIX" true)
      (cmakeFeature "DEPTHAI_BOOTLOADER_FWP" "${bootloader}")
      (cmakeFeature "DEPTHAI_DEVICE_FWP" "${firmware}")
      (cmakeFeature "CMAKE_MODULE_PATH" (
        concatStringsSep ";" [
          "${xlink}/lib/cmake"
          "${libnop}/lib/cmake"
        ]
      ))
    ];

  meta = {
    description = "DepthAI core is a C++ library which comes with firmware and an API to interact with OAK Platform";
    license = with lib.licenses; [ mit ];
  };
})
