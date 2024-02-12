# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class ROrgHsEgDb(RPackage):
    """Genome wide annotation for Human.

    Genome wide annotation for Human, primarily based on mapping using Entrez
    Gene identifiers."""

    bioc = "org.Hs.eg.db"
    url = "https://www.bioconductor.org/packages/3.5/data/annotation/src/contrib/org.Hs.eg.db_3.4.1.tar.gz"

    version(
        "3.15.0",
        sha256="1dc9bb6019e0f0a222b9ec84a1c5870cdbca480f45d9ad08e35f77278baa3c5f",
        url="https://www.bioconductor.org/packages/3.15/data/annotation/src/contrib/org.Hs.eg.db_3.15.0.tar.gz",
    )
    version(
        "3.14.0",
        sha256="0f87b3f1925a1d7007e5ad9200bdf511788bd1d7cb76f1121feeb109889c2b00",
        url="https://www.bioconductor.org/packages/3.14/data/annotation/src/contrib/org.Hs.eg.db_3.14.0.tar.gz",
    )
    version(
        "3.12.0",
        sha256="48a1ab5347ec7a8602c555d9aba233102b61ffa2765826e5c8890ff0003249bb",
        url="https://www.bioconductor.org/packages/3.12/data/annotation/src/contrib/org.Hs.eg.db_3.12.0.tar.gz",
    )
    version(
        "3.8.2",
        sha256="a0a16b7428f9e3d6ba54ebf4e05cd97a7bd298510ec4cf46ed2bed3e8f80db02",
        url="https://www.bioconductor.org/packages/3.9/data/annotation/src/contrib/org.Hs.eg.db_3.8.2.tar.gz",
    )
    version(
        "3.4.1",
        sha256="0f87b3f1925a1d7007e5ad9200bdf511788bd1d7cb76f1121feeb109889c2b00",
        url="https://www.bioconductor.org/packages/3.5/data/annotation/src/contrib/org.Hs.eg.db_3.4.1.tar.gz",
    )

    depends_on("r@2.7.0:", type=("build", "run"))
    depends_on("r-annotationdbi@1.37.4:", type=("build", "run"))
    depends_on("r-annotationdbi@1.43.1:", type=("build", "run"), when="@3.8.2:")
    depends_on("r-annotationdbi@1.51.3:", type=("build", "run"), when="@3.12.0:")
    depends_on("r-annotationdbi@1.55.1:", type=("build", "run"), when="@3.14.0:")
    depends_on("r-annotationdbi@1.57.1:", type=("build", "run"), when="@3.15.0:")
