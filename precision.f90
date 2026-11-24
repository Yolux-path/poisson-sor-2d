module precision

    use, intrinsic :: iso_fortran_env, only: real64

    implicit none (type, external)

    private

    public :: PR, PI

    integer, parameter :: PR = real64

    real(PR), parameter:: PI = 4._PR * atan(1._PR)


end module precision
