# Copyright 2013-2019 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)


from spack import *
import os


class Magma(CMakePackage):
    """The MAGMA project aims to develop a dense linear algebra library similar to
       LAPACK but for heterogeneous/hybrid architectures, starting with current
       "Multicore+GPU" systems.
    """

    homepage = "http://icl.cs.utk.edu/magma/"
    url = "http://icl.cs.utk.edu/projectsfiles/magma/downloads/magma-2.2.0.tar.gz"
    maintainers = ['luszczek']

    version('2.5.1-alpha1', sha256='0576ddef07e049e2674fa87caca06ffe96f8d92134ed8aea387b9523be0d7c77')
    version('2.5.0', sha256='4fd45c7e46bd9d9124253e7838bbfb9e6003c64c2c67ffcff02e6c36d2bcfa33')
    version('2.4.0', sha256='4eb839b1295405fd29c8a6f5b4ed578476010bf976af46573f80d1169f1f9a4f')
    version('2.3.0', sha256='010a4a057d7aa1e57b9426bffc0958f3d06913c9151463737e289e67dd9ea608')
    version('2.2.0', sha256='df5d4ace417e5bf52694eae0d91490c6bde4cde1b0da98e8d400c5c3a70d83a2')

    variant('fortran', default=True,
            description='Enable Fortran bindings support')
    variant('shared', default=True,
            description='Enable shared library')

    gpu_targets = ('none', 'kepler', 'fermi', 'maxwell', 'volta')
    variant('gpus', default='none',
            values=gpu_targets,
            multi=True,
            description='Enables support for specific CUDA GPUs.')

    # Version 2.2.0 only supports up to "Maxwell", but not "Volta"
    conflicts('gpus=volta', when='@:2.2.0')

    depends_on('blas')
    depends_on('lapack')
    depends_on('cuda')

    conflicts('%gcc@6:', when='^cuda@:8')
    conflicts('%gcc@7:', when='^cuda@:9')

    patch('ibm-xl.patch', when='@2.2:2.5.0%xl')
    patch('ibm-xl.patch', when='@2.2:2.5.0%xl_r')
    patch('magma-2.3.0-gcc-4.8.patch', when='@2.3.0%gcc@:4.8')
    patch('magma-2.5.0.patch', when='@2.5.0')
    patch('magma-2.5.0-cmake.patch', when='@2.5.0')

    def cmake_args(self):
        spec = self.spec
        pic_flag = self.compiler.pic_flag
        options = []

        options.extend([
            '-DCMAKE_INSTALL_PREFIX=%s' % spec.prefix,
            '-DCMAKE_INSTALL_NAME_DIR:PATH=%s/lib' % spec.prefix,
            '-DBLAS_LIBRARIES=%s' % spec['blas'].libs.joined(';'),
            # As of MAGMA v2.3.0, CMakeLists.txt does not use the variable
            # BLAS_LIBRARIES, but only LAPACK_LIBRARIES, so we need to
            # explicitly add blas to LAPACK_LIBRARIES.
            '-DLAPACK_LIBRARIES=%s' %
            (spec['lapack'].libs + spec['blas'].libs).joined(';')
        ])

        if spec.satisfies('+shared'):
            options.extend(['-DBUILD_SHARED_LIBS=ON',
                            '-DCMAKE_C_FLAGS=%s' % pic_flag,
                            '-DCMAKE_CXX_FLAGS=%s' % pic_flag,
                            '-DCMAKE_Fortran_FLAGS=%s' % pic_flag,
                            ])
        else:
            options.append('-DBUILD_SHARED_LIBS=OFF')

        if '+fortran' in spec:
            options.extend([
                '-DUSE_FORTRAN=yes'
            ])
            if spec.satisfies('%xl') or spec.satisfies('%xl_r'):
                options.extend([
                    '-DCMAKE_Fortran_COMPILER=%s' % self.compiler.f77
                ])

        gpus = ','.join([target.capitalize() for target
                         in self.gpu_targets
                         if (target != 'none' and
                             spec.satisfies('gpus=%s' % target))])

        if spec.satisfies('^cuda@9.0:'):
            if '@:2.2.0' in spec:
                gpus = ','.join([i for i in  gpus.split(',') if i] + ['sm30'])
            else:
                gpus = ','.join([i for i in  gpus.split(',') if i] + ['sm_30'])

        if gpus:
            options.extend([
                '-DGPU_TARGET=%s' % gpus,
                ])

        if '@2.5.0' in spec:
            options.extend(['-DMAGMA_SPARSE=OFF'])
            if spec.compiler.name in ['xl', 'xl_r']:
                options.extend(['-DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=TRUE'])

        return options

    @run_after('install')
    def post_install(self):
        install('magmablas/atomics.cuh', self.prefix.include)
        install('control/magma_threadsetting.h', self.prefix.include)
        install('control/pthread_barrier.h', self.prefix.include)
        install('control/magma_internal.h', self.prefix.include)