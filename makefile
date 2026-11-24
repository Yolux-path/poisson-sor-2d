FC = gfortran

# DRAPEAUX D'OPTIMISATION FINALE
# -O3  /Ofast        : Optimisation agressive (vectorisation, déroulage de boucles).
# -march=native : Utilise toutes les instructions de votre CPU (AVX2, AVX-512, etc.).
# -flto         : Optimisation globale inter-fichiers (Link-Time Optimization).
# -ffast-math   : Accélère les calculs flottants (au détriment d'une stricte conformité IEEE).
FFLAGS = -O3 -march=native -flto -ffast-math
LDFLAGS = -flto

# Fichiers Sources
SRCS = precision.f90 fonction.f90 solver.f90 convergence_edp.f90

# Fichiers Objets
OBJS = $(SRCS:.f90=.o)

# Exécutable
EXEC = exe

# Règle par défaut
all: $(EXEC)

# Compilation des fichiers sources en fichiers objets
%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@

# Édition de liens
$(EXEC): $(OBJS)
	$(FC) $(LDFLAGS) $^ -o $@

# --- GESTION DES DÉPENDANCES FORTRAN ---
fonction.o: precision.o
solver.o: fonction.o precision.o
convergence_edp.o: solver.o fonction.o precision.o

# Nettoyage
clean:
	rm -f $(OBJS) $(EXEC)

cleanall: clean
	rm -f *.mod

# Outils de qualité de code (Fortitude)
check: 
	fortitude check $(SRCS)

fix:
	fortitude check --fix $(SRCS)
