class AthenzUtils < Formula
  desc "athenz-utils"
  homepage "https://github.com/yahoo/athenz/tree/master/utils"
  url "https://bintray.com/yahoo/maven/download_file?file_path=com%2Fyahoo%2Fathenz%2Fathenz-utils%2F1.7.43%2Fathenz-utils-1.7.43-bin.tar.gz"
  version "1.7.43"
  sha256 "bd8805426ebc2710a7340145c6d5bea3c22a209b39d122ee9b327e655253a229"

  def install
    bin.install "bin/darwin/athenz-conf" => "athenz-conf"
    bin.install "bin/darwin/zms-svctoken" => "zms-svctoken"
    bin.install "bin/darwin/zts-svccert" => "zts-svccert"
    bin.install "bin/darwin/zts-roletoken" => "zts-roletoken"
    bin.install "bin/darwin/zts-rolecert" => "zts-rolecert"
    bin.install "bin/darwin/zpu" => "zpu"
  end
end
