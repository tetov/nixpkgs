{
  lib,
  stdenv,
  writeShellApplication,
  fetchFromGitHub,
  cjson,
  cmake,
  git,
  makeBinaryWrapper,
  unzip,
  curl,
  freetype,
  glew,
  libjpeg,
  libogg,
  libpng,
  libtheora,
  libX11,
  lua5_4,
  minizip,
  openal,
  SDL2,
  sqlite,
  zlib,
}:
let
  version = "2.83.2";
  fakeGit = writeShellApplication {
    name = "git";

    text = ''
      if [ "$1" = "describe" ]; then
        echo "${version}"
      fi
    '';
  };
in
stdenv.mkDerivation {
  pname = "etlegacy-unwrapped";
  inherit version;

  src = fetchFromGitHub {
    owner = "etlegacy";
    repo = "etlegacy";
    tag = "v${version}";
    hash = "sha256-hZwLYaYV0j3YwFi8KRr4DZV73L2yIwFJ3XqCyq6L7hE=";
  };

  nativeBuildInputs = [
    cjson
    cmake
    fakeGit
    git
    makeBinaryWrapper
    unzip
  ];

  buildInputs = [
    curl
    freetype
    glew
    libjpeg
    libogg
    libpng
    libtheora
    libX11
    lua5_4
    minizip
    openal
    SDL2
    sqlite
    zlib
  ];

  preBuild = ''
    # Required for build time to not be in 1980
    export SOURCE_DATE_EPOCH=$(date +%s)
    # This indicates the build was by a CI pipeline and prevents the resource
    # files from being flagged as 'dirty' due to potentially being custom built.
    export CI="true"
  '';

  cmakeFlags = [
    "-DCROSS_COMPILE32=0"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SERVER=1"
    "-DBUILD_CLIENT=1"
    "-DBUNDLED_ZLIB=0"
    "-DBUNDLED_CJSON=0"
    "-DBUNDLED_JPEG=0"
    "-DBUNDLED_LIBS=0"
    "-DBUNDLED_FREETYPE=0"
    "-DBUNDLED_OGG_VORBIS=0"
    "-DBUNDLED_OPENAL=0"
    "-DBUNDLED_PNG=0"
    "-DBUNDLED_THEORA=0"
    "-DBUNDLED_MINIZIP=0"
    "-DINSTALL_EXTRA=0"
    "-DINSTALL_OMNIBOT=0"
    "-DINSTALL_GEOIP=0"
    "-DINSTALL_WOLFADMIN=0"
    "-DFEATURE_AUTOUPDATE=0"
    "-DINSTALL_DEFAULT_BASEDIR=${placeholder "out"}/lib/etlegacy"
    "-DINSTALL_DEFAULT_BINDIR=${placeholder "out"}/bin"
  ];

  hardeningDisable = [ "fortify" ];

  meta = {
    description = "ET: Legacy is an open source project based on the code of Wolfenstein: Enemy Territory which was released in 2010 under the terms of the GPLv3 license";
    homepage = "https://etlegacy.com";
    license = with lib.licenses; [ gpl3Plus ];
    longDescription = ''
      ET: Legacy, an open source project fully compatible client and server
      for the popular online FPS game Wolfenstein: Enemy Territory - whose
      gameplay is still considered unmatched by many, despite its great age.
    '';
    maintainers = with lib.maintainers; [
      ashleyghooper
      drupol
    ];
  };
}
