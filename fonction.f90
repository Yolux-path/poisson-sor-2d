module fonction

    use :: precision, only : PR, PI

    implicit none(type, external)

    private

    abstract interface
        real(PR) function big_F(x,y) result(z)
            import :: PR
            implicit none(type,external)
            real(PR), intent(in) :: x,y
        end function big_F
    end interface


    abstract interface
        real(PR) function big_sol_exat(x,y) result(z)
            import :: PR
            implicit none(type,external)
            real(PR), intent(in) :: x,y
        end function big_sol_exat
    end interface


    public :: big_F,big_sol_exat, f1, f2, sol_exacte_1, sol_exacte_2

contains

    ! Fonction f1
    real(PR) function f1(x,y)
        real(PR), intent(in) :: x, y

        f1 = 10*(PI*PI)*sin(3*PI*x)*sin(PI*y)
    end function f1

    ! Fonction f2
    real(PR) function f2(x, y)
        real(PR), intent(in) :: x, y

        f2 = 2*(x*(1-x)+y*(1-y))
    end function f2

    real(PR) function sol_exacte_1(x,y)

        real(PR), intent(in) :: x, y

        sol_exacte_1 = sin(3*PI*x)*sin(PI*y)
        
    end function sol_exacte_1

    real(PR) function sol_exacte_2(x,y)

        real(PR), intent(in) :: x, y

        sol_exacte_2 = x*(1-x)*y*(1-y)

    end function sol_exacte_2

end module fonction
