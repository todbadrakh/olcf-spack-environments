# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class RBrobdingnag(RPackage):
    """Very Large Numbers in R.

    Handles very large numbers in R. Real numbers are held using their natural
    logarithms, plus a logical flag indicating sign. The package includes a
    vignette that gives a step-by-step introduction to using S4 methods."""

    cran = "Brobdingnag"

    version("1.2-7", sha256="73a734342736da5b29c2827d91f662101873503af7ad9cdf9e9e697bb32dd742")
    version("1.2-6", sha256="19eccaed830ce9d93b70642f6f126ac66722a98bbd48586899cc613dd9966ad4")

    depends_on("r@2.13.0:", type=("build", "run"))
