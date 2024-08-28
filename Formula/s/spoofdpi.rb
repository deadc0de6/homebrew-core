class Spoofdpi < Formula
  desc "Simple and fast anti-censorship tool written in Go"
  homepage "https://github.com/xvzc/SpoofDPI"
  url "https://github.com/xvzc/SpoofDPI/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "3f4c9e144870afd0f39796e43433de5fd444492f86bf7740a11ce7169ab893ec"
  license "Apache-2.0"
  head "https://github.com/xvzc/SpoofDPI.git", branch: "main"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "0b78611ee0585f1fc10af5030d7ca961b33ce93e177b086a55e851d8b1d7a58a"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0b78611ee0585f1fc10af5030d7ca961b33ce93e177b086a55e851d8b1d7a58a"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0b78611ee0585f1fc10af5030d7ca961b33ce93e177b086a55e851d8b1d7a58a"
    sha256 cellar: :any_skip_relocation, sonoma:         "81edc2ceaf186955d567cbd6226ad03a8998ac427ce53898d048f7e36a30e2fc"
    sha256 cellar: :any_skip_relocation, ventura:        "81edc2ceaf186955d567cbd6226ad03a8998ac427ce53898d048f7e36a30e2fc"
    sha256 cellar: :any_skip_relocation, monterey:       "81edc2ceaf186955d567cbd6226ad03a8998ac427ce53898d048f7e36a30e2fc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f0052976ee942e128af65f6bfeb99120e7b58a8c61bb133bf57e48698f9b2f10"
  end

  depends_on "go" => :build
  uses_from_macos "curl" => :test

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/spoofdpi"
  end

  service do
    run opt_bin/"spoofdpi"
    keep_alive successful_exit: false
    log_path var/"log/spoofdpi/output.log"
    error_log_path var/"log/spoofdpi/error.log"
  end

  test do
    port = free_port

    pid = fork do
      system bin/"spoofdpi", "-system-proxy=false", "-port", port
    end
    sleep 3

    begin
      # "nothing" is an invalid option, but curl will process it
      # only after it succeeds at establishing a connection,
      # then it will close it, due to the option, and return exit code 49.
      shell_output("curl -s --connect-timeout 1 --telnet-option nothing 'telnet://127.0.0.1:#{port}' > /dev/null", 49)
    ensure
      Process.kill("SIGTERM", pid)
    end
  end
end
