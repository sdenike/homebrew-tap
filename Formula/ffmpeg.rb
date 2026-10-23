class Ffmpeg < Formula
  desc "With every codec and filter, built for Apple Silicon"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz"
  sha256 "8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e"
  license :cannot_represent # GPL-3.0-or-later build with nonfree libfdk-aac; do not redistribute binaries
  revision 1 # matches homebrew-core ffmpeg 9.0.2_1 so this is a like-for-like keg
  compatibility_version 3
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  livecheck do
    url "https://ffmpeg.org/download.html"
    regex(/href=.*?ffmpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

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
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  # Reviewed upstream fix for the yadif_videotoolbox teardown crash (FFmpeg PR 23850).
  resource "ffmpeg-info" do
    url "https://raw.githubusercontent.com/sdenike/homebrew-tap/5ef02a79f520dd4595856a2256623b82e5104ce4/scripts/ffmpeg-info"
    sha256 "802b09b63337af5963b349927c97ae4b1d935058cff998c8a672458201220c15"
  end

  patch do
    url "https://raw.githubusercontent.com/sdenike/homebrew-tap/5ef02a79f520dd4595856a2256623b82e5104ce4/patches/ffmpeg-yadif-videotoolbox.patch"
    sha256 "ef03bb929ff86d5a8fc3052065e2e120d38ff6d64df6c592c331b0ee18dce595"
  end

  # Canonical JSON output for the whisper filter (vendored from Aagedal Photo Agent).
  patch do
    url "https://raw.githubusercontent.com/sdenike/homebrew-tap/5ef02a79f520dd4595856a2256623b82e5104ce4/patches/ffmpeg-whisper-canonical-json.patch"
    sha256 "f34d798a927a417c28ad6b6836b2ed881ab758b2de61170ea8f3c9000ed9ce68"
  end

  deny_network_access! [:postinstall, :test]

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.ld64_version.between?("1015.7", "1022.1")

    args = %W[
      --prefix=#{prefix}
      --arch=arm64
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-shared
      --enable-static
      --disable-debug
      --enable-pthreads
      --enable-neon
      --extra-cflags=-mcpu=apple-m1
      --extra-cxxflags=-mcpu=apple-m1
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
    # configure splits --metalcc on spaces, so pass resolved tool paths.
    metalcc = Utils.safe_popen_read("xcrun", "-sdk", "macosx", "-f", "metal", err: :close).chomp
    metallib = Utils.safe_popen_read("xcrun", "-sdk", "macosx", "-f", "metallib", err: :close).chomp
    if !metalcc.empty? && !metallib.empty? && quiet_system(metalcc, "-v")
      ENV["CLANG_MODULE_CACHE_PATH"] = buildpath/"clang-modules"
      args += %W[--enable-metal --metalcc=#{metalcc} --metallib=#{metallib}]
    else
      opoo "Metal toolchain not found; building without yadif_videotoolbox"
    end

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools, as homebrew-core's ffmpeg does.
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"

    resource("ffmpeg-info").stage { bin.install "ffmpeg-info" }
  end

  def caveats
    <<~EOS
      This build links the nonfree libfdk-aac, so the resulting binaries are not
      redistributable. It installs from source on your own machine only.
    EOS
  end

  test do
    assert_match "fdk-aac", shell_output(bin/"ffmpeg-info")
    # Encode a test pattern with a few of the extras and read it back.
    system bin/"ffmpeg", "-hide_banner", "-loglevel", "error",
           "-f", "lavfi", "-i", "testsrc=duration=1:size=320x240:rate=15",
           "-f", "lavfi", "-i", "sine=duration=1", "-c:v", "libx264", "-c:a", "libfdk_aac", "-y", "test.mp4"
    assert_match "h264", shell_output("#{bin}/ffprobe -loglevel error -show_entries stream=codec_name test.mp4")
    assert_match "whisper", shell_output("#{bin}/ffmpeg -hide_banner -filters")
  end
end
