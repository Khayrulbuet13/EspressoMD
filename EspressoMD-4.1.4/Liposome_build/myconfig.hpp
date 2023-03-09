
/* Generic features */
#define EXTERNAL_FORCES
#define MASS
//#define EXCLUSIONS
#define BOND_CONSTRAINT
#define LANGEVIN_PER_PARTICLE
//#define COLLISION_DETECTION
//#define METADYNAMICS
#define NPT
//#define SWIMMER_REACTIONS
//#define ENGINE
//#define PARTICLE_ANISOTROPY

/* Rotation */
//#define ROTATION
//#define ROTATIONAL_INERTIA

/* Electrostatics */
//#define ELECTROSTATICS
//#define MMM1D_GPU
//#define _P3M_GPU_FLOAT

/* Magnetostatics */
//#define DIPOLES


/* Virtual sites features */
//#define VIRTUAL_SITES
//#define VIRTUAL_SITES_RELATIVE

//#define VIRTUAL_SITES_INERTIALESS_TRACERS

/* DPD features */
//#define DPD

/* Lattice-Boltzmann features */
#define LB_BOUNDARIES
#define LB_BOUNDARIES_GPU
//#define LB_ELECTROHYDRODYNAMICS
//#define ELECTROKINETICS
//#define EK_BOUNDARIES
//#define EK_DEBUG
//#define EK_DOUBLE_PREC

/* Interaction features */
//#define TABULATED
#define LENNARD_JONES
//#define WCA
//#define LENNARD_JONES_GENERIC
//#define LJCOS
#define LJCOS2
//#define LJGEN_SOFTCORE
//#define SMOOTH_STEP
//#define HERTZIAN
//#define GAUSSIAN
//#define BMHTF_NACL
#define MORSE
//#define BUCKINGHAM
#define SOFT_SPHERE
//#define HAT
//#define UMBRELLA
//#define GAY_BERNE
//#define OVERLAPPED
//#define THOLE

/* Fluid-Structure Interactions (object in fluid) */
//#define AFFINITY
#define MEMBRANE_COLLISION

/* Immersed-Boundary Bayreuth version */
//#define SCAFACOS_DIPOLES

#define EXPERIMENTAL_FEATURES

/* Strange features. Use only if you know what you are doing! */
/* turn off certain nonbonded interactions within molecules */
//#define NO_INTRA_NB

/* Debugging */
//#define ADDITIONAL_CHECKS

