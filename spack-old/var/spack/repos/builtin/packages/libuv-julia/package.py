# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)
from spack.package import *


class LibuvJulia(AutotoolsPackage):
    """Multi-platform library with a focus on asynchronous IO"""

    homepage = "https://libuv.org"
    url = "https://github.com/JuliaLang/libuv/archive/refs/heads/julia-uv2-1.44.2.tar.gz"
    git = "https://github.com/JuliaLang/libuv.git"

    # julia's libuv fork doesn't tag (all?) releases, so we fix commits.
    version("1.44.2", commit="e6f0e4900e195c8352f821abe2b3cffc3089547b")
    version("1.44.1", commit="1b2d16477fe1142adea952168d828a066e03ee4c")
    version("1.42.0", commit="3a63bf71de62c64097989254e4f03212e3bf5fc8")

    depends_on("automake", type="build")
    depends_on("autoconf", type="build")
    depends_on("libtool", type="build")
    depends_on("m4", type="build")

    def autoreconf(self, spec, prefix):
        # This is needed because autogen.sh generates on-the-fly
        # an m4 macro needed during configuration
        Executable("./autogen.sh")()

    @property
    def libs(self):
        return find_libraries(["libuv"], root=self.prefix, recursive=True)
