# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class PyTorchmetrics(PythonPackage):
    """Machine learning metrics for distributed, scalable PyTorch applications."""

    homepage = "https://github.com/PyTorchLightning/metrics"
    pypi = "torchmetrics/torchmetrics-0.3.1.tar.gz"

    maintainers = ["adamjstewart"]

    version("0.10.0", sha256="990bafc7f76d7442894533771d0ba7492dbca2bbf2989fb32de7e9c68eb3d133")
    version("0.9.3", sha256="4ebfd2466021db26397636966ee1a195d3b340ba5d71bb258e764340dfc2476f")
    version("0.9.2", sha256="8178c9242e243318093d9b7237738a504535193d2006da6e58b0ed4003e318d2")
    version("0.9.0", sha256="3aa32ea575915b313d872d3460996c0f12a7bb37e6ce3da0e8d80865603b89f6")
    version("0.7.0", sha256="dbfb8989086f38020045a935e83928504e1af1d84ae92b073f6a83d018f4bc00")
    version("0.5.1", sha256="22fbcb6fc05348ca3f2bd06e0763e88411a6b68c2b9fc26084b39d40cc4021b0")
    version("0.4.1", sha256="2fc50f812210c33b8c2649dbb1482e3c47e93cae33e4b3d0427fb830384effbd")
    version("0.3.1", sha256="78f4057db53f7c219fdf9ec9eed151adad18dd43488a44e5c780806d218e3f1d")
    version("0.2.0", sha256="481a28759acd2d77cc088acba6bc7dc4a356c7cb767da2e1495e91e612e2d548")

    depends_on("python@3.7:", when="@0.9:", type=("build", "run"))
    depends_on("python@3.6:", type=("build", "run"))
    depends_on("py-setuptools", type="build")
    depends_on("py-numpy@1.17.2:", when="@0.4:", type=("build", "run"))
    depends_on("py-numpy", when="@0.3:", type=("build", "run"))
    depends_on("py-torch@1.3.1:", type=("build", "run"))
    depends_on("py-pydeprecate@0.3", when="@0.7:0.8", type=("build", "run"))
    depends_on("py-packaging", when="@0.3:", type=("build", "run"))
    depends_on("py-typing-extensions", when="@0.9: ^python@:3.8", type=("build", "run"))
