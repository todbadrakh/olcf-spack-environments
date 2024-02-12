# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

from spack import *
import os

class Tkdiff(Package):
    """tkdiff is a graphical front end to the diff program. It provides a
    side-by-side view of the differences between two text files, along with
    several innovative features such as diff bookmarks, a graphical map of
    differences for quick navigation, and a facility for slicing diff regions to
    achieve exactly the merge output desired.
    """
    homepage = "https://sourceforge.net/projects/tkdiff/"
    url      = "https://master.dl.sourceforge.net/project/tkdiff/tkdiff/4.3.1/tkdiff-4-3-1.zip"


    version('4.3.5',
            sha256='29d7f0b815d06b0ab6653baa9b6b7c213801ce6a976724ae843bf9735cbbde7e')
    version('4.3.1',
            sha256='832da430a66be06e7406edd620c10ac922f16b00d071334d4b9c8267f640901f')
    version('4.2',
            sha256='734bb417184c10072eb64e8d274245338e41b7fdeff661b5ef30e89f3e3aa357')


    def url_for_version(self, version):
        url = ("https://master.dl.sourceforge.net/project"
               "/tkdiff/tkdiff/{0}/tkdiff-{1}.{2}")
        return url.format(version.dotted,
                          version.dashed,
                          'zip' if self.spec.satisfies('@4.3:') else 'tar.gz')


    def install(self, spec, prefix):
        os.mkdir(prefix.bin)
        install('tkdiff', prefix.bin)
