# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *


class GridcfGct(AutotoolsPackage):
    """The GCT is a nascent effort by the Grid Community Forum (GridCF) to
    provide community-based support for critical software packages for grid
    computing.
    
    The GCT is based on a fork of the Globus Toolkit but is not the Globus
    Toolkit.
    """

    homepage = "https://github.com/gridcf/gct"
    url      = "https://repo.gridcf.org/gct6/sources/gct-6.2.1653033972.tar.gz"

    maintainers = ['belhornmp']

    version('6.2.20220524',
            sha256='ad4de378b481bc41d888b5cfc192b24b3602488e56a9abee497e55933067baa4',
            url='https://repo.gridcf.org/gct6/sources/gct-6.2.1653033972.tar.gz')

    depends_on('openssl@0.9.8:')
    depends_on('perl@5.10:')
    # depends_on('pkgconf', type='build')
    # depends_on('autoconf', type='build')
    # depends_on('automake', type='build')
    # depends_on('libtool', type='build')

    def configure_args(self):
        args = ['--disable-gsi-openssh']
        return args
