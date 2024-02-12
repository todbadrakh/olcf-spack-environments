#!/bin/bash

# Set a compiler to test with, e.g. '%gcc', '%clang', etc.
compiler=''
cuda_arch="70"
rocm_arch="gfx908"

spack_jobs=''
# spack_jobs='-j 128'

mfem='mfem@4.4.0'${compiler}
mfem_dev='mfem@develop'${compiler}

backends='+occa+raja+libceed'
backends_specs='^occa~cuda ^raja~openmp'

# help the concrtizer find suitable hdf5 version (conduit constraint)
hdf5_spec='^hdf5@1.8.19:1.8'
# petsc spec
petsc_spec='^petsc+suite-sparse+mumps'
petsc_spec_cuda='^petsc+cuda+suite-sparse+mumps'
# strumpack spec without cuda (use @master until version > 6.3.1 is released)
strumpack_spec='^strumpack@master~slate~openmp~cuda'
strumpack_cuda_spec='^strumpack@master~slate~openmp'
strumpack_rocm_spec='^strumpack+rocm~slate~openmp~cuda'

builds=(
    # preferred version:
    ${mfem}
    ${mfem}'~mpi~metis~zlib'
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: add back '+slepc' when its build is fixed.
    ${mfem}"$backends"'+superlu-dist+strumpack+suite-sparse+petsc \
        +sundials+pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        '"$backends_specs $strumpack_spec $petsc_spec $hdf5_spec"
    ${mfem}'~mpi \
        '"$backends"'+suite-sparse+sundials+gslib+mpfr+netcdf \
        +zlib+gnutls+libunwind+conduit \
        '"$backends_specs $hdf5_spec"' ^sundials~mpi'

    # develop version, shared builds:
    ${mfem_dev}'+shared~static'
    ${mfem_dev}'+shared~static~mpi~metis~zlib'
    # NOTE: Shared build with +gslib works on mac but not on linux
    # TODO: add back '+gslib' when the gslib test is fixed and the above NOTE
    #       is addressed.
    # TODO: add back '+slepc' when its build is fixed.
    ${mfem_dev}'+shared~static \
        '"$backends"'+superlu-dist+strumpack+suite-sparse+petsc \
        +sundials+pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        '"$backends_specs $strumpack_spec $petsc_spec $hdf5_spec"
    # NOTE: Shared build with +gslib works on mac but not on linux
    # TODO: add back '+gslib' when the above NOTE is addressed.
    ${mfem_dev}'+shared~static~mpi \
        '"$backends"'+suite-sparse+sundials+mpfr+netcdf \
        +zlib+gnutls+libunwind+conduit \
        '"$backends_specs $hdf5_spec"' ^sundials~mpi'
)

builds2=(
    # preferred version
    ${mfem}"$backends $backends_specs"
    ${mfem}'+superlu-dist'
    ${mfem}'+strumpack'" $strumpack_spec"
    ${mfem}'+suite-sparse~mpi'
    ${mfem}'+suite-sparse'
    ${mfem}'+sundials~mpi ^sundials~mpi'
    ${mfem}'+sundials'
    ${mfem}'+pumi'
    # TODO: uncomment the next line when the gslib test is fixed.
    # ${mfem}'+gslib'
    ${mfem}'+netcdf~mpi'
    ${mfem}'+netcdf'
    ${mfem}'+mpfr'
    ${mfem}'+gnutls'
    ${mfem}'+conduit~mpi'
    ${mfem}'+conduit'
    ${mfem}'+umpire'
    ${mfem}'+petsc'" $petsc_spec"
    # TODO: uncomment the next line when the slepc build is fixed.
    # ${mfem}'+petsc+slepc'" $petsc_spec"
    # TODO: uncomment the next line when the threadsafe build is fixed.
    # ${mfem}'+threadsafe'
    # develop version
    ${mfem_dev}"$backends $backends_specs"
    ${mfem_dev}'+superlu-dist'
    ${mfem_dev}'+strumpack'" $strumpack_spec"
    ${mfem_dev}'+suite-sparse~mpi'
    ${mfem_dev}'+suite-sparse'
    ${mfem_dev}'+sundials~mpi ^sundials~mpi'
    ${mfem_dev}'+sundials'
    ${mfem_dev}'+pumi'
    # TODO: uncomment the next line when the gslib test is fixed.
    # ${mfem_dev}'+gslib'
    ${mfem_dev}'+netcdf~mpi'
    ${mfem_dev}'+netcdf'
    ${mfem_dev}'+mpfr'
    ${mfem_dev}'+gnutls'
    ${mfem_dev}'+conduit~mpi'
    ${mfem_dev}'+conduit'
    ${mfem_dev}'+umpire'
    ${mfem_dev}'+petsc'" $petsc_spec"
    ${mfem_dev}'+petsc+slepc'" $petsc_spec"
    # TODO: uncomment the next line when the threadsafe build is fixed.
    # ${mfem_dev}'+threadsafe'
)


builds_cuda=(
    # hypre without cuda:
    ${mfem}'+cuda cuda_arch='"${cuda_arch}"

    # hypre with cuda:
    ${mfem}'+cuda cuda_arch='"${cuda_arch} ^hypre+cuda"

    # hypre with cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    ${mfem}'+cuda+raja+occa cuda_arch='"${cuda_arch}"' \
        ^raja+cuda~openmp ^hypre+cuda'

    # hypre without cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when the unit test is fixed.
    # TODO: add back "+petsc+slepc $petsc_spec_cuda" when it works.
    ${mfem}'+cuda+openmp+raja+occa cuda_arch='"${cuda_arch}"' \
        +strumpack+suite-sparse \
        +sundials+pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+cuda+openmp'" $strumpack_cuda_spec"' \
        '"$hdf5_spec"

    # hypre with cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when we support it with '^hypre+cuda'.
    # TODO: add back "+strumpack $strumpack_cuda_spec" when it's supported.
    # TODO: add back "+petsc+slepc $petsc_spec_cuda" when it works.
    # TODO: add back "+sundials" when it's supported with '^hypre+cuda'.
    ${mfem}'+cuda+openmp+raja+occa cuda_arch='"${cuda_arch}"' \
        +suite-sparse \
        +pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+cuda+openmp ^hypre+cuda \
        '"$hdf5_spec"

    #
    # same builds as above with ${mfem_dev}
    #

    # hypre without cuda:
    ${mfem_dev}'+cuda cuda_arch='"${cuda_arch}"

    # hypre with cuda:
    ${mfem_dev}'+cuda cuda_arch='"${cuda_arch} ^hypre+cuda"

    # hypre with cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    ${mfem_dev}'+cuda+raja+occa cuda_arch='"${cuda_arch}"' \
        ^raja+cuda~openmp ^hypre+cuda'

    # hypre without cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when the unit test is fixed.
    # TODO: add back "+petsc+slepc $petsc_spec_cuda" when it works.
    ${mfem_dev}'+cuda+openmp+raja+occa cuda_arch='"${cuda_arch}"' \
        +strumpack+suite-sparse \
        +sundials+pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+cuda+openmp'" $strumpack_cuda_spec"' \
        '"$hdf5_spec"

    # hypre with cuda:
    # TODO: restore '+libceed' when the libCEED CUDA unit tests take less time.
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when we support it with '^hypre+cuda'.
    # TODO: add back "+strumpack $strumpack_cuda_spec" when it's supported.
    # TODO: add back "+petsc+slepc $petsc_spec_cuda" when it works.
    # TODO: add back "+sundials" when it's supported with '^hypre+cuda'.
    ${mfem_dev}'+cuda+openmp+raja+occa cuda_arch='"${cuda_arch}"' \
        +suite-sparse \
        +pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+cuda+openmp ^hypre+cuda \
        '"$hdf5_spec"
)


builds_rocm=(
    # hypre without rocm:
    ${mfem}'+rocm amdgpu_target='"${rocm_arch}"

    # hypre with rocm:
    ${mfem}'+rocm amdgpu_target='"${rocm_arch} ^hypre+rocm"

    # hypre with rocm:
    ${mfem}'+rocm+raja+occa+libceed amdgpu_target='"${rocm_arch}"' \
        ^raja+rocm~openmp ^occa~cuda ^hypre+rocm'

    # hypre without rocm:
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when the unit test is fixed.
    # TODO: add "+petsc+slepc $petsc_spec_rocm" when it is supported.
    ${mfem}'+rocm+openmp+raja+occa+libceed amdgpu_target='"${rocm_arch}"' \
        +strumpack+suite-sparse \
        +sundials+pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+rocm~openmp ^occa~cuda'" $strumpack_rocm_spec"' \
        '"$hdf5_spec"

    # hypre with rocm:
    # TODO: add back '+gslib' when the gslib test is fixed.
    # TODO: restore '+superlu-dist' when we support it with '^hypre+rocm'.
    # TODO: add back "+strumpack $strumpack_rocm_spec" when it's supported.
    # TODO: add back "+petsc+slepc $petsc_spec_rocm" when it works.
    # TODO: add back "+sundials" when it's supported with '^hypre+rocm'.
    ${mfem}'+rocm+openmp+raja+occa+libceed amdgpu_target='"${rocm_arch}"' \
        +suite-sparse \
        +pumi+mpfr+netcdf+zlib+gnutls+libunwind+conduit \
        ^raja+rocm~openmp ^occa~cuda ^hypre+rocm \
        '"$hdf5_spec"

    #
    # same builds as above with ${mfem_dev}
    #

    # TODO
)


trap 'printf "\nScript interrupted.\n"; exit 33' INT

SEP='=========================================================================='
sep='--------------------------------------------------------------------------'

run_builds=("${builds[@]}" "${builds2[@]}")
# run_builds=("${builds_cuda[@]}")
# run_builds=("${builds_rocm[@]}")

for bld in "${run_builds[@]}"; do
    printf "\n%s\n" "${SEP}"
    printf "    %s\n" "${bld}"
    printf "%s\n" "${SEP}"
    eval bbb="\"${bld}\""
    spack spec -I $bbb || exit 1
    printf "%s\n" "${sep}"
    spack install $spack_jobs --test=root $bbb || exit 2
done

# Uninstall all mfem builds:
# spack uninstall --all mfem
