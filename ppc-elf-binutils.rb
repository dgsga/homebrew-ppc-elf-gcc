class PpcElfBinutils < Formula
  desc "GNU Binutils for ppc-elf cross development"
  homepage "https://www.gnu.org/software/binutils/"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.39.tar.xz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.39.tar.xz"
  sha256 "645c25f563b8adc0a81dbd6a41cffbf4d37083a382e02d5d3df4f65c09516d00"
  license "GPL-3.0-or-later"

  livecheck do
    formula "binutils"
  end

  on_system :linux, macos: :ventura_or_newer do
    depends_on "texinfo" => :build
  end

  def install
    target = "ppc-elf"
    system "./configure", "--target=#{target}",
           "--prefix=#{prefix}",
           "--libdir=#{lib}/#{target}",
           "--infodir=#{info}/#{target}",
           "--disable-nls"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test-s.s").write <<~EOS
      .section .text
      .globl _start
      _start:
          mov x0, #0
          mov x16, #1
          svc #0x80
    EOS
    system "#{bin}/ppc-elf-as", "-o", "test-s.o", "test-s.s"
    assert_match "file format elf64-littleppc",
                 shell_output("#{bin}/ppc-elf-objdump -a test-s.o")
    assert_match "f()", shell_output("#{bin}/ppc-elf-c++filt _Z1fv")
  end
end
