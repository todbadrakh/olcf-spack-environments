# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class PySphinxcontribMermaid(PythonPackage):
    """This extension allows you to embed
    `Mermaid <http://knsv.github.io/mermaid/>`_ graphs in your documents,
    including general flowcharts, sequence and gantt diagrams."""

    homepage = "https://github.com/mgaitan/sphinxcontrib-mermaid"
    pypi = "sphinxcontrib-mermaid/sphinxcontrib-mermaid-0.4.0.tar.gz"

    version("0.4.0", sha256="0ee45ba45b9575505eacdd6212e4e545213f4f93dfa32c7eeca32720dbc3b468")

    depends_on("py-setuptools", type="build")
    depends_on("py-sphinx@1.7:", type=("build", "run"))
