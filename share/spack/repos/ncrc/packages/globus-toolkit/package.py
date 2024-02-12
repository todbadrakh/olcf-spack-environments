# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *

class GlobusToolkit(AutotoolsPackage):
    """The Globus Toolkit is an open source software toolkit used for building grids"""
    homepage = "http://toolkit.globus.org"
    maintainers = ['belhornmp']

    # depends_on('m4')
    # depends_on('autoconf')
    # depends_on('automake')
    # depends_on('libtool')

    # The source is distributed via github without a configure script but
    # autoreconf requires the source to have been cloned via git. This causes
    # problems when spack uses a cached archive of a version previously fetched
    # via git. Furthermore, the autoreconf stage fails when the source is cloned
    # freshly from git. So we've cloned the source, ran autoreconf manually, and
    # repackaged the release as a static archive.
    version('6.0.17', sha256="c14296306b14d118698a471f68c520acf57dacf1c3f0a1017df2f442e79d1892")

    def url_for_version(self, version):
        # commits_by_version = {
        #         '6.0.17': '14761278bf048b0d9bd3d46ab4c3c987b968f2d3',
        #         }
        # commit = self.commits_by_version.get(str(version.up_to(3)))
        url = 'file:///sw/sources/globus-toolkit/globus-toolkit-{0}.tar.gz'
        return url.format(version.up_to(3))
