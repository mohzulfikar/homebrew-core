require "language/node"

class Lanraragi < Formula
  desc "Web application for archival and reading of manga/doujinshi"
  homepage "https://github.com/Difegue/LANraragi"
  url "https://github.com/Difegue/LANraragi/archive/v.0.7.5.tar.gz"
  sha256 "6a0f4e54ee550256a2301024ffc3b9cd75559c5527d7e2b932c1e92cd21338e0"
  license "MIT"
  head "https://github.com/Difegue/LANraragi.git"

  bottle do
    cellar :any
    sha256 "e3f87759273fd856ac242a651ea4d5c4cec92939a92a31d7e0808d28e7b7bb9f" => :big_sur
    sha256 "0815af31c4b839d92e787a4bded8afd0416bcd9f01152db094cfd11714f4caad" => :catalina
    sha256 "9114bf6aa5a2b13a87d6102028bd07739393ddbf589681e48b97fd309a8fb742" => :mojave
    sha256 "4e9a6f6f8c47965704f90183682e574d1de54cd3a476bccc2298af18719051cd" => :high_sierra
  end

  depends_on "pkg-config" => :build
  depends_on "cpanminus"
  depends_on "ghostscript"
  depends_on "giflib"
  depends_on "imagemagick@6"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "node"
  depends_on "openssl@1.1"
  depends_on "perl"
  depends_on "redis"
  uses_from_macos "libarchive"

  resource "Image::Magick" do
    url "https://cpan.metacpan.org/authors/id/J/JC/JCRISTY/PerlMagick-6.89-1.tar.gz"
    sha256 "c8f81869a4f007be63e67fddf724b23256f6209f16aa95e14d0eaef283772a59"
  end

  # libarchive headers from macOS 10.15 source
  resource "libarchive-headers-10.15" do
    url "https://opensource.apple.com/tarballs/libarchive/libarchive-72.11.2.tar.gz"
    sha256 "655b9270db794ba0b27052fd37b1750514b06769213656ab81e30727322e401f"
  end

  resource "Archive::Peek::Libarchive" do
    url "https://cpan.metacpan.org/authors/id/R/RE/REHSACK/Archive-Peek-Libarchive-0.38.tar.gz"
    sha256 "332159603c5cd560da27fd80759da84dad7d8c5b3d96fbf7586de2b264f11b70"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
    ENV.prepend_path "PERL5LIB", libexec/"lib"
    ENV["CFLAGS"] = "-I"+libexec/"include"

    resource("Image::Magick").stage do
      inreplace "Makefile.PL" do |s|
        s.gsub! "/usr/local/include/ImageMagick-6", "#{Formula["imagemagick@6"].opt_include}/ImageMagick-6"
      end

      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    resource("libarchive-headers-10.15").stage do
      (libexec/"include").install "libarchive/libarchive/archive.h"
      (libexec/"include").install "libarchive/libarchive/archive_entry.h"
    end

    resource("Archive::Peek::Libarchive").stage do
      inreplace "Makefile.PL" do |s|
        s.gsub! "$autoconf->_get_extra_compiler_flags", "$autoconf->_get_extra_compiler_flags .$ENV{CFLAGS}"
      end

      system "cpanm", "Config::AutoConf", "--notest", "-l", libexec
      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
      system "make"
      system "make", "install"
    end

    system "npm", "install", *Language::Node.local_npm_install_args
    system "perl", "./tools/install.pl", "install-full"

    prefix.install "README.md"
    bin.install "tools/build/homebrew/lanraragi"
    (libexec/"lib").install Dir["lib/*"]
    libexec.install "script"
    libexec.install "package.json"
    libexec.install "public"
    libexec.install "templates"
    libexec.install "tests"
    libexec.install "tools/build/homebrew/redis.conf"
    libexec.install "lrr.conf"
  end

  def caveats
    <<~EOS
      Automatic thumbnail generation will not work properly on macOS < 10.15 due to the bundled Libarchive being too old.
      Opening archives for reading will generate thumbnails normally.
    EOS
  end

  test do
    # This can't have its _user-facing_ functionality tested in the `brew test`
    # environment because it needs Redis. It fails spectacularly tho with some
    # table flip emoji. So let's use those to confirm _some_ functionality.
    output = <<~EOS
      ｷﾀ━━━━━━(ﾟ∀ﾟ)━━━━━━!!!!!
      (╯・_>・）╯︵ ┻━┻
      It appears your Redis database is currently not running.
      The program will cease functioning now.
    EOS
    assert_match output, shell_output("#{bin}/lanraragi", 1)
  end
end
