[Mesh]
  active = 'mesh'
  [./mesh]
   dim = 1
   type = GeneratedMeshGenerator
   nx = 1e4
   xmax = 10e-6 # 100 micron thickness of solid electrolyte
  [../]
[]

[Variables]
  [./phi]
  order = FIRST
  family = LAGRANGE
  initial_condition = 0.01
  [../]
  [./cpos]
  order	= FIRST
  family = LAGRANGE
  initial_condition = 1e-6
  [../]
  [./cneg]
  order	= FIRST
  family = LAGRANGE
  initial_condition = 1e-6
  [../]
[]
  
[AuxVariables]
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
[]
  
[Bounds]
  [cpos_upper_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = cpos
    bound_type = upper
    bound_value = 1
  []
  [cpos_lower_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = cpos
    bound_type = lower
    bound_value = 0
  []
  [cneg_upper_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = cneg
    bound_type = upper
    bound_value = 1
  []
  [cneg_lower_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = cneg
    bound_type = lower
    bound_value = 0
  []
[]
 
[Kernels]
  active = 'diff rhobyeps_term chempot_eqbm chempotvalue'
  [./diff]
    type = Diffusion
    variable = phi
  [../]
  [./rhobyeps_term]
    type = MaskedBodyForce
    variable = phi
    value = 1.0
    mask = rhobyeps
    coupled_variables = 'cpos cneg'
  [../]
    #will set mupos = -muneg
  [./chem_pot_eqbm]
    type = ChemPotEqual
    variable = cneg 
    mua = mu_neg # mua is for the coupled variable
    mub = mu_pos
    args = 'phi cpos'
  [../]
  #will set mu equal to mu_target
  [./chempotvalue2]
    type = ChemPotValue
    variable = cneg
    mutarget = mutarget
    mu = mu_neg
  [../]
  [./chempotvalue]
    type = ChemPotValue
    variable = cpos
    mutarget = mutarget
    mu = mu_pos
  [../]
[]
  
[Materials]
  [./consts]
    type = ADGenericConstantMaterial
    prop_names =      'eps       N          kT       e      zpos zneg mu0_pos   mu0_neg   mutarget'
    prop_values = '1.328e-10 5.98412e28 4.142e-21 1.602e-19  1    1   3.0e-19   3.0e-19   1.6e-19'
  [../]
    [./chempot_pos]
     type = ADDerivativeParsedMaterial
     property_name = 'mu_pos'
     coupled_variables = 'phi cpos'
     material_property_names = 'mu0_pos kT zpos e'
     expression = 'mu0_pos + kT * log( cpos / (1-cpos) ) + zpos * e * phi'
     derivative_order = 2
     outputs = exodus
  [../]
  [./chempot_neg]
     type = ADDerivativeParsedMaterial
     property_name = 'mu_neg'
     coupled_variables = 'phi cneg'
     material_property_names = 'mu0_neg kT zneg e'
     expression = 'mu0_neg + kT * log( cneg / (1-cneg) ) - zneg * e * phi'
     derivative_order = 2
     outputs = exodus
  [../]
  #Need to convert e and eps to non-AD for the next material
  [./convert_to_AD]
     type = MaterialADConverter
     ad_props_in = 'e eps N'
     reg_props_out = 'e_reg eps_reg N_reg'
  [../]
  [./rhobyeps_f]
    type = DerivativeParsedMaterial
    property_name = 'rhobyeps'
    coupled_variables = 'phi cpos cneg'
    material_property_names = 'e_reg eps_reg N_reg'
    expression = 'e_reg * N_reg * ( cpos - cneg )/eps_reg'
    derivative_order = 2
    outputs = exodus
  [../]
[]
  
[BCs]
  [./left]
    type = DirichletBC
    variable = phi
    boundary = left
    value = 0.1000
  [../]
  [./right]
    type = DirichletBC
    variable = phi
    boundary = 'right'
    value = -0.1
  [../]
[]

[Preconditioning]
  [./SMP]
  type = SMP
  full = true
#  petsc_options = '-snes_monitor -ksp_monitor_true_residual -snes_converged_reason -ksp_converged_reason'
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      121                  preonly       lu           4'
  [../]
[]

[Executioner]
  automatic_scaling = true
  type = Steady
#  end_time = 10.0
#  dt = 0.1
#  scheme = bdf2
  verbose = True
  solve_type = 'Newton'
  l_max_its = 50
  l_tol = 1e-6
  nl_max_its = 50
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-12
  petsc_options = '-snes_monitor -ksp_monitor_true_residual -snes_converged_reason -ksp_converged_reason'
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly      lu          4'
#  line_search = 'none'
[]
			       
[Outputs]
  execute_on = 'final'
  exodus = true
[]

[Debug]
  show_material_props = true
  show_var_residual_norms = true
[]

