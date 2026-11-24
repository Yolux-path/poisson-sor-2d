module solver
    use :: precision, only : PR, PI
    use :: fonction, only : big_F, big_sol_exat
    implicit none(type, external)

    private
    public :: init, endit, resoudre_poisson_sor, calculer_erreur, resoudre_poisson_sor_V2

contains

    subroutine init(n, h, x, y, U)
        integer, intent(in) :: n
        real(PR), intent(out) :: h
        real(PR), dimension(:), allocatable, intent(out) :: x, y
        real(PR), dimension(:,:), allocatable, intent(out) :: U
        integer :: i

        allocate(x(0:n), y(0:n), U(0:n, 0:n))
        
        h = 1.0_PR / real(n, PR) 
        x = [( i * h, i = 0, n )]
        y = [( i * h, i = 0, n )]
        
        U = 0.0_PR
    end subroutine init

    subroutine endit (x, y, U)
        real(PR), dimension(:), allocatable, intent(inout) :: x, y
        real(PR), dimension(:,:), allocatable, intent(inout) :: U
        deallocate(x, y, U)
    end subroutine endit

    subroutine resoudre_poisson_sor(n, h, x, y, U, f)
        integer, intent(in) :: n
        real(PR), intent(in) :: h
        real(PR), intent(in) :: x(0:n), y(0:n)
        real(PR), intent(inout) :: U(0:n, 0:n)
        procedure(big_F) :: f

        integer :: i, j, iter
        real(PR), allocatable :: FF(:,:)
        integer, parameter :: max_iter = 1000000
        real(PR), parameter :: tol = 1.0e-10_PR
        real(PR) :: omega, max_diff, temp_val, diff, h2

        h2 = h*h

        allocate(FF(0:n, 0:n))

        do j = 1, n - 1
            do i = 1, n - 1
                FF(i,j) = f(x(i), y(j))
            end do
        end do

        
        ! Paramètre de relaxation optimal de SOR pour un domaine carré
        omega = 2.0_PR / (1.0_PR + sin(PI * h))

        do iter = 1, max_iter
            max_diff = 0.0_PR
            
            do j = 1, n - 1
                do i = 1, n - 1
                    ! équation discrétisée (5)
                    temp_val = 0.25_PR * (U(i-1, j) + U(i+1, j) + U(i, j-1) + U(i, j+1) + h2 * FF(i,j))                    
                    ! Mise à jour avec relaxation
                    diff = omega * (temp_val - U(i, j))
                    U(i, j) = U(i, j) + diff
                    
                    ! Suivi de la convergence
                    if (abs(diff) > max_diff) then
                        max_diff = abs(diff)
                    end if
                end do
            end do
            
            ! Arrêt si la tolérance est atteinte
            if (max_diff < tol) exit
        end do
        
        !print*, "Convergence atteinte en", iter, "itérations."
        deallocate(FF)
    end subroutine resoudre_poisson_sor

    subroutine resoudre_poisson_sor_V2(n, h, x, y, U, f)

        integer, intent(in) :: n
        real(PR), intent(in) :: h
        real(PR), intent(in) :: x(0:n), y(0:n)
        real(PR), intent(inout) :: U(0:n, 0:n)
        procedure(big_F) :: f

        integer :: i, j, iter
        integer, parameter :: max_iter = 10000
        integer, parameter :: check_freq = 5

        real(PR), parameter :: tol_res = 1.0e-8_PR

        real(PR) :: omega
        real(PR) :: temp_val
        real(PR) :: h2
        real(PR) :: res
        real(PR) :: max_res
        real(PR) :: max_f
        real(PR) :: res_rel

        real(PR), allocatable :: FF(:,:)

        h2 = h*h

        allocate(FF(0:n,0:n))

        do j = 1, n-1
            do i = 1, n-1
                FF(i,j) = f(x(i), y(j))
            end do
        end do

        omega = 2.0_PR / (1.0_PR + sin(PI*h))

        res_rel = huge(1.0_PR)

        do iter = 1, max_iter

            do j = 1, n-1
                do i = 1, n-1

                    temp_val = 0.25_PR * ( &
                        U(i-1,j) + U(i+1,j) + &
                        U(i,j-1) + U(i,j+1) + &
                        h2 * FF(i,j) )

                    U(i,j) = U(i,j) + &
                        omega * (temp_val - U(i,j))

                end do
            end do

            if (mod(iter, check_freq) == 0) then

                max_res = 0.0_PR
                max_f = 0.0_PR

                do j = 1, n-1
                    do i = 1, n-1

                        res = ( &
                            4.0_PR * U(i,j) &
                            - U(i-1,j) &
                            - U(i+1,j) &
                            - U(i,j-1) &
                            - U(i,j+1) ) / h2 &
                            - FF(i,j)

                        max_res = max(max_res, abs(res))
                        max_f = max(max_f, abs(FF(i,j)))

                    end do
                end do

                res_rel = max_res / max(max_f, 1.0e-14_PR)

                if (res_rel < tol_res) exit

            end if

        end do

        print *, "Iterations =", iter
        print *, "omega =", omega
        print *, "Residue relatif =", res_rel

        deallocate(FF)

    end subroutine resoudre_poisson_sor_V2


    subroutine calculer_erreur(n, h, x, y, U, sol_exacte)
        integer, intent(in)  :: n
        real(PR), intent(in) :: h
        real(PR), intent(in) :: x(0:n), y(0:n)
        real(PR), intent(in) :: U(0:n, 0:n)
        procedure(big_sol_exat) :: sol_exacte
        
        integer  :: i, j
        real(PR) :: erreur_l2, diff
        
        erreur_l2  = 0.0_PR
        
        do j = 1, n
            do i = 0, n
                diff = abs(U(i, j) - sol_exacte(x(i), y(j)))
                erreur_l2 = erreur_l2 + (diff*diff)
            end do
        end do
        
        ! équation (7)
        erreur_l2 = h*sqrt(erreur_l2)
        
        print*, "--------------------------------------------------"
        print*, "Bilan pour la grille N =", n
        print*, "  -> Erreur Norme L2     :", erreur_l2
        print*, "--------------------------------------------------"
    end subroutine calculer_erreur
end module solver