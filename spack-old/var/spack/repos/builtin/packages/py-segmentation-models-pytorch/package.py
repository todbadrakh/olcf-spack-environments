# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack.package import *


class PySegmentationModelsPytorch(PythonPackage):
    """Python library with Neural Networks for Image Segmentation based on PyTorch."""

    homepage = "https://github.com/qubvel/segmentation_models.pytorch"
    pypi = "segmentation_models_pytorch/segmentation_models_pytorch-0.2.0.tar.gz"

    version("0.3.0", sha256="8e00ed1707698d309d23f207aef15f21465e091aa0f1dc8043ec3300f5f67216")
    version("0.2.1", sha256="86744552b04c6bedf7e10f7928791894d8d9b399b9ed58ed1a3236d2bf69ead6")
    version("0.2.0", sha256="247266722c23feeef16b0862456c5ce815e5f0a77f95c2cd624a71bf00d955df")

    depends_on("python@3.6:", type=("build", "run"))
    depends_on("py-setuptools", type="build")
    depends_on("py-torchvision@0.5.0:", type=("build", "run"))
    depends_on("py-pretrainedmodels@0.7.4", type=("build", "run"))
    depends_on("py-efficientnet-pytorch@0.7.1", when="@0.3:", type=("build", "run"))
    depends_on("py-efficientnet-pytorch@0.6.3", when="@:0.2", type=("build", "run"))
    depends_on("py-timm@0.4.12", type=("build", "run"))
    depends_on("py-tqdm", when="@0.3:", type=("build", "run"))
    depends_on("pil", when="@0.3:", type=("build", "run"))
