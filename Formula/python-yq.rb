class PythonYq < Formula
  include Language::Python::Virtualenv

  desc "Command-line YAML and XML processor that wraps jq"
  homepage "https://kislyuk.github.io/yq/"
  url "https://files.pythonhosted.org/packages/fc/0b/93a830fe6f75acaf2c052966b2c5f98aa3a18c08ca99b1621b60dd74e453/yq-3.0.2.tar.gz"
  sha256 "e47ff2479a3746f90bdbb77f84e3ebdb789ce46a092b1c261ae5b1f5f914f8e8"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5c35399b698ad7bfa396283e5bbba732c92a9bf3b3ef2318725492b2faed806a"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "22959c8c896e3e9ec2fab51a3f93f4a34da8d0ff8117c8c1620264d2bffb2289"
    sha256 cellar: :any_skip_relocation, monterey:       "c96d9dbf20bc4ac51d7b5098bb3dcfb8b801277c1c763d32ccecf03765412e04"
    sha256 cellar: :any_skip_relocation, big_sur:        "fd0172b1e01cee07350d5470fb7bdafffaf6fdac28a44e7569bcf2a21e5027a9"
    sha256 cellar: :any_skip_relocation, catalina:       "294354a91a83c14236afc950dcd5f2a46ab0ba0224a08513b57177ea7beda855"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d116658979f0cec62acf579bb9e93177c90d8405019f063252c9b6642b5d3317"
  end

  depends_on "jq"
  depends_on "python@3.10"

  conflicts_with "yq", because: "both install `yq` executables"

  resource "argcomplete" do
    url "https://files.pythonhosted.org/packages/05/f8/67851ae4fe5396ba6868c5d84219b81ea6a5d53991a6853616095c30adc0/argcomplete-2.0.0.tar.gz"
    sha256 "6372ad78c89d662035101418ae253668445b391755cfe94ea52f1b9d22425b20"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/36/2b/61d51a2c4f25ef062ae3f74576b01638bebad5e045f747ff12643df63844/PyYAML-6.0.tar.gz"
    sha256 "68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2"
  end

  resource "toml" do
    url "https://files.pythonhosted.org/packages/be/ba/1f744cdc819428fc6b5084ec34d9b30660f6f9daaf70eead706e3203ec3c/toml-0.10.2.tar.gz"
    sha256 "b3bda1d108d5dd99f4a20d24d9c348e91c4db7ab1b749200bded2f839ccbe68f"
  end

  resource "xmltodict" do
    url "https://files.pythonhosted.org/packages/39/0d/40df5be1e684bbaecdb9d1e0e40d5d482465de6b00cbb92b84ee5d243c7f/xmltodict-0.13.0.tar.gz"
    sha256 "341595a488e3e01a85a9d8911d8912fd922ede5fecc4dce437eb4b6c8d037e56"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    input = <<~EOS
      foo:
       bar: 1
       baz: {bat: 3}
    EOS
    expected = <<~EOS
      3
      ...
    EOS
    assert_equal expected, pipe_output("#{bin}/yq -y .foo.baz.bat", input, 0)
  end
end
