# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)
from typing import List

from spack.package import *


class PySphinxcontribQthelp(PythonPackage):
    """sphinxcontrib-qthelp is a sphinx extension which outputs QtHelp
    document."""

    homepage = "http://sphinx-doc.org/"
    pypi = "sphinxcontrib-qthelp/sphinxcontrib-qthelp-1.0.2.tar.gz"

    # 'sphinx' requires 'sphinxcontrib-qthelp' at build-time, but
    # 'sphinxcontrib-qthelp' requires 'sphinx' at run-time. Don't bother trying to
    # import any modules.
    import_modules = []  # type: List[str]

    version("1.0.2", sha256="79465ce11ae5694ff165becda529a600c754f4bc459778778c7017374d4d406f")

    depends_on("python@3.5:", type=("build", "run"))
    depends_on("py-setuptools", type="build")
