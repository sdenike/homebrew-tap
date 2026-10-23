class FfmpegFull < Formula
  desc "FFmpeg with the kitchen sink for Apple Silicon: GPL, nonfree fdk-aac, whisper, VVC, JPEG XL"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz"
  sha256 "8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e"
  license :cannot_represent # GPL-3.0-or-later build with nonfree libfdk-aac; do not redistribute binaries
  head "https://git.ffmpeg.org/ffmpeg.git", branch: "master"

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on arch: :arm64
  depends_on "dav1d"
  depends_on "fdk-aac"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz"
  depends_on "jpeg-xl"
  depends_on "lame"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libsoxr"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on :macos
  depends_on "openjpeg"
  depends_on "openssl@4"
  depends_on "opus"
  depends_on "sdl2-compat"
  depends_on "srt"
  depends_on "svt-av1"
  depends_on "theora"
  depends_on "vvenc"
  depends_on "webp"
  depends_on "whisper.cpp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xz"
  depends_on "zeromq"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  conflicts_with "ffmpeg", because: "both install ffmpeg/ffprobe/ffplay and the libav* libraries"

  # Reviewed upstream fix for the yadif_videotoolbox teardown crash (FFmpeg PR 23850).
  patch do
    url "https://raw.githubusercontent.com/sdenike/homebrew-tap/6c1d482e27bc5f2366156603fee01b4c629dabbe/patches/ffmpeg-full-yadif-videotoolbox.patch"
    sha256 "ef03bb929ff86d5a8fc3052065e2e120d38ff6d64df6c592c331b0ee18dce595"
  end

  # Canonical JSON output for the whisper filter (vendored from Aagedal Photo Agent).
  patch do
    url "https://raw.githubusercontent.com/sdenike/homebrew-tap/6c1d482e27bc5f2366156603fee01b4c629dabbe/patches/ffmpeg-full-whisper-canonical-json.patch"
    sha256 "f34d798a927a417c28ad6b6836b2ed881ab758b2de61170ea8f3c9000ed9ce68"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --arch=arm64
      --cc=#{ENV.cc}
      --enable-shared
      --disable-static
      --disable-debug
      --disable-doc
      --enable-pthreads
      --enable-neon
      --enable-runtime-cpudetect
      --enable-gpl
      --enable-version3
      --enable-nonfree
      --enable-ffplay
      --enable-openssl
      --enable-videotoolbox
      --enable-audiotoolbox
      --enable-libaom
      --enable-libass
      --enable-libbluray
      --enable-libdav1d
      --enable-libfdk-aac
      --enable-libfontconfig
      --enable-libfreetype
      --enable-libfribidi
      --enable-libharfbuzz
      --enable-libjxl
      --enable-libmp3lame
      --enable-libopenjpeg
      --enable-libopus
      --enable-libsoxr
      --enable-libsrt
      --enable-libsvtav1
      --enable-libtheora
      --enable-libvmaf
      --enable-libvorbis
      --enable-libvpx
      --enable-libvvenc
      --enable-libwebp
      --enable-libx264
      --enable-libx265
      --enable-libzmq
      --enable-whisper
    ]

    # yadif_videotoolbox needs the Metal toolchain; build without it if absent.
    if quiet_system("xcrun", "-sdk", "macosx", "metal", "-v") &&
       quiet_system("xcrun", "-sdk", "macosx", "metallib", "--version")
      args += %w[
        --enable-metal
        --metalcc=xcrun -sdk macosx metal
        --metallib=xcrun -sdk macosx metallib
      ]
    else
      opoo "Metal toolchain not found; building without yadif_videotoolbox"
    end

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<~EOS
      This build links the nonfree libfdk-aac, so the resulting binaries are not
      redistributable. It installs from source on your own machine only.
    EOS
  end

  test do
    # Encode a test pattern with a few of the extras and read it back.
    system bin/"ffmpeg", "-hide_banner", "-loglevel", "error",
           "-f", "lavfi", "-i", "testsrc=duration=1:size=320x240:rate=15",
           "-f", "lavfi", "-i", "sine=duration=1", "-c:v", "libx264", "-c:a", "libfdk_aac", "-y", "test.mp4"
    assert_match "h264", shell_output("#{bin}/ffprobe -loglevel error -show_entries stream=codec_name test.mp4")
    assert_match "whisper", shell_output("#{bin}/ffmpeg -hide_banner -filters")
  end
end
