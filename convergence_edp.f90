program convergence_edp
    use :: precision, only : PR
    use :: solver, only : init, endit, resoudre_poisson_sor, calculer_erreur, resoudre_poisson_sor_V2
    use :: fonction, only : f1, sol_exacte_1, f2, sol_exacte_2

    implicit none (type, external)

    integer :: n
    character(len=16) :: arg
    real(PR) :: h
    real(PR), dimension(:), allocatable :: x, y
    real(PR), dimension(:,:), allocatable :: U

    ! Taille de grille : ./exe [n]
    n = 512
    if (command_argument_count() >= 1) then
        call get_command_argument(1, arg)
        read(arg, *) n
    end if

    call init(n, h, x, y, U)

    ! Résolution itérative Matrix-Free 
    call resoudre_poisson_sor(n, h, x, y, U, f1)  !f1 ou f2!! 

    ! Vérification de la solution eq (7)
    call calculer_erreur(n, h, x, y, U, sol_exacte_1) !sol_exacte_1 ou sol_exacte_2 !! 
    
    call endit(x, y, U)

end program convergence_edp