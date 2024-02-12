# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class PyRadicalUtils(PythonPackage):
    """RADICAL-Utils contains shared code and tools for various
    RADICAL-Cybertools packages."""

    homepage = "https://radical-cybertools.github.io"
    git = "https://github.com/radical-cybertools/radical.utils.git"
    pypi = "radical.utils/radical.utils-1.16.0.tar.gz"

    maintainers = ["andre-merzky"]

    version("develop", branch="devel")
    version("1.16.0", sha256="6eddfba5c73e71c7c5ddeba6c8ebe5260616d66b26d1f7123613c3cd543d61e9")
    version("1.15.0", sha256="22e5028de75c0a471bfed587d437dded214625b150deaca0289474a3619d395b")
    version("1.14.0", sha256="f61f0e335bbdc51e4023458e7e6959551686ebf170adc5353220dcc83fd677c9")
    version("1.13.0", sha256="84c1cad8be988dad7fb2b8455d19a4fb0c979fab02c5b7a7b531a4ae8fe52580")
    version("1.12.0", sha256="1474dbe4d94cdf3e992e1711e10d73dffa352c1c29ff51d81c1686e5081e9398")
    version("1.11.1", sha256="4fec3f6d45d7309c891ab4f8aeda0257f06f9a8404ca87c7eb643cd8d7415804")
    version("1.11.0", sha256="81537c2a2f8a1a409b4a1aac67323c6b49cc994e2b70052425e2bc8d4622e2de")
    version("1.9.1", sha256="0837d75e7f9dcce5ba5ac63151ab1683d6ba9ab3954b076d1f170cc4a3cdb1b4")
    version("1.8.4", sha256="4777ba20e9f881bf3e73ad917638fdeca5a4b253d57ed7b321a07f670e3f737b")
    version("1.8.0", sha256="8582c65593f51d394fc263c6354ec5ad9cc7173369dcedfb2eef4f5e8146cf03")
    version("1.6.7", sha256="552f6c282f960ccd9d2401d686b0b3bfab35dfa94a26baeb2d3b4e45211f05a9")

    version(
        "0.45",
        sha256="1333cff1a69532e51d4484fbac3fad6b172d415d2055a3141117c7cf8bdee6c5",
        deprecated=True,
    )
    version(
        "0.41.1",
        sha256="582900e0434f49b69885a89bc65dc787362756e1014d52a4afac0bb61bcaa3ce",
        deprecated=True,
    )

    depends_on("py-radical-gtod", type=("build", "run"), when="@:1.13")

    depends_on("python@3.6:", type=("build", "run"))
    depends_on("py-colorama", type=("build", "run"))
    depends_on("py-msgpack", type=("build", "run"))
    depends_on("py-netifaces", type=("build", "run"))
    depends_on("py-ntplib", type=("build", "run"))
    depends_on("py-pymongo@:3", type=("build", "run"))
    depends_on("py-pyzmq", type=("build", "run"))
    depends_on("py-regex", type=("build", "run"))
    depends_on("py-setproctitle", type=("build", "run"))
    depends_on("py-setuptools", type="build")
