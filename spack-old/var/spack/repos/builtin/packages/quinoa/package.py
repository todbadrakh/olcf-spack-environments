# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack.package import *
from spack.pkg.builtin.boost import Boost


class Quinoa(CMakePackage):
    """Quinoa is a set of computational tools that enables research and
    numerical analysis in fluid dynamics. At this time it is a test-bed
    to experiment with various algorithms using fully asynchronous runtime
    systems.
    """

    homepage = "https://quinoacomputing.org"
    git = "https://github.com/quinoacomputing/quinoa.git"

    version("develop", branch="master")

    depends_on("hdf5+mpi")
    depends_on("charmpp backend=mpi")
    depends_on("trilinos+exodus+mpi")
    # TODO: replace this with an explicit list of components of Boost,
    # for instance depends_on('boost +filesystem')
    # See https://github.com/spack/spack/pull/22303 for reference
    depends_on(Boost.with_default_variants)
    depends_on("hypre~internal-superlu")
    depends_on("random123")
    depends_on("netlib-lapack+lapacke")
    depends_on("mad-numdiff")
    depends_on("h5part")
    depends_on("boostmplcartesianproduct")
    depends_on("tut")
    depends_on("pugixml")
    depends_on("pstreams")
    depends_on("pegtl")

    root_cmakelists_dir = "src"
