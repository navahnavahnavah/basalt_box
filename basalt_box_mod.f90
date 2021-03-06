module basalt_box_mod
	implicit none

	INCLUDE "IPhreeqc.f90.inc"
save



contains


! ----------------------------------------------------------------------------------%%
!
! RUN_BOX
!
! ----------------------------------------------------------------------------------%%

function run_box(primary_in, secondary_in, solute_in, solute0_in, medium_in, g_pri, g_sec, g_sol, g_med, n_box, alt_num, temp_in, area_in, mix_in, timestep_in, param_exp_string_in, param_exp1_string_in)
	integer :: g_pri, g_sec, g_sol, g_med, n_box, alt_num
	integer :: i, ii, j, jj, n
	real(4) :: solute0_in(g_sol), solute_step(g_sol,n_box)
	real(4) :: primary_in(g_pri,n_box), secondary_in(g_sec,n_box), solute_in(g_sol,n_box), medium_in(g_med,n_box)
	real(4) :: temp_in(n_box), area_in(n_box), mix_in(n_box), timestep_in, dt

	real(4) :: p_out(n_box,alt_num)
	real(4) :: run_box(n_box,alt_num)
	INTEGER(KIND=4) :: id
	real(4) :: out_mat(4,alt_num)
	!real(4) :: solute_inter(tn)
	character(len=25) :: s_precip = "0.00"

	! STRINGS
	character(len=25) :: s_verm_ca, s_analcime, s_phillipsite, s_clinozoisite, s_verm_na
	character(len=25) :: s_diopside, s_epidote, s_minnesotaite, s_ferrite_ca, s_foshagite
	character(len=25) :: s_gismondine, s_gyrolite, s_hedenbergite, s_chalcedony, s_verm_mg
	character(len=25) :: s_ferrihydrite, s_lawsonite, s_merwinite, s_monticellite, s_natrolite
	character(len=25) :: s_talc, s_smectite_low, s_prehnite, s_chlorite, s_rankinite
	character(len=25) :: s_scolecite, s_tobermorite_9a, s_tremolite, s_chamosite7a, s_clinochlore14a
	character(len=25) :: s_clinochlore7a, s_andradite
	character(len=25) :: s_saponite_ca, s_troilite, s_pyrrhotite, s_lepidocrocite, s_daphnite_7a
	character(len=25) :: s_daphnite_14a, s_verm_k, s_greenalite, s_aragonite
	character(len=25) :: s_siderite, s_kaolinite, s_goethite, s_dolomite, s_celadonite
	character(len=25) :: s_sio2, s_albite, s_calcite, s_mont_na, s_smectite, s_saponite
	character(len=25) :: s_stilbite, s_saponite_k, s_anhydrite, s_clinoptilolite, s_pyrite
	character(len=25) :: s_quartz, s_kspar, s_saponite_na, s_nont_na, s_nont_mg, s_nont_k
	character(len=25) :: s_fe_celadonite, s_nont_ca, s_muscovite, s_mesolite, s_hematite, s_diaspore
	character(len=25) :: s_fe_saponite_ca, s_fe_saponite_mg
	character(len=25) :: s_feldspar, s_pigeonite, s_augite, s_glass, s_basalt1, s_magnetite ! primary
	character(len=25) :: s_basalt2, s_basalt3
	character(len=25) :: s_laumontite, s_mont_k, s_mont_mg, s_mont_ca
	character(len=25) :: s_temp, s_timestep, s_area ! important information
	character(len=25) :: s_ph, s_ca, s_mg, s_na, s_k, s_fe, s_s, s_si, s_cl, s_al, s_alk, s_co2 ! solutes
	character(len=25) :: s_hco3, s_co3
	character(len=25) :: s_water, s_w ! medium
	character(len=25) :: param_exp_string_in, param_exp1_string_in
	character(len=25) :: kinetics

	CHARACTER(LEN=10000) :: line
	character(len=45000) :: input_string

	character(len=59000) :: L5

	character(len=25) :: ol_k1, ol_e1, ol_n1, ol_k2, ol_e2, ol_k3, ol_e3, ol_n3
	character(len=25) :: pyr_k1, pyr_e1, pyr_n1, pyr_k2, pyr_e2, pyr_k3, pyr_e3, pyr_n3
	character(len=25) :: plag_k1, plag_e1, plag_n1, plag_k2, plag_e2, plag_k3, plag_e3, plag_n3
	character(len=25) :: exp_ol1, exp_ol2, exp_ol3, exp_ol
	character(len=25) :: exp_pyr1, exp_pyr2, exp_pyr3, exp_pyr
	character(len=25) :: exp_plag1, exp_plag2, exp_plag3, exp_plag

	!# limiter declare
	! real(4) :: sec_vol_total, pri_vol_total

	exp_ol1 = "0.01"
	exp_ol2 = "0.001"
	exp_ol3 = "0.01"

	exp_pyr1 = "0.01"
	exp_pyr2 = "0.001"
	exp_pyr3 = "0.01"

	exp_plag1 = "0.01"
	exp_plag2 = "0.001"
	exp_plag3 = "0.01"

	ol_k1 = "10.0^(-4.8)"
	ol_e1 = "94.4"
	ol_n1 = "1.0"
	ol_k2 = "10.0^(-12.8)"
	ol_e2 = "94.4"
	ol_k3 = ""
	ol_e3 = ""
	ol_n3 = ""

	pyr_k1 = "10.0^(-6.82)"
	pyr_e1 = "78.0"
	pyr_n1 = "0.7"
	pyr_k2 = "10.0^(-11.97)"
	pyr_e2 = "78.0"
	pyr_k3 = ""
	pyr_e3 = ""
	pyr_n3 = ""

	plag_k1 = "10.0^(-7.87)"
	plag_e1 = "42.1"
	plag_n1 = "0.626"
	plag_k2 = "10.0^(-10.91)"
	plag_e2 = "45.2"
	plag_k3 = ""
	plag_e3 = ""
	plag_n3 = ""



	L5 = "#  $Id: llnl.dat 4023 2010-02-09 21:02:42Z dlpark $" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"LLNL_AQUEOUS_MODEL_PARAMETERS" //NEW_LINE('')// &
         &"-temperatures" //NEW_LINE('')// &
         &"         0.0100   25.0000   60.0000  100.0000" //NEW_LINE('')// &
         &"       150.0000  200.0000  250.0000  300.0000" //NEW_LINE('')// &
       !  &"#debye huckel a (adh)" //NEW_LINE('')// &
         &"-dh_a" //NEW_LINE('')// &
         &"         0.4939    0.5114    0.5465    0.5995" //NEW_LINE('')// &
         &"         0.6855    0.7994    0.9593    1.2180" //NEW_LINE('')// &
       !  &"#debye huckel b (bdh)" //NEW_LINE('')// &
         &"-dh_b" //NEW_LINE('')// &
         &"         0.3253    0.3288    0.3346    0.3421" //NEW_LINE('')// &
         &"         0.3525    0.3639    0.3766    0.3925" //NEW_LINE('')// &
         &"-bdot" //NEW_LINE('')// &
         &"         0.0374    0.0410    0.0438    0.0460" //NEW_LINE('')// &
         &"         0.0470    0.0470    0.0340    0.0000" //NEW_LINE('')// &
       !  &"#cco2   (coefficients for the Drummond (1981) polynomial)" //NEW_LINE('')// &
         &"-co2_coefs" //NEW_LINE('')// &
         &"        -1.0312              0.0012806" //NEW_LINE('')// &
         &"          255.9                 0.4445" //NEW_LINE('')// &
         &"      -0.001606" //NEW_LINE('')// &
         &"NAMED_EXPRESSIONS" //NEW_LINE('')// &
       !  &"#" //NEW_LINE('')// &
       !  &"# formation of O2 from H2O " //NEW_LINE('')// &
       !  &"# 2H2O =  O2 + 4H+ + 4e-  " //NEW_LINE('')// &
       !  &"#" //NEW_LINE('')// &
         &"	Log_K_O2" //NEW_LINE('')// &
         &"	 	log_k      -85.9951" //NEW_LINE('')// &
         &"		-delta_H	559.543	kJ/mol	# 	O2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-2.9 kcal/mol" //NEW_LINE('')// &
         &"	        -analytic   38.0229    7.99407E-03   -2.7655e+004  -1.4506e+001  199838.45" //NEW_LINE('')// &
       !  &"#	Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"SOLUTION_MASTER_SPECIES" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
       !  &"#element species        alk     gfw_formula     element_gfw" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Al       Al+3           0.0     Al              26.9815" //NEW_LINE('')// &
                                  !&"Alkalinity HCO3-        1.0     Ca0.5(CO3)0.5   50.05" //NEW_LINE('')// &
         &"Alkalinity	CO3-2	1.0			Ca0.5(CO3)0.5	50.05" //NEW_LINE('')// &
         ! &"C(-4)	CH4		0.0	CH4" //NEW_LINE('')// &
         ! &"C(-3)	C2H6		0.0	C2H6" //NEW_LINE('')// &
         ! &"C(-2)	C2H4		0.0	C2H4" //NEW_LINE('')// &
         &"C        HCO3-          1.0     HCO3            12.0110" //NEW_LINE('')// &
         !&"C        CO3-2          1.0     HCO3            12.0110" //NEW_LINE('')// &
         ! &"C(+2)	 CO		0	C" //NEW_LINE('')// &
         &"C(+4)    HCO3-          1.0     HCO3" //NEW_LINE('')// &
         !&"C(+4)    CO3-2          1.0     HCO3" //NEW_LINE('')// &
         &"Ca       Ca+2           0.0     Ca              40.078" //NEW_LINE('')// &
         &"Cl       Cl-            0.0     Cl              35.4527" //NEW_LINE('')// &
         &"Cl(-1)	 Cl-		0	Cl" //NEW_LINE('')// &
         &"Cl(1)	 ClO-		0	Cl" //NEW_LINE('')// &
         &"Cl(3)	 ClO2-		0	Cl" //NEW_LINE('')// &
         &"Cl(5)	 ClO3-		0	Cl" //NEW_LINE('')// &
         &"Cl(7)	 ClO4-		0	Cl" //NEW_LINE('')// &
         &"E        e-             0.0     0.0             0.0" //NEW_LINE('')// &
         &"Fe       Fe+2           0.0     Fe              55.847" //NEW_LINE('')// &
         &"Fe(+2)   Fe+2           0.0     Fe" //NEW_LINE('')// &
         &"Fe(+3)   Fe+3           -2.0    Fe" //NEW_LINE('')// &
         &"H        H+             -1.     H               1.0079" //NEW_LINE('')// &
         &"H(0)     H2             0.0     H" //NEW_LINE('')// &
         &"H(+1)    H+             -1.     0.0" //NEW_LINE('')// &
         &"K        K+             0.0     K               39.0983" //NEW_LINE('')// &
         &"Mg       Mg+2           0.0     Mg              24.305" //NEW_LINE('')// &
         &"Na       Na+            0.0     Na              22.9898" //NEW_LINE('')// &
         &"O        H2O            0.0     O               15.994" //NEW_LINE('')// &
         &"O(-2)    H2O            0.0     0.0" //NEW_LINE('')// &
         &"O(0)     O2             0.0     O" //NEW_LINE('')// &
         &"S	 SO4-2          0.0     SO4             32.066" //NEW_LINE('')// &
         &"S(-2)	 HS-            1.0     S" //NEW_LINE('')// &
         &"S(+2)	 S2O3-2		0.0	S" //NEW_LINE('')// &
         &"S(+3)	 S2O4-2		0.0	S" //NEW_LINE('')// &
         &"S(+4)	 SO3-2		0.0	S" //NEW_LINE('')// &
         &"S(+5)	 S2O5-2		0.0	S" //NEW_LINE('')// &
         &"S(+6)	 SO4-2          0.0     SO4" //NEW_LINE('')// &
         &"S(+7)	 S2O8-2		0.0	S" //NEW_LINE('')// &
         &"S(+8)	 HSO5-		0.0	S" //NEW_LINE('')// &
         &"Si       SiO2         0.0     SiO2            28.0855" //NEW_LINE('')// &
         !&"Si		H4SiO4	0.0	SiO2		28.0843" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         !-DB SOLUTION SPECIES
         &"SOLUTION_SPECIES" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &

         &"H2O + 0.01e- = H2O-0.01" //NEW_LINE('')// &
         &"	log_k -9" //NEW_LINE('')// &

         &"Al+3 =  Al+3 " //NEW_LINE('')// &
         &"	-llnl_gamma	9.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Al+3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-128.681 kcal/mol" //NEW_LINE('')// &
         &"-Vm  -3.3404  -17.1108  14.9917  -2.0716  2.8711 9 # supcrt" //NEW_LINE('')// &


         &"Ca+2 =  Ca+2 " //NEW_LINE('')// &
         &"	-llnl_gamma	6.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Ca+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-129.8 kcal/mol" //NEW_LINE('')// &
         !&"	-millero -19.69 0.1058 -0.001256 1.617 -0.075 0.0008262" //NEW_LINE('')// &
         &"-Vm  -0.3456  -7.252  6.149  -2.479  1.239  5  1.60  -57.1  -6.12e-3  1 # supcrt modified" //NEW_LINE('')// &


         &"Cl- =  Cl- " //NEW_LINE('')// &
         &"	-llnl_gamma	3.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Cl-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-39.933 kcal/mol" //NEW_LINE('')// &
         !&"	-millero 16.37 0.0896 -0.001264 -1.494 0.034 -0.000621" //NEW_LINE('')// &
         &"-Vm  4.465  4.801  4.325  -2.847  1.748  0  -0.331  20.16  0  1 # supcrt modified" //NEW_LINE('')// &


         &"e- =  e- " //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol		e-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kJ/mol" //NEW_LINE('')// &

         &"Fe+2 =  Fe+2 " //NEW_LINE('')// &
         &"	-llnl_gamma	6.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Fe+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-22.05 kcal/mol" //NEW_LINE('')// &
         &"-Vm  -0.3255  -9.687  1.536  -2.379  0.3033  5.5  -4.21e-2  37.96  0  1 # supcrt modified" //NEW_LINE('')// &


         &"H+ =  H+ " //NEW_LINE('')// &
         &"	-llnl_gamma	9.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	H+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kJ/mol" //NEW_LINE('')// &

         &"HCO3- =  HCO3- " //NEW_LINE('')// &
         &"	-llnl_gamma	4.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	HCO3-" //NEW_LINE('')// &
         !&"-Vm  5.224  0  0  -5.85  5.126  0  0.404  110  -5.74e-3  1 # supcrt modified" //NEW_LINE('')// &
         ! not entirely sure about carbonate vs. bicarbonate decision here...

         ! &"CO3-2 =  CO3-2 " //NEW_LINE('')// &
         ! &"	-llnl_gamma	5.4	" //NEW_LINE('')// &
         ! &"	log_k 0" //NEW_LINE('')// &
         ! &"	-delta_H	0	kJ/mol	# 	CO3-2" //NEW_LINE('')// &
         ! &"-Vm  5.224  0  0  -5.85  5.126  0  0.404  110  -5.74e-3  1 # supcrt modified" //NEW_LINE('')// &

         ! &"#	Enthalpy of formation:	-164.898 kcal/mol" //NEW_LINE('')// &
         &"K+ =  K+ " //NEW_LINE('')// &
         &"	-llnl_gamma	3.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	K+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-60.27 kcal/mol" //NEW_LINE('')// &
         !&"	-millero 7.26 0.0892 -0.000736 2.722 -0.101 0.00151" //NEW_LINE('')// &
         &"-Vm  3.322  -1.473  6.534  -2.712  9.06e-2  3.5  0  29.7  0  1 # supcrt modified" //NEW_LINE('')// &

         &"Mg+2 =  Mg+2 " //NEW_LINE('')// &
         &"	-llnl_gamma	8.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Mg+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-111.367 kcal/mol" //NEW_LINE('')// &
         !&"	-millero -22.32 0.0868 -0.0016 2.017 -0.125 0.001457" //NEW_LINE('')// &
         &"-Vm  -1.410  -8.6  11.13  -2.39  1.332  5.5  1.29  -32.9  -5.86e-3  1 # supcrt modified" //NEW_LINE('')// &

         &"Na+ =  Na+ " //NEW_LINE('')// &
         &"	-llnl_gamma	4.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	Na+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-57.433 kcal/mol" //NEW_LINE('')// &
         !&"	-millero -3.46 0.1092 -0.000768 2.698 -0.106 0.001651" //NEW_LINE('')// &
         &"-Vm  1.403  -2.285  4.419  -2.726  -5.125e-5  4.0  0.162  47.67  -3.09e-3  0.725 # sup" //NEW_LINE('')// &

         &"H2O =  H2O " //NEW_LINE('')// &
         &"	-llnl_gamma	3.0000	" //NEW_LINE('')// &
         &"        log_k   0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	H2O" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-68.317 kcal/mol" //NEW_LINE('')// &
         &"SO4-2 =  SO4-2 " //NEW_LINE('')// &
         &"	-llnl_gamma	4.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	SO4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-217.4 kcal/mol" //NEW_LINE('')// &
         !&"	-millero 9.26 0.284 -0.003808 0.4348 -0.0099143 -8.4762e-05" //NEW_LINE('')// &
         &"-Vm  8.0  2.51  -42.5 5.41  4.23 0 0 0 0 1 # supcrt modified" //NEW_LINE('')// &


         &"SiO2 =  SiO2 " //NEW_LINE('')// &
         &"	-llnl_gamma	3.0000	" //NEW_LINE('')// &
         &"	log_k 0" //NEW_LINE('')// &
         &"	-delta_H	0	kJ/mol	# 	SiO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-209.775 kcal/mol" //NEW_LINE('')// &
         !&"-Vm  10.5  1.7  20  -2.7  0.1291 # supcrt + 2*H2O in a1" //NEW_LINE('')// &
         ! not sure of ion vs. sio2 here

         &"2H2O =  O2 + 4H+ + 4e-  " //NEW_LINE('')// &
         &"	-CO2_llnl_gamma" //NEW_LINE('')// &
         &" 	log_k      -85.9951" //NEW_LINE('')// &
         &"	-delta_H	559.543	kJ/mol	# 	O2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-2.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic   38.0229    7.99407E-03   -2.7655e+004  -1.4506e+001  199838.45" //NEW_LINE('')// &
       !  &"#	Range:  0-300" //NEW_LINE('')// &
         &"-Vm  5.7889  6.3536  3.2528  -3.0417  -0.3943 # supcrt" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.0000 SO4-- + 1.0000 H+  =  HS- +2.0000 O2  " //NEW_LINE('')// &
         &"        -llnl_gamma           3.5    " //NEW_LINE('')// &
         &"        log_k           -138.3169" //NEW_LINE('')// &
         &"	-delta_H	869.226	kJ/mol	# 	HS-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-3.85 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 2.6251e+001 3.9525e-002 -4.5443e+004 -1.1107e+001 3.1843e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         !&"-Vm 8.2 9.2590  2.1108  -3.1618 1.1748  0 -0.3 15 0 1 # supcrt modified" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" .5000 O2 + 2.0000 HS-  = S2--  + H2O" //NEW_LINE('')// &
       !  &"#2 HS- = S2-- +2 H+ + 2e-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           33.2673" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.21730E+02   -0.12307E-02    0.10098E+05   -0.88813E+01    0.15757E+03" //NEW_LINE('')// &
         &"	-mass_balance	S(-2)2" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
       !  &"#	-add_logk	Log_K_O2	0.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"2.0000 H+  + 2.0000 SO3--  = S2O3--  + O2  + H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -40.2906" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2O3-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic  0.77679E+02    0.65761E-01   -0.15438E+05   -0.34651E+02   -0.24092E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         ! ! new
         ! &"CO3-2 + H+ = HCO3-" //NEW_LINE('')// &
         ! &" 	-log_k	10.329" //NEW_LINE('')// &
         ! &"	-delta_H	-3.561	kcal" //NEW_LINE('')// &
         ! &"  -analytic	107.8871	0.03252849	-5151.79	-38.92561	563713.9" //NEW_LINE('')// &
         ! &"-Vm  8.615  0  -12.21 0  1.667  0  0  264  0  1 # supcrt modified" //NEW_LINE('')// &
         !
         ! ! new
         ! &"CO3-2 + 2 H+ = CO2 + H2O" //NEW_LINE('')// &
         ! &" 	-log_k	16.681" //NEW_LINE('')// &
         ! &"	-delta_h -5.738	kcal" //NEW_LINE('')// &
         ! &"  -analytic	464.1965	0.09344813	-26986.16	-165.75951	2248628.9" //NEW_LINE('')// &
         ! &"-Vm  21.78  -49.4  -91.7  31.96 # supcrt modified" //NEW_LINE('')// &

         ! &" H+  + HCO3-  + H2O  = CH4 + 2.0000 O2" //NEW_LINE('')// &
         ! &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         ! &"        log_k            -144.1412" //NEW_LINE('')// &
         ! &"	-delta_H	863.599	kJ/mol	# 	CH4" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-21.01 kcal/mol" //NEW_LINE('')// &
         ! &"	-analytic    -0.41698E+02    0.36584E-01   -0.40675E+05    0.93479E+01   -0.63468E+03" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         !&"-Vm 7.7" //NEW_LINE('')// &
         ! unsure but unimportant


         ! &" CO3-2 + 10 H+ + 8 e- = CH4 + 3 H2O" //NEW_LINE('')// &
         ! &"        -log_k	41.071" //NEW_LINE('')// &
         ! &"	-delta_h -61.039 kcal" //NEW_LINE('')// &
         ! &"	-Vm 7.7" //NEW_LINE('')// &

         ! &"" //NEW_LINE('')// &
         ! &" 2.0000 H+  + 2.0000 HCO3-  + H2O  = C2H6  + 3.5000 O2" //NEW_LINE('')// &
         ! &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         ! &"        log_k            -228.6072" //NEW_LINE('')// &
         ! &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	C2H6" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic    0.10777E+02    0.72105E-01   -0.67489E+05   -0.13915E+02   -0.10531E+04" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &

         ! &"" //NEW_LINE('')// &
         ! &" 2.000 H+  + 2.0000 HCO3-  = C2H4 + 3.0000 O2" //NEW_LINE('')// &
         ! &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         ! &"        log_k            -254.5034" //NEW_LINE('')// &
         ! &"	-delta_H	1446.6	kJ/mol	# 	C2H4" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	24.65 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic    -0.30329E+02    0.71187E-01   -0.73140E+05    0.00000E+00    0.00000E+00" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         ! &" 1.0000 HCO3- + 1.0000 H+  =  CO +1.0000 H2O +0.5000 O2 " //NEW_LINE('')// &
         ! &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         ! &"        log_k           -41.7002" //NEW_LINE('')// &
         ! &"	-delta_H	277.069	kJ/mol	# 	CO" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-28.91 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.0028e+002 4.6877e-002 -1.8062e+004 -4.0263e+001 3.8031e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &

         &" 1.0000 Cl- + 0.5000 O2  =  ClO-   " //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -15.1014" //NEW_LINE('')// &
         &"	-delta_H	66.0361	kJ/mol	# 	ClO-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-25.6 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 6.1314e+001 3.4812e-003 -6.0952e+003 -2.3043e+001 -9.5128e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.0000 O2 + 1.0000 Cl-  =  ClO2-   " //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -23.108" //NEW_LINE('')// &
         &"	-delta_H	112.688	kJ/mol	# 	ClO2-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-15.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 3.3638e+000 -6.1675e-003 -4.9726e+003 -2.0467e+000 -2.5769e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.5000 O2 + 1.0000 Cl-  =  ClO3-   " //NEW_LINE('')// &
         &"        -llnl_gamma           3.5    " //NEW_LINE('')// &
         &"        log_k           -17.2608" //NEW_LINE('')// &
         &"	-delta_H	81.3077	kJ/mol	# 	ClO3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-24.85 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 2.8852e+001 -4.8281e-003 -4.6779e+003 -1.0772e+001 -2.0783e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 2.0000 O2 + 1.0000 Cl-  =  ClO4-   " //NEW_LINE('')// &
         &"        -llnl_gamma           3.5    " //NEW_LINE('')// &
         &"        log_k           -15.7091" //NEW_LINE('')// &
         &"	-delta_H	62.0194	kJ/mol	# 	ClO4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-30.91 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 7.0280e+001 -6.8927e-005 -5.5690e+003 -2.6446e+001 -1.6596e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &" 1.0000 H+ + 1.0000 Fe++ + 0.2500 O2  =  Fe+++ +0.5000 H2O " //NEW_LINE('')// &
         &"        -llnl_gamma           9.0    " //NEW_LINE('')// &
         &"        log_k           +8.4899" //NEW_LINE('')// &
         &"	-delta_H	-97.209	kJ/mol	# 	Fe+3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-11.85 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.7808e+001 -1.1753e-002 4.7609e+003 5.5866e+000 7.4295e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.0000 H2O  =  H2 +0.5000 O2   " //NEW_LINE('')// &
         &"	-CO2_llnl_gamma" //NEW_LINE('')// &
         &"        log_k           -46.1066" //NEW_LINE('')// &
         &"	-delta_H	275.588	kJ/mol	# 	H2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 6.6835e+001 1.7172e-002 -1.8849e+004 -2.4092e+001 4.2501e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.0000 SO4-- + 1.0000 H+ + 0.5000 O2  =  HSO5-  " //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -17.2865" //NEW_LINE('')// &
         &"	-delta_H	140.038	kJ/mol	# 	HSO5-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-185.38 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 5.9944e+001 3.0904e-002 -7.7494e+003 -2.4420e+001 -1.2094e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &" 2.0000 H+  + 2.0000 SO3--  = S2O4--  + .500 O2  + H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           5.0    " //NEW_LINE('')// &
       !  &"#        log_k           -25.2075" //NEW_LINE('')// &
         &"        log_k           -25.2076" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2O4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
       !  &"#        -analytic  -0.15158E+05   -0.31356E+01    0.47072E+06    0.58544E+04    0.73497E+04" //NEW_LINE('')// &
         &"	-analytic	-2.3172e2	2.0393e-3	-7.1011e0	8.3239e1	9.4155e-1" //NEW_LINE('')// &
       !  &"#	changed 3/23/04, corrected to supcrt temperature dependence, GMA" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
       !  &"# 2.0000 SO3--  + .500 O2  + 2.0000 H+  = S2O6--  + H2O" //NEW_LINE('')// &
       !  &"#  H2O = .5 O2 + 2H+ + 2e- " //NEW_LINE('')// &
         &"2SO3-- = S2O6-- + 2e-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           41.8289" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2O6-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.14458E+03    0.61449E-01    0.71877E+04   -0.58657E+02    0.11211E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"	-add_logk  Log_K_O2	0.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 2.0000 SO3--  + 1.500 O2  + 2.0000 H+  = S2O8--  + H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           70.7489" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2O8-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.18394E+03    0.60414E-01    0.13864E+05   -0.71804E+02    0.21628E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"O2 + H+ + 3.0000 HS-  = S3--  + 2.0000 H2O" //NEW_LINE('')// &
       !  &"# 2H2O = O2 + 4H+ + 4e-" //NEW_LINE('')// &
       !  &"#3HS- = S3-- + 3H+ + 4e-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           79.3915" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S3-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -0.51626E+02    0.70208E-02    0.31797E+05    0.11927E+02   -0.64249E+06" //NEW_LINE('')// &
         &"	-mass_balance	S(-2)3" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
       !  &"#	-add_logk  Log_K_O2	1.0" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
       !  &"# 3.0000 SO3--  + 4.0000 H+  = S3O6-- + .500 O2 + 2.0000 H2O" //NEW_LINE('')// &
       !  &"# .5 O2 + 2H+ + 2e- = H2O" //NEW_LINE('')// &
         &"3SO3-- + 6 H+ + 2e- = S3O6-- + 3H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -6.2316" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S3O6-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.23664E+03    0.12702E+00   -0.10110E+05   -0.99715E+02   -0.15783E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"	-add_logk	Log_K_O2	-0.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.5000 O2 + 2.0000 H+ + 4.0000 HS-  = S4--  + 3.0000 H2O" //NEW_LINE('')// &
       !  &"#4 HS- = S4-- + 4H+ + 6e-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           125.2958" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.20875E+03    0.58133E-01    0.33278E+05   -0.85833E+02    0.51921E+03" //NEW_LINE('')// &
         &"	-mass_balance	S(-2)4" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
       !  &"#	-add_logk	Log_K_O2	1.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
       !  &"# 4.0000 SO3-- + 6.0000 H+  = S4O6-- + 1.500 O2 + 3.0000 H2O" //NEW_LINE('')// &
         &"4 SO3-- + 12 H+ + 6e- = S4O6-- + 6H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -38.3859" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S4O6-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.32239E+03    0.19555E+00   -0.23617E+05   -0.13729E+03   -0.36862E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"	-add_logk	Log_K_O2	-1.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"2.0000 O2 + 3.0000 H+  + 5.0000 HS-  = S5--  + 4.0000 H2O" //NEW_LINE('')// &
       !  &"#5 HS- = S5-- + 5H+ + 8e-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           170.9802" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S5-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.30329E+03    0.88033E-01    0.44739E+05   -0.12471E+03    0.69803E+03" //NEW_LINE('')// &
         &"	-mass_balance	S(-2)5" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
       !  &"#	-add_logk	Log_K_O2	2" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
       !  &"# 5.0000 SO3-- + 8.0000 H+  = S5O6-- + 2.5000 O2 + 4.0000 H2O" //NEW_LINE('')// &
       !  &"# 2.5O2 + 10 H+ + 10e- = 5H2O" //NEW_LINE('')// &
         &"5SO3-- + 18H+ + 10e- = S5O6-- + 9H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -99.4206" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S5O6-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.42074E+03    0.25833E+00   -0.43878E+05   -0.18178E+03   -0.68480E+03" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"	-add_logk	Log_K_O2	-2.5" //NEW_LINE('')// &

         ! &"" //NEW_LINE('')// &
         ! &"# 1.0000 H+  + HCO3-  + HS-  + NH3 = SCN-  + 3.0000 H2O" //NEW_LINE('')// &
         ! &"#        -llnl_gamma           3.5    " //NEW_LINE('')// &
         ! &"#        log_k            3.0070" //NEW_LINE('')// &
         ! &"#	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	SCN-" //NEW_LINE('')// &
         ! &"##	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         ! &"#        -analytic  0.16539E+03    0.49623E-01   -0.44624E+04   -0.65544E+02   -0.69680E+02" //NEW_LINE('')// &
         ! &"##       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &" 1.0000 SO4--  =  SO3-- +0.5000 O2   " //NEW_LINE('')// &
         &"        -llnl_gamma           4.5    " //NEW_LINE('')// &
         &"        log_k           -46.6244" //NEW_LINE('')// &
         &"	-delta_H	267.985	kJ/mol	# 	SO3-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-151.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.3771e+001 6.5102e-004 -1.3330e+004 4.7164e+000 -2.0800e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 Al+++  =  Al(OH)2+ +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -10.5945" //NEW_LINE('')// &
         &"	-delta_H	98.2822	kJ/mol	# 	Al(OH)2+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-241.825 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 4.4036e+001 2.0168e-002 -5.5455e+003 -1.6987e+001 -8.6545e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &


         &"" //NEW_LINE('')// &
         &"2.0000 SO4-- + 1.0000 Al+++  =  Al(SO4)2-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +4.9000" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Al(SO4)2-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
  !# removed Al 24 phase
      !    &" " //NEW_LINE('')// &
      !    &"28.0000 H2O + 13.0000 Al+++  =  Al13O4(OH)24+7 +32.0000 H+" //NEW_LINE('')// &
      !    &"        -llnl_gamma           6.0    " //NEW_LINE('')// &
      !    &"        log_k           -98.73" //NEW_LINE('')// &
      !    &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Al13O4(OH)24+7" //NEW_LINE('')// &
      !    ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &

         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 2.0000 Al+++  =  Al2(OH)2++++ +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           5.5    " //NEW_LINE('')// &
         &"        log_k           -7.6902" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Al2(OH)2+4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &

         &" " //NEW_LINE('')// &
         &"4.0000 H2O + 3.0000 Al+++  =  Al3(OH)4+5 +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           6.0    " //NEW_LINE('')// &
         &"        log_k           -13.8803" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Al3(OH)4+5" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &

         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 Al+++  =  AlO2- +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -22.8833" //NEW_LINE('')// &
         &"	-delta_H	180.899	kJ/mol	# 	AlO2-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-222.079 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.0803e+001 -3.4379e-003 -9.7391e+003 0.0000e+000 0.0000e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.0000 H2O + 1.0000 Al+++  =  AlOH++ +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.5    " //NEW_LINE('')// &
         &"        log_k           -4.9571" //NEW_LINE('')// &
         &"	-delta_H	49.798	kJ/mol	# 	AlOH+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-185.096 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.6224e-001 8.8816e-003 -1.8686e+003 -4.3195e-001 -2.9158e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 Al+++  =  AlSO4+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +3.0100" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	AlSO4+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &

         &" " //NEW_LINE('')// &
         &"1.0000 HCO3- + 1.0000 H+  =  CO2 +1.0000 H2O" //NEW_LINE('')// &
         &"        -CO2_llnl_gamma" //NEW_LINE('')// &
         &"        log_k           +6.3447" //NEW_LINE('')// &
         &"	-delta_H	-9.7027	kJ/mol	# 	CO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-98.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.0534e+001 2.1746e-002 2.5216e+003 7.9125e-001 3.9351e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         ! &"CO3-2 + 2 H+ = CO2 + H2O" //NEW_LINE('')// &
         ! &"        -log_k	16.681" //NEW_LINE('')// &
         ! &"	-delta_h -5.738	kcal" //NEW_LINE('')// &
         ! &"        -analytic	464.1965	0.09344813	-26986.16	-165.75951	2248628.9" //NEW_LINE('')// &
         ! &"        -Vm  21.78  -49.4  -91.7  31.96 # supcrt modified" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.0000 HCO3-  =  CO3-- +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.5    " //NEW_LINE('')// &
         &"        log_k           -10.3288" //NEW_LINE('')// &
         &"	-delta_H	14.6984	kJ/mol	# 	CO3-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-161.385 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -6.9958e+001 -3.3526e-002 -7.0846e+001 2.8224e+001 -1.0849e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"CO3-2 + H+ = HCO3-" //NEW_LINE('')// &
         &"        -llnl_gamma           5.4    " //NEW_LINE('')// &
         &"        log_k           10.3288" //NEW_LINE('')// &
         &"	-delta_h -3.561	kcal" //NEW_LINE('')// &
         &"        -analytic	107.8871	0.03252849	-5151.79	-38.92561	563713.9" //NEW_LINE('')// &
       !  &"#       -Vm  8.615  0  -12.21 0  1.667  0  0  264  0  1 # supcrt modified" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.0000 HCO3- + 1.0000 Ca++  =  CaCO3 +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -7.0017" //NEW_LINE('')// &
         &"	-delta_H	30.5767	kJ/mol	# 	CaCO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-287.39 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 2.3045e+002 5.5350e-002 -8.5056e+003 -9.1096e+001 -1.3279e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         !&"-Vm  -.2430  -8.3748  9.0417  -2.4328  -.0300 # supcrt" //NEW_LINE('')// &
         ! again

         ! &"" //NEW_LINE('')// &
         ! &"Ca+2 + CO3-2 = CaCO3" //NEW_LINE('')// &
         ! &"        -log_k	3.224" //NEW_LINE('')// &
         ! &"	-delta_h 3.545	kcal" //NEW_LINE('')// &
         ! &"        -analytic	-1228.732	-0.299440	35512.75	485.818" //NEW_LINE('')// &
         ! &"#       -Vm  -.2430  -8.3748  9.0417  -2.4328  -.0300 # supcrt" //NEW_LINE('')// &
         !

         &"" //NEW_LINE('')// &
         &"1.0000 Cl- + 1.0000 Ca++  =  CaCl+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -0.6956" //NEW_LINE('')// &
         &"	-delta_H	2.02087	kJ/mol	# 	CaCl+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-169.25 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 8.1498e+001 3.8387e-002 -1.3763e+003 -3.5968e+001 -2.1501e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 Cl- + 1.0000 Ca++  =  CaCl2" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -0.6436" //NEW_LINE('')// &
         &"	-delta_H	-5.8325	kJ/mol	# 	CaCl2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-211.06 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.8178e+002 7.6910e-002 -3.1088e+003 -7.8760e+001 -4.8563e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"1.0000 HCO3- + 1.0000 Ca++  =  CaHCO3+" //NEW_LINE('')// &
         ! &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         ! &"        log_k           +1.0467" //NEW_LINE('')// &
         ! &"	-delta_H	1.45603	kJ/mol	# 	CaHCO3+" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-294.35 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 5.5985e+001 3.4639e-002 -3.6972e+002 -2.5864e+001 -5.7859e+000" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"-Vm  3.1911  .0104  5.7459  -2.7794  .3084 5.4 # supcrt" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"1.0000 H2O + 1.0000 Ca++  =  CaOH+ +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -12.85" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	CaOH+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &

       !  &"#Al(OH)4-            82" //NEW_LINE('')// &
         &"        Al+3 + 4H2O = Al(OH)4- + 4H+ " //NEW_LINE('')// &
         &"        log_k           -22.7" //NEW_LINE('')// &
         &"        delta_h 42.3 kcal" //NEW_LINE('')// &
         &"        -analytical     51.578          0.0     -11168.9        -14.865         0.0" //NEW_LINE('')// &



         &"1.0000 SO4-- + 1.0000 Ca++  =  CaSO4" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +2.1111" //NEW_LINE('')// &
         &"	-delta_H	5.4392	kJ/mol	# 	CaSO4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-345.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 2.8618e+002 8.4084e-002 -7.6880e+003 -1.1449e+002 -1.2005e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"-Vm  2.7910  -.9666  6.1300  -2.7390  -.0010 # supcrt" //NEW_LINE('')// &

         &"2.0000 H2O + 1.0000 Fe++  =  Fe(OH)2 +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -20.6" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 Fe+++  =  Fe(OH)2+ +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -5.67" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)2+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"3.0000 H2O + 1.0000 Fe+++  =  Fe(OH)3 +3.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -12" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"3.0000 H2O + 1.0000 Fe++  =  Fe(OH)3- +3.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -31" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"4.0000 H2O + 1.0000 Fe+++  =  Fe(OH)4- +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -21.6" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"4.0000 H2O + 1.0000 Fe++  =  Fe(OH)4-- +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -46" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(OH)4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 SO4-- + 1.0000 Fe+++  =  Fe(SO4)2-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +3.2137" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe(SO4)2-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 2.0000 Fe+++  =  Fe2(OH)2++++ +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           5.5    " //NEW_LINE('')// &
         &"        log_k           -2.95" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe2(OH)2+4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"4.0000 H2O + 3.0000 Fe+++  =  Fe3(OH)4+5 +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           6.0    " //NEW_LINE('')// &
         &"        log_k           -6.3" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Fe3(OH)4+5" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 HCO3- + 1.0000 Fe++  =  FeCO3 +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -5.5988" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeCO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 HCO3- + 1.0000 Fe+++  =  FeCO3+ +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -0.6088" //NEW_LINE('')// &
         &"	-delta_H	-50.208	kJ/mol	# 	FeCO3+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-188.748 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.7100e+002 8.0413e-002 -4.3217e+002 -7.8449e+001 -6.7948e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Fe++ + 1.0000 Cl-  =  FeCl+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -0.1605" //NEW_LINE('')// &
         &"	-delta_H	3.02503	kJ/mol	# 	FeCl+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-61.26 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 8.2435e+001 3.7755e-002 -1.4765e+003 -3.5918e+001 -2.3064e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Fe+++ + 1.0000 Cl-  =  FeCl++" //NEW_LINE('')// &
         &"        -llnl_gamma           4.5    " //NEW_LINE('')// &
         &"        log_k           -0.8108" //NEW_LINE('')// &
         &"	-delta_H	36.6421	kJ/mol	# 	FeCl+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-180.018 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 1.6186e+002 5.9436e-002 -5.1913e+003 -6.5852e+001 -8.1053e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 Cl- + 1.0000 Fe++  =  FeCl2" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -2.4541" //NEW_LINE('')// &
         &"	-delta_H	6.46846	kJ/mol	# 	FeCl2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-100.37 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.9171e+002 7.8070e-002 -4.1048e+003 -8.2292e+001 -6.4108e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 Cl- + 1.0000 Fe+++  =  FeCl2+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +2.1300" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeCl2+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"4.0000 Cl- + 1.0000 Fe+++  =  FeCl4-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -0.79" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeCl4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"4.0000 Cl- + 1.0000 Fe++  =  FeCl4--" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -1.9" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeCl4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.4108e+002 -6.0086e-003 9.7979e+003 8.4084e+001 1.5296e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 HCO3- + 1.0000 Fe++  =  FeHCO3+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +2.7200" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeHCO3+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 H2O + 1.0000 Fe++  =  FeOH+ +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -9.5" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeOH+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 H2O + 1.0000 Fe+++  =  FeOH++ +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.5    " //NEW_LINE('')// &
         &"        log_k           -2.19" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeOH+2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 Fe++  =  FeSO4" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +2.2000" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	FeSO4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 Fe+++  =  FeSO4+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +1.9276" //NEW_LINE('')// &
         &"	-delta_H	27.181	kJ/mol	# 	FeSO4+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-932.001 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 2.5178e+002 1.0080e-001 -6.0977e+003 -1.0483e+002 -9.5223e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
       !  &"#1.0000 HS- + 1.0000 H+  =  H2S" //NEW_LINE('')// &
       !  &"#        -llnl_gamma           3.0    " //NEW_LINE('')// &
       !  &"#        log_k           +6.99" //NEW_LINE('')// &
       !  &"#        -analytic 1.2833e+002 5.1641e-002 -1.1681e+003 -5.3665e+001 -1.8266e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"# these (above) H2S values are from " //NEW_LINE('')// &
         ! &"# Suleimenov & Seward, Geochim. Cosmochim. Acta, v. 61, p. 5187-5198." //NEW_LINE('')// &
         ! &"# values below are the original Thermo.com.v8.r6.230 data from somewhere" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 HS- + 1.0000 H+  =  H2S" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +6.9877" //NEW_LINE('')// &
         &"	-delta_H	-21.5518	kJ/mol	# 	H2S" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-9.001 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 3.9283e+001 2.8727e-002  1.3477e+003 -1.8331e+001  2.1018e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 H+ + 1.0000 SO3--  =  H2SO3" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +9.2132" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	H2SO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 H+ + 1.0000 SO4--  =  H2SO4" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -1.0209" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	H2SO4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 SiO2  =  H2SiO4-- +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -22.96" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	H2SiO4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"8.0000 H2O + 4.0000 SiO2  =  H4(H2SiO4)4---- +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -35.94" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	H4(H2SiO4)4-4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"8.0000 H2O + 4.0000 SiO2  =  H6(H2SiO4)4-- +2.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -13.64" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	H6(H2SiO4)4-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 Al+++  =  HAlO2 +3.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -16.4329" //NEW_LINE('')// &
         &"	-delta_H	144.704	kJ/mol	# 	HAlO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-230.73 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 4.2012e+001 1.9980e-002 -7.7847e+003 -1.5470e+001 -1.2149e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 H+ + 1.0000 Cl-  =  HCl" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -0.67" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	HCl" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 4.1893e+002 1.1103e-001 -1.1784e+004 -1.6697e+002 -1.8400e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 H+ + 1.0000 ClO-  =  HClO" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +7.5692" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	HClO" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 H+ + 1.0000 ClO2-  =  HClO2" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +3.1698" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	HClO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"  " //NEW_LINE('')// &
         &"1.0000 H+ + 1.0000 S2O3--  =  HS2O3-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k            1.0139" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	HS2O3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SO3-- + 1.0000 H+  =  HSO3-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +7.2054" //NEW_LINE('')// &
         &"	-delta_H	9.33032	kJ/mol	# 	HSO3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-149.67 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 5.5899e+001 3.3623e-002 -5.0120e+002 -2.3040e+001 -7.8373e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 H+  =  HSO4-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +1.9791" //NEW_LINE('')// &
         &"	-delta_H	20.5016	kJ/mol	# 	HSO4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-212.5 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 4.9619e+001 3.0368e-002 -1.1558e+003 -2.1335e+001 -1.8051e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 SiO2 + 1.0000 H2O  =  HSiO3- +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -9.9525" //NEW_LINE('')// &
         &"	-delta_H	25.991	kJ/mol	# 	HSiO3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-271.88 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 6.4211e+001 -2.4872e-002 -1.2707e+004 -1.4681e+001 1.0853e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 K+ + 1.0000 Cl-  =  KCl" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -1.4946" //NEW_LINE('')// &
         &"	-delta_H	14.1963	kJ/mol	# 	KCl" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-96.81 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.3650e+002 3.8405e-002 -4.4014e+003 -5.4421e+001 -6.8721e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 K+ + 1.0000 H+  =  KHSO4" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +0.8136" //NEW_LINE('')// &
         &"	-delta_H	29.8319	kJ/mol	# 	KHSO4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-270.54 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.2620e+002 5.7349e-002 -3.3670e+003 -5.3003e+001 -5.2576e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 K+ + 1.0000 H2O  =  KOH +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -14.46" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	KOH" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 K+  =  KSO4-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +0.8796" //NEW_LINE('')// &
         &"	-delta_H	2.88696	kJ/mol	# 	KSO4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-276.98 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 9.9073e+001 3.7817e-002 -2.1628e+003 -4.1297e+001 -3.3779e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"4.0000 Mg++ + 4.0000 H2O  =  Mg4(OH)4++++ +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           5.5    " //NEW_LINE('')// &
         &"        log_k           -39.75" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Mg4(OH)4+4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 Mg++ + 1.0000 HCO3-  =  MgCO3 +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -7.3499" //NEW_LINE('')// &
         &"	-delta_H	23.8279	kJ/mol	# 	MgCO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-270.57 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 2.3465e+002 5.5538e-002 -8.3947e+003 -9.3104e+001 -1.3106e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Mg++ + 1.0000 Cl-  =  MgCl+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -0.1349" //NEW_LINE('')// &
         &"	-delta_H	-0.58576	kJ/mol	# 	MgCl+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-151.44 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 4.3363e+001 3.2858e-002 1.1878e+002 -2.1688e+001 1.8403e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Mg++ + 1.0000 HCO3-  =  MgHCO3+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +1.0357" //NEW_LINE('')// &
         &"	-delta_H	2.15476	kJ/mol	# 	MgHCO3+" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-275.75 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 3.8459e+001 3.0076e-002 9.8068e+001 -1.8869e+001 1.5187e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 Mg++  =  MgSO4" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +2.4117" //NEW_LINE('')// &
         &"	-delta_H	19.6051	kJ/mol	# 	MgSO4" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1355.96 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 1.7994e+002 6.4715e-002 -4.7314e+003 -7.3123e+001 -8.0408e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-200" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 H2O + 1.0000 Na+ + 1.0000 Al+++  =  NaAlO2 +4.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -23.6266" //NEW_LINE('')// &
         &"	-delta_H	190.326	kJ/mol	# 	NaAlO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-277.259 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.2288e+002 3.4921e-002 -1.2808e+004 -4.6046e+001 -1.9990e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Na+ + 1.0000 HCO3-  =  NaCO3- +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           -9.8144" //NEW_LINE('')// &
         &"	-delta_H	-5.6521	kJ/mol	# 	NaCO3-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-935.885 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 1.6939e+002 5.3122e-004 -7.6768e+003 -6.2078e+001 -1.1984e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Na+ + 1.0000 Cl-  =  NaCl" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -0.777" //NEW_LINE('')// &
         &"	-delta_H	5.21326	kJ/mol	# 	NaCl" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-96.12 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.1398e+002 3.6386e-002 -3.0847e+003 -4.6571e+001 -4.8167e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Na+ + 1.0000 HCO3-  =  NaHCO3" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +0.1541" //NEW_LINE('')// &
         &"	-delta_H	-13.7741	kJ/mol	# 	NaHCO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-944.007 kJ/mol" //NEW_LINE('')// &
         &"        -analytic -9.0668e+001 -2.9866e-002 2.7947e+003 3.6515e+001 4.7489e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-200" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 SiO2 + 1.0000 Na+ + 1.0000 H2O  =  NaHSiO3 +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -8.304" //NEW_LINE('')// &
         &"	-delta_H	11.6524	kJ/mol	# 	NaHSiO3" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-332.74 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 3.6045e+001 -9.0411e-003 -6.6605e+003 -1.0447e+001 5.8415e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 Na+ + 1.0000 H2O  =  NaOH +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           -14.7948" //NEW_LINE('')// &
         &"	-delta_H	53.6514	kJ/mol	# 	NaOH" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-112.927 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 8.7326e+001 2.3555e-002 -5.4770e+003 -3.6678e+001 -8.5489e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"1.0000 SO4-- + 1.0000 Na+  =  NaSO4-" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           +0.8200" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	NaSO4-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 H2O  =  OH- +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           3.5    " //NEW_LINE('')// &
         &"        log_k           -13.9951" //NEW_LINE('')// &
         &"	-delta_H	55.8146	kJ/mol	# 	OH-" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-54.977 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -6.7506e+001 -3.0619e-002 -1.9901e+003 2.8004e+001 -3.1033e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         &"1.0000 HS-  =  S-- +1.0000 H+" //NEW_LINE('')// &
         &"        -llnl_gamma           5.0    " //NEW_LINE('')// &
         &"        log_k           -12.9351" //NEW_LINE('')// &
         &"	-delta_H	49.0364	kJ/mol	# 	S-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	32.928 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 9.7756e+001 3.2913e-002 -5.0784e+003 -4.1812e+001 -7.9273e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 H+  + 2.0000 SO3--  = S2O5--  + H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           4.0    " //NEW_LINE('')// &
         &"        log_k           9.5934" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	S2O5-2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-0 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 0.12262E+03    0.62883E-01   -0.18005E+04   -0.50798E+02   -0.28132E+02" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"2.0000 H+ + 1.0000 SO3--  =  SO2 +1.0000 H2O" //NEW_LINE('')// &
         &"        -llnl_gamma           3.0    " //NEW_LINE('')// &
         &"        log_k           +9.0656" //NEW_LINE('')// &
         &"	-delta_H	26.7316	kJ/mol	# 	SO2" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-77.194 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 9.4048e+001 6.2127e-002 -1.1072e+003 -4.0310e+001 -1.7305e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &" " //NEW_LINE('')// &
         !-DB PHASES
         &"PHASES" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
       !  &"#  1122 minerals" //NEW_LINE('')// &
         ! &"Afwillite" //NEW_LINE('')// &
         ! &"        Ca3Si2O4(OH)6 +6.0000 H+  =  + 2.0000 SiO2 + 3.0000 Ca++ + 6.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           60.0452" //NEW_LINE('')// &
         ! &"	-delta_H	-316.059	kJ/mol	# 	Afwillite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1143.31 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.8353e+001 1.9014e-003 1.8478e+004 -6.6311e+000 -4.0227e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"Akermanite" //NEW_LINE('')// &
         ! &"        Ca2MgSi2O7 +6.0000 H+  =  + 1.0000 Mg++ + 2.0000 Ca++ + 2.0000 SiO2 + 3.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           45.3190" //NEW_LINE('')// &
         ! &"	-delta_H	-288.575	kJ/mol	# 	Akermanite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-926.497 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -4.8295e+001 -8.5613e-003 2.0880e+004 1.3798e+001 -7.1975e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         &"Al" //NEW_LINE('')// &
         &"       Al +3.0000 H+ +0.7500 O2  =  + 1.0000 Al+++ + 1.5000 H2O" //NEW_LINE('')// &
         &"        log_k           149.9292" //NEW_LINE('')// &
         &"	-delta_H	-958.059	kJ/mol	# 	Al" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	0 kJ/mol" //NEW_LINE('')// &
         &"        -analytic -1.8752e+002 -4.6187e-002 5.7127e+004 6.6270e+001 -3.8952e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Al2(SO4)3" //NEW_LINE('')// &
         ! &"       Al2(SO4)3  =  + 2.0000 Al+++ + 3.0000 SO4--" //NEW_LINE('')// &
         ! &"        log_k           19.0535" //NEW_LINE('')// &
         ! &"	-delta_H	-364.566	kJ/mol	# 	Al2(SO4)3" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-3441.04 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -6.1001e+002 -2.4268e-001 2.9194e+004 2.4383e+002 4.5573e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Al2(SO4)3:6H2O" //NEW_LINE('')// &
         ! &"       Al2(SO4)3:6H2O  =  + 2.0000 Al+++ + 3.0000 SO4-- + 6.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           1.6849" //NEW_LINE('')// &
         ! &"	-delta_H	-208.575	kJ/mol	# 	Al2(SO4)3:6H2O" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-5312.06 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -7.1642e+002 -2.4552e-001 2.6064e+004 2.8441e+002 4.0691e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"################################" //NEW_LINE('')// &
         ! &"#      ADDITIONS BY NAVAH      #" //NEW_LINE('')// &
         ! &"################################" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Augite" //NEW_LINE('')// &
         ! &"        Ca.7Fe.6Mg.7Si2O6 +4.0000 H+  =  2.0 H2O + 2.0 SiO2 + .7Ca+2 + 0.6Fe+2 + 0.7Mg+2" //NEW_LINE('')// &
         ! &"        log_k           21.00" //NEW_LINE('')// &
         ! &"	-delta_H	-51.8523	kJ/mol	# 	Augite" //NEW_LINE('')// &
         ! &"	-analytic 7.84710902e+00   7.21674649e-03   1.25039649e+04  -8.82692820e+00  -8.09786954e+05" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Pigeonite" //NEW_LINE('')// &
         ! &"        Ca1.14Fe.64Mg.22Si2O6 +4.0000 H+  =  2.0 H2O + 2.0 SiO2 + 1.14Ca+2 + 0.64Fe+2 + 0.22Mg+2" //NEW_LINE('')// &
         ! &"        log_k           21.40" //NEW_LINE('')// &
         ! &"	-delta_H	-51.8523	kJ/mol	# 	Pigeonite" //NEW_LINE('')// &
         ! &"	-analytic 3.92773074e+01   1.11617261e-02   1.07613145e+04  -1.98006851e+01  -7.39527557e+05" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Plagioclase" //NEW_LINE('')// &
         ! &"        Ca.5Na.5Al1.5Si2.5O8 +6.0000 H+  =  3.0000 H2O + 2.5 SiO2 + .5 Ca+2 + 1.5 Al+3 + 0.5Na+" //NEW_LINE('')// &
         ! &"        log_k           14.20" //NEW_LINE('')// &
         ! &"	-delta_H	-51.8523	kJ/mol	# 	Plagioclase" //NEW_LINE('')// &
         ! &"	-analytic -3.80343385e+01  -7.37083665e-03   1.59944487e+04   4.95599390e+00  -1.01574822e+06" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"################################" //NEW_LINE('')// &
         ! &"#        END NAVAHBLOCK        #" //NEW_LINE('')// &
         ! &"################################" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Albite" //NEW_LINE('')// &
         ! &"        NaAlSi3O8 +4.0000 H+  =  + 1.0000 Al+++ + 1.0000 Na+ + 2.0000 H2O + 3.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           2.7645" //NEW_LINE('')// &
         ! &"	-delta_H	-51.8523	kJ/mol	# 	Albite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-939.68 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.1694e+001 1.4429e-002 1.3784e+004 -7.2866e+000 -1.6136e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Analcime" //NEW_LINE('')// &
         &"        Na.96Al.96Si2.04O6:H2O +3.8400 H+  =  + 0.9600 Al+++ + 0.9600 Na+ + 2.0400 SiO2 + 2.9200 H2O" //NEW_LINE('')// &
         &"        log_k           6.1396" //NEW_LINE('')// &
         &"	-delta_H	-75.844	kJ/mol	# 	Analcime" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-3296.86 kJ/mol" //NEW_LINE('')// &
         &"        -analytic -6.8694e+000 6.6052e-003 9.8260e+003 -4.8540e+000 -8.8780e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Andradite" //NEW_LINE('')// &
         ! &"        Ca3Fe2(SiO4)3 +12.0000 H+  =  + 2.0000 Fe+++ + 3.0000 Ca++ + 3.0000 SiO2 + 6.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           33.3352" //NEW_LINE('')// &
         ! &"	-delta_H	-301.173	kJ/mol	# 	Andradite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1380.35 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.3884e+001 -2.3886e-002 1.5314e+004 -8.1606e+000 -4.2193e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Saponite-Ca" //NEW_LINE('')// &
         &"        Ca.165Mg3Al.33Si3.67O10(OH)2 +7.3200 H+  =  + 0.1650 Ca++ + 0.3300 Al+++ + 3.0000 Mg++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           26.2900" //NEW_LINE('')// &
         &"	-delta_H	-207.971	kJ/mol	# Saponite-Ca" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1436.51 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -4.6904e+001 6.2555e-003 2.2572e+004 5.3198e+000 -1.5725e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Anhydrite" //NEW_LINE('')// &
         ! &"        CaSO4  =  + 1.0000 Ca++ + 1.0000 SO4--" //NEW_LINE('')// &
         ! &"        log_k           -4.3064" //NEW_LINE('')// &
         ! &"	-delta_H	-18.577	kJ/mol	# 	Anhydrite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-342.76 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.0986e+002 -7.8823e-002 5.0969e+003 8.5642e+001 7.9594e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"-Vm 46.1 # 136.14 / 2.95" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"Phillipsite" //NEW_LINE('')// &
         ! &"        Na0.5K0.5AlSi3O8:H2O + 4H+ = 0.5Na+ +0.5K+ + 3H2O + Al+3 + 3SiO2" //NEW_LINE('')// &
         &"        Na0.5K0.5AlSi3O8:H2O + 7H2O = 0.5Na+ +0.5K+ + Al(OH)4- + 6H2O + 3SiO2" //NEW_LINE('')// &
         &"        log_k           -19.874" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &

         ! &"Aragonite" //NEW_LINE('')// &
         ! &"        CaCO3 +1.0000 H+  =  + 1.0000 Ca++ + 1.0000 HCO3-" //NEW_LINE('')// &
         ! &"        log_k           1.9931" //NEW_LINE('')// &
         ! &"	-delta_H	-25.8027	kJ/mol	# 	Aragonite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-288.531 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.4934e+002 -4.8043e-002 4.9089e+003 6.0284e+001 7.6644e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! !&"-Vm 34.04" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"Calcite" //NEW_LINE('')// &
         &"        CaCO3 +1.0000 H+  =  + 1.0000 Ca++ + 1.0000 HCO3-" //NEW_LINE('')// &
         &"        log_k           1.8487" //NEW_LINE('')// &
         &"	-delta_H	-25.7149	kJ/mol	# 	Calcite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-288.552 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.4978e+002 -4.8370e-002 4.8974e+003 6.0458e+001 7.6464e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         !&"-Vm 36.9 cm3/mol # MW (100.09 g/mol) / rho (2.71 g/cm3)" //NEW_LINE('')// &

         ! &"" //NEW_LINE('')// &
         !  &"Calcite" //NEW_LINE('')// &
         !  &"	CaCO3 = CO3-2 + Ca+2" //NEW_LINE('')// &
         !  &"	-log_k	-8.48" //NEW_LINE('')// &
         !  &"	-delta_h -2.297 kcal" //NEW_LINE('')// &
         !  &"	-analytic	-171.9065	-0.077993	2839.319	71.595" //NEW_LINE('')// &
         !  &"	-Vm 36.9 cm3/mol # MW (100.09 g/mol) / rho (2.71 g/cm3)" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         !  &"Aragonite" //NEW_LINE('')// &
         !  &"	CaCO3 = CO3-2 + Ca+2" //NEW_LINE('')// &
         !  &"	-log_k	-8.336" //NEW_LINE('')// &
         !  &"	-delta_h -2.589 kcal" //NEW_LINE('')// &
         !  &"	-analytic	-171.9773	-0.077993	2903.293	71.595" //NEW_LINE('')// &
         !  &"	-Vm 34.04" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"Celadonite" //NEW_LINE('')// &
         &"        KMgAlSi4O10(OH)2 +6.0000 H+  =  + 1.0000 Al+++ + 1.0000 K+ + 1.0000 Mg++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           7.4575" //NEW_LINE('')// &
         &"	-delta_H	-74.3957	kJ/mol	# 	Celadonite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1394.9 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -3.3097e+001 1.7989e-002 1.8919e+004 -2.1219e+000 -2.0588e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Clinoptilolite-Ca" //NEW_LINE('')// &
         &"        Ca1.7335Al3.45Fe.017Si14.533O36:10.922H2O +13.8680 H+  =  + 0.0170 Fe+++ + 1.7335 Ca++ + 3.4500 Al+++ + 14.5330 SiO2 + 17.8560 H2O" //NEW_LINE('')// &
         &"        log_k           -7.0095" //NEW_LINE('')// &
         &"	-delta_H	-74.6745	kJ/mol	# 	Clinoptilolite-Ca" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-4919.84 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -4.4820e+001 5.3696e-002 5.4878e+004 -3.1459e+001 -7.5491e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Clinozoisite" //NEW_LINE('')// &
         ! &"        Ca2Al3Si3O12(OH) +13.0000 H+  =  + 2.0000 Ca++ + 3.0000 Al+++ + 3.0000 SiO2 + 7.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           43.2569" //NEW_LINE('')// &
         ! &"	-delta_H	-457.755	kJ/mol	# 	Clinozoisite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1643.78 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.8690e+001 -3.7056e-002 2.2770e+004 3.7880e+000 -2.5834e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Cronstedtite-7A" //NEW_LINE('')// &
         ! &"        Fe2Fe2SiO5(OH)4 +10.0000 H+  =  + 1.0000 SiO2 + 2.0000 Fe++ + 2.0000 Fe+++ + 7.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           16.2603" //NEW_LINE('')// &
         ! &"	-delta_H	-244.266	kJ/mol	# 	Cronstedtite-7A" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-697.413 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.3783e+002 -7.1026e-002 1.7752e+004 8.7147e+001 2.7707e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Daphnite-14A" //NEW_LINE('')// &
         &"        Fe5AlAlSi3O10(OH)8 +16.0000 H+  =  + 2.0000 Al+++ + 3.0000 SiO2 + 5.0000 Fe++ + 12.0000 H2O" //NEW_LINE('')// &
         &"        log_k           52.2821" //NEW_LINE('')// &
         &"	-delta_H	-517.561	kJ/mol	# 	Daphnite-14A" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1693.04 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.5261e+002 -6.1392e-002 2.8283e+004 5.1788e+001 4.4137e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Daphnite-7A" //NEW_LINE('')// &
         &"        Fe5AlAlSi3O10(OH)8 +16.0000 H+  =  + 2.0000 Al+++ + 3.0000 SiO2 + 5.0000 Fe++ + 12.0000 H2O" //NEW_LINE('')// &
         &"        log_k           55.6554" //NEW_LINE('')// &
         &"	-delta_H	-532.326	kJ/mol	# 	Daphnite-7A" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1689.51 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.6430e+002 -6.3160e-002 2.9499e+004 5.6442e+001 4.6035e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Dawsonite" //NEW_LINE('')// &
         ! &"        NaAlCO3(OH)2 +3.0000 H+  =  + 1.0000 Al+++ + 1.0000 HCO3- + 1.0000 Na+ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           4.3464" //NEW_LINE('')// &
         ! &"	-delta_H	-76.3549	kJ/mol	# 	Dawsonite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1963.96 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.1393e+002 -2.3487e-002 7.1758e+003 4.0900e+001 1.2189e+002" //NEW_LINE('')// &
         ! ! &"#       -Range:  0-200" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Diaspore" //NEW_LINE('')// &
         ! &"        AlHO2 +3.0000 H+  =  + 1.0000 Al+++ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           7.1603" //NEW_LINE('')// &
         ! &"	-delta_H	-110.42	kJ/mol	# 	Diaspore" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-238.924 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.2618e+002 -3.1671e-002 8.8737e+003 4.5669e+001 1.3850e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Dicalcium_silicate" //NEW_LINE('')// &
         ! &"        Ca2SiO4 +4.0000 H+  =  + 1.0000 SiO2 + 2.0000 Ca++ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           37.1725" //NEW_LINE('')// &
         ! &"	-delta_H	-217.642	kJ/mol	# 	Dicalcium_silicate" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-2317.9 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -5.9723e+001 -1.3682e-002 1.5461e+004 2.1547e+001 -3.7732e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Diopside" //NEW_LINE('')// &
         ! &"        CaMgSi2O6 +4.0000 H+  =  + 1.0000 Ca++ + 1.0000 Mg++ + 2.0000 H2O + 2.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           20.9643" //NEW_LINE('')// &
         ! &"	-delta_H	-133.775	kJ/mol	# 	Diopside" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-765.378 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 7.1240e+001 1.5514e-002 8.1437e+003 -3.0672e+001 -5.6880e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Dolomite" //NEW_LINE('')// &
         ! &"        CaMg(CO3)2 +2.0000 H+  =  + 1.0000 Ca++ + 1.0000 Mg++ + 2.0000 HCO3-" //NEW_LINE('')// &
         ! &"        log_k           2.5135" //NEW_LINE('')// &
         ! &"	-delta_H	-59.9651	kJ/mol	# 	Dolomite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-556.631 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -3.1782e+002 -9.8179e-002 1.0845e+004 1.2657e+002 1.6932e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"-Vm 64.5" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"Epidote" //NEW_LINE('')// &
         &"        Ca2FeAl2Si3O12OH +13.0000 H+  =  + 1.0000 Fe+++ + 2.0000 Al+++ + 2.0000 Ca++ + 3.0000 SiO2 + 7.0000 H2O" //NEW_LINE('')// &
         &"        log_k           32.9296" //NEW_LINE('')// &
         &"	-delta_H	-386.451	kJ/mol	# 	Epidote" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1543.99 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.6187e+001 -3.6436e-002 1.9351e+004 3.3671e+000 -3.0319e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Ettringite" //NEW_LINE('')// &
         ! &"        Ca6Al2(SO4)3(OH)12:26H2O +12.0000 H+  =  + 2.0000 Al+++ + 3.0000 SO4-- + 6.0000 Ca++ + 38.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           62.5362" //NEW_LINE('')// &
         ! &"	-delta_H	-382.451	kJ/mol	# 	Ettringite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-4193 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.0576e+003 -1.1585e-001 5.9580e+004 3.8585e+002 1.0121e+003" //NEW_LINE('')// &
         ! ! &"#       -Range:  0-200" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Fayalite" //NEW_LINE('')// &
         ! &"        Fe2SiO4 +4.0000 H+  =  + 1.0000 SiO2 + 2.0000 Fe++ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           19.1113" //NEW_LINE('')// &
         ! &"	-delta_H	-152.256	kJ/mol	# 	Fayalite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-354.119 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.3853e+001 -3.5501e-003 7.1496e+003 -6.8710e+000 -6.3310e+004" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Ferrite-Ca" //NEW_LINE('')// &
         ! &"        CaFe2O4 +8.0000 H+  =  + 1.0000 Ca++ + 2.0000 Fe+++ + 4.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           21.5217" //NEW_LINE('')// &
         ! &"	-delta_H	-264.738	kJ/mol	# 	Ferrite-Ca" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-363.494 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.8472e+002 -7.5870e-002 2.0688e+004 1.0485e+002 3.2289e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Foshagite" //NEW_LINE('')// &
         ! &"        Ca4Si3O9(OH)2:0.5H2O +8.0000 H+  =  + 3.0000 SiO2 + 4.0000 Ca++ + 5.5000 H2O" //NEW_LINE('')// &
         ! &"        log_k           65.9210" //NEW_LINE('')// &
         ! &"	-delta_H	-359.839	kJ/mol	# 	Foshagite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1438.27 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 2.9983e+001 5.5272e-003 2.3427e+004 -1.3879e+001 -8.9461e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Gismondine" //NEW_LINE('')// &
         &"        Ca2Al4Si4O16:9H2O +16.0000 H+  =  + 2.0000 Ca++ + 4.0000 Al+++ + 4.0000 SiO2 + 17.0000 H2O" //NEW_LINE('')// &
         &"        log_k           41.7170" //NEW_LINE('')// &
         &"	-delta_H	0	      	# Not possible to calculate enthalpy of reaction	Gismondine" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	0 kcal/mol" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Goethite" //NEW_LINE('')// &
         &"        FeOOH +3.0000 H+  =  + 1.0000 Fe+++ + 2.0000 H2O" //NEW_LINE('')// &
         &"        log_k           0.5345" //NEW_LINE('')// &
         &"	-delta_H	-61.9291	kJ/mol	# 	Goethite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-559.328 kJ/mol" //NEW_LINE('')// &
         &"        -analytic -6.0331e+001 -1.0847e-002 4.7759e+003 1.9429e+001 8.1122e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-200" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Greenalite" //NEW_LINE('')// &
         ! &"        Fe3Si2O5(OH)4 +6.0000 H+  =  + 2.0000 SiO2 + 3.0000 Fe++ + 5.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           22.6701" //NEW_LINE('')// &
         ! &"	-delta_H	-165.297	kJ/mol	# 	Greenalite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-787.778 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.4187e+001 -3.8377e-003 1.1710e+004 1.6442e+000 -4.8290e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Gyrolite" //NEW_LINE('')// &
         ! &"        Ca2Si3O7(OH)2:1.5H2O +4.0000 H+  =  + 2.0000 Ca++ + 3.0000 SiO2 + 4.5000 H2O" //NEW_LINE('')// &
         ! &"        log_k           22.9099" //NEW_LINE('')// &
         ! &"	-delta_H	-82.862	kJ/mol	# 	Gyrolite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1176.55 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.4416e+001 1.4646e-002 1.6181e+004 2.3723e+000 -1.5369e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Hedenbergite" //NEW_LINE('')// &
         ! &"        CaFe(SiO3)2 +4.0000 H+  =  + 1.0000 Ca++ + 1.0000 Fe++ + 2.0000 H2O + 2.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           19.6060" //NEW_LINE('')// &
         ! &"	-delta_H	-124.507	kJ/mol	# 	Hedenbergite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-678.276 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.9473e+001 1.5288e-003 1.2910e+004 2.1729e+000 -9.0058e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Hematite" //NEW_LINE('')// &
         &"        Fe2O3 +6.0000 H+  =  + 2.0000 Fe+++ + 3.0000 H2O" //NEW_LINE('')// &
         &"        log_k           0.1086" //NEW_LINE('')// &
         &"	-delta_H	-129.415	kJ/mol	# 	Hematite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-197.72 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.2015e+002 -6.0290e-002 1.1812e+004 8.0253e+001 1.8438e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Hillebrandite" //NEW_LINE('')// &
         ! &"        Ca2SiO3(OH)2:0.17H2O +4.0000 H+  =  + 1.0000 SiO2 + 2.0000 Ca++ + 3.1700 H2O" //NEW_LINE('')// &
         ! &"        log_k           36.8190" //NEW_LINE('')// &
         ! &"	-delta_H	-203.074	kJ/mol	# 	Hillebrandite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-637.404 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.9360e+001 -7.5176e-003 1.1947e+004 8.0558e+000 -1.4504e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"K-Feldspar" //NEW_LINE('')// &
         &"        KAlSi3O8 +4.0000 H+  =  + 1.0000 Al+++ + 1.0000 K+ + 2.0000 H2O + 3.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           -0.2753" //NEW_LINE('')// &
         &"	-delta_H	-23.9408	kJ/mol	# 	K-Feldspar" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-949.188 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.0684e+000 1.3111e-002 1.1671e+004 -9.9129e+000 -1.5855e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Kaolinite" //NEW_LINE('')// &
         &"        Al2Si2O5(OH)4 +6.0000 H+  =  + 2.0000 Al+++ + 2.0000 SiO2 + 5.0000 H2O" //NEW_LINE('')// &
         &"        log_k           6.8101" //NEW_LINE('')// &
         &"	-delta_H	-151.779	kJ/mol	# 	Kaolinite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-982.221 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.6835e+001 -7.8939e-003 7.7636e+003 -1.2190e+001 -3.2354e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Larnite" //NEW_LINE('')// &
         ! &"        Ca2SiO4 +4.0000 H+  =  + 1.0000 SiO2 + 2.0000 Ca++ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           38.4665" //NEW_LINE('')// &
         ! &"	-delta_H	-227.061	kJ/mol	# 	Larnite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-551.74 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 2.6900e+001 -2.1833e-003 1.0900e+004 -9.5257e+000 -7.2537e+004" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Laumontite" //NEW_LINE('')// &
         ! &"        CaAl2Si4O12:4H2O +8.0000 H+  =  + 1.0000 Ca++ + 2.0000 Al+++ + 4.0000 SiO2 + 8.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           13.6667" //NEW_LINE('')// &
         ! &"	-delta_H	-184.657	kJ/mol	# 	Laumontite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1728.66 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.1904e+000 8.1763e-003 1.9005e+004 -1.4561e+001 -1.5851e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Lawsonite" //NEW_LINE('')// &
         ! &"        CaAl2Si2O7(OH)2:H2O +8.0000 H+  =  + 1.0000 Ca++ + 2.0000 Al+++ + 2.0000 SiO2 + 6.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           22.2132" //NEW_LINE('')// &
         ! &"	-delta_H	-244.806	kJ/mol	# 	Lawsonite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1158.1 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.3995e+001 -1.7668e-002 1.0119e+004 -8.3100e+000 1.5789e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &

         ! &"Magnesite" //NEW_LINE('')// &
         ! &"        MgCO3 +1.0000 H+  =  + 1.0000 HCO3- + 1.0000 Mg++" //NEW_LINE('')// &
         ! &"        log_k           2.2936" //NEW_LINE('')// &
         ! &"	-delta_H	-44.4968	kJ/mol	# 	Magnesite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-265.63 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.6665e+002 -4.9469e-002 6.4344e+003 6.5506e+001 1.0045e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Magnetite" //NEW_LINE('')// &
         ! &"        Fe3O4 +8.0000 H+  =  + 1.0000 Fe++ + 2.0000 Fe+++ + 4.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           10.4724" //NEW_LINE('')// &
         ! &"	-delta_H	-216.597	kJ/mol	# 	Magnetite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-267.25 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -3.0510e+002 -7.9919e-002 1.8709e+004 1.1178e+002 2.9203e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Merwinite" //NEW_LINE('')// &
         ! &"        MgCa3(SiO4)2 +8.0000 H+  =  + 1.0000 Mg++ + 2.0000 SiO2 + 3.0000 Ca++ + 4.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           68.5140" //NEW_LINE('')// &
         ! &"	-delta_H	-430.069	kJ/mol	# 	Merwinite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1090.8 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.2524e+002 -4.2525e-002 3.5619e+004 7.9984e+001 -9.8259e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Mesolite" //NEW_LINE('')// &
         &"        Na.676Ca.657Al1.99Si3.01O10:2.647H2O +7.9600 H+  =  + 0.6570 Ca++ + 0.6760 Na+ + 1.9900 Al+++ + 3.0100 SiO2 + 6.6270 H2O" //NEW_LINE('')// &
         &"        log_k           13.6191" //NEW_LINE('')// &
         &"	-delta_H	-179.744	kJ/mol	# 	Mesolite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-5947.05 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 7.1993e+000 5.9356e-003 1.4717e+004 -1.3627e+001 -9.8863e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Minnesotaite" //NEW_LINE('')// &
         ! &"        Fe3Si4O10(OH)2 +6.0000 H+  =  + 3.0000 Fe++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           13.9805" //NEW_LINE('')// &
         ! &"	-delta_H	-105.211	kJ/mol	# 	Minnesotaite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1153.37 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.8812e+001 1.7261e-002 1.9804e+004 -6.4410e+000 -2.0433e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Monticellite" //NEW_LINE('')// &
         ! &"        CaMgSiO4 +4.0000 H+  =  + 1.0000 Ca++ + 1.0000 Mg++ + 1.0000 SiO2 + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           29.5852" //NEW_LINE('')// &
         ! &"	-delta_H	-195.711	kJ/mol	# 	Monticellite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-540.8 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.5730e+001 -3.5567e-003 9.0789e+003 -6.3007e+000 1.4166e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Montmor-Na" //NEW_LINE('')// &
         &"        Na.33Mg.33Al1.67Si4O10(OH)2 +6.0000 H+  =  + 0.3300 Mg++ + 0.3300 Na+ + 1.6700 Al+++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           2.4844" //NEW_LINE('')// &
         &"	-delta_H	-93.2165	kJ/mol	# 	Montmor-Na" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1360.69 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.9601e+000 1.1342e-002 1.6051e+004 -1.4718e+001 -1.8160e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &



         ! &"Montmor-k" //NEW_LINE('')// &
         ! &"        K.33Mg.33Al1.67Si4O10(OH)2 +6.0000 H+  =  + 0.3300 K+ + 0.3300 Mg++ + 1.6700 Al+++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           2.1423" //NEW_LINE('')// &
         ! &"	-delta_H	-88.184	kJ/mol	# Calculated enthalpy of reaction	Montmor-K" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1362.83 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 8.4757e+000 1.1219e-002 1.5654e+004 -1.6833e+001 -1.8386e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &

         &"Montmor-Mg" //NEW_LINE('')// &
         &"        Mg.495Al1.67Si4O10(OH)2 +6.0000 H+  =  + 0.4950 Mg++ + 1.6700 Al+++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           2.3879" //NEW_LINE('')// &
         &"	-delta_H	-102.608	kJ/mol	# Calculated enthalpy of reaction	Montmor-Mg" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1357.87 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -6.8505e+000 9.0710e-003 1.6817e+004 -1.1887e+001 -1.8323e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &

         &"Montmor-Ca" //NEW_LINE('')// &
         &"        Ca.165Mg.33Al1.67Si4O10(OH)2 +6.0000 H+  =  + 0.1650 Ca++ + 0.3300 Mg++ + 1.6700 Al+++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           2.4952" //NEW_LINE('')// &
         &"	-delta_H	-100.154	kJ/mol	# Calculated enthalpy of reaction	Montmor-Ca" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1361.5 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 6.0725e+000 1.0644e-002 1.6024e+004 -1.6334e+001 -1.7982e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &



         ! &"Muscovite" //NEW_LINE('')// &
         ! &"        KAl3Si3O10(OH)2 +10.0000 H+  =  + 1.0000 K+ + 3.0000 Al+++ + 3.0000 SiO2 + 6.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           13.5858" //NEW_LINE('')// &
         ! &"	-delta_H	-243.224	kJ/mol	# 	Muscovite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1427.41 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 3.3085e+001 -1.2425e-002 1.2477e+004 -2.0865e+001 -5.4692e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Natrolite" //NEW_LINE('')// &
         &"        Na2Al2Si3O10:2H2O +8.0000 H+  =  + 2.0000 Al+++ + 2.0000 Na+ + 3.0000 SiO2 + 6.0000 H2O" //NEW_LINE('')// &
         &"        log_k           18.5204" //NEW_LINE('')// &
         &"	-delta_H	-186.971	kJ/mol	# 	Natrolite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-5718.56 kJ/mol" //NEW_LINE('')// &
         &"        -analytic -2.7712e+001 -2.7963e-003 1.6075e+004 1.5332e+000 -9.5765e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Nontronite-Ca" //NEW_LINE('')// &
         &"        Ca.165Fe2Al.33Si3.67H2O12 +7.3200 H+  =  + 0.1650 Ca++ + 0.3300 Al+++ + 2.0000 Fe+++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           -11.5822" //NEW_LINE('')// &
         &"	-delta_H	-38.138	kJ/mol	# 	Nontronite-Ca" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1166.7 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.6291e+001 4.3557e-003 1.0221e+004 -1.8690e+001 -1.5427e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Nontronite-H" //NEW_LINE('')// &
         ! &"        H.33Fe2Al.33Si3.67H2O12 +6.9900 H+  =  + 0.3300 Al+++ + 2.0000 Fe+++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         ! &"        log_k           -12.5401" //NEW_LINE('')// &
         ! &"	-delta_H	-30.452	kJ/mol	# 	Nontronite-H" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1147.12 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 9.7794e+001 1.4055e-002 4.7440e+003 -4.7272e+001 -1.2103e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Nontronite-K" //NEW_LINE('')// &
         &"        K.33Fe2Al.33Si3.67H2O12 +7.3200 H+  =  + 0.3300 Al+++ + 0.3300 K+ + 2.0000 Fe+++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           -11.8648" //NEW_LINE('')// &
         &"	-delta_H	-26.5822	kJ/mol	# 	Nontronite-K" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1167.93 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.3630e+001 4.7708e-003 1.0073e+004 -1.7407e+001 -1.5803e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Nontronite-Mg" //NEW_LINE('')// &
         &"        Mg.165Fe2Al.33Si3.67H2O12 +7.3200 H+  =  + 0.1650 Mg++ + 0.3300 Al+++ + 2.0000 Fe+++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           -11.6200" //NEW_LINE('')// &
         &"	-delta_H	-41.1779	kJ/mol	# 	Nontronite-Mg" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1162.93 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 5.5961e+001 1.0139e-002 8.0777e+003 -3.3164e+001 -1.4031e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Nontronite-Na" //NEW_LINE('')// &
         &"        Na.33Fe2Al.33Si3.67H2O12 +7.3200 H+  =  + 0.3300 Al+++ + 0.3300 Na+ + 2.0000 Fe+++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           -11.5263" //NEW_LINE('')// &
         &"	-delta_H	-31.5687	kJ/mol	# 	Nontronite-Na" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1165.8 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 6.7915e+001 1.2851e-002 7.1218e+003 -3.7112e+001 -1.3758e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Fe-Celadonite" //NEW_LINE('')// &
         &"        KFeAlSi4O10(OH)2 = +1.000K+     +1.000Fe+2     +1.000Al+3     -6.000H+     +8.0H2O + 4SiO2    -4.000H2O     " //NEW_LINE('')// &
         &"        log_k           2.73" //NEW_LINE('')// &
         &"	-delta_H	-83.838	kJ/mol	# 	Fe-Celadonite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-5498.159 kJ/mol" //NEW_LINE('')// &
         ! &"Okenite" //NEW_LINE('')// &
         ! &"        CaSi2O4(OH)2:H2O +2.0000 H+  =  + 1.0000 Ca++ + 2.0000 SiO2 + 3.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           10.3816" //NEW_LINE('')// &
         ! &"	-delta_H	-19.4974	kJ/mol	# 	Okenite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-749.641 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -7.7353e+001 1.5091e-002 1.3023e+004 2.1337e+001 -1.1831e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Smectite-low-Fe-Mg" //NEW_LINE('')// &
         &"        Ca.02Na.15K.2Fe.29Fe.16Mg.9Al1.25Si3.75H2O12 +7.0000 H+  =  + 0.0200 Ca++ + 0.1500 Na+ + 0.1600 Fe+++ + 0.2000" // &
         &" K+ + 0.2900 Fe++ + 0.9000 Mg++ + 1.2500 Al+++ + 3.7500 SiO2 + 4.5000 H2O" //NEW_LINE('')// &
         &"        log_k           11.0405" //NEW_LINE('')// &
         &"	-delta_H	-144.774	kJ/mol	# Smectite-low-Fe-Mg" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1352.12 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.7003e+001 6.9848e-003 1.8359e+004 -6.8896e+000 -1.6637e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Prehnite" //NEW_LINE('')// &
         &"        Ca2Al2Si3O10(OH)2 +10.0000 H+  =  + 2.0000 Al+++ + 2.0000 Ca++ + 3.0000 SiO2 + 6.0000 H2O" //NEW_LINE('')// &
         &"        log_k           32.9305" //NEW_LINE('')// &
         &"	-delta_H	-311.875	kJ/mol	# 	Prehnite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1481.65 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -3.5763e+001 -2.1396e-002 2.0167e+004 6.3554e+000 -7.4967e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Pseudowollastonite" //NEW_LINE('')// &
         ! &"        CaSiO3 +2.0000 H+  =  + 1.0000 Ca++ + 1.0000 H2O + 1.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           13.9997" //NEW_LINE('')// &
         ! &"	-delta_H	-79.4625	kJ/mol	# 	Pseudowollastonite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-388.9 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 2.6691e+001 6.3323e-003 5.5723e+003 -1.1822e+001 -3.6038e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Pyrite" //NEW_LINE('')// &
         &"        FeS2 +1.0000 H2O  =  + 0.2500 H+ + 0.2500 SO4-- + 1.0000 Fe++ + 1.7500 HS-" //NEW_LINE('')// &
         &"        log_k           -24.6534" //NEW_LINE('')// &
         &"	-delta_H	109.535	kJ/mol	# 	Pyrite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-41 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.4195e+002 -8.7948e-002 -6.2911e+002 9.9248e+001 -9.7454e+000" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Pyrrhotite" //NEW_LINE('')// &
         &"        FeS +1.0000 H+  =  + 1.0000 Fe++ + 1.0000 HS-" //NEW_LINE('')// &
         &"        log_k           -3.7193" //NEW_LINE('')// &
         &"	-delta_H	-7.9496	kJ/mol	# 	Pyrrhotite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-24 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -1.5785e+002 -5.2258e-002 3.9711e+003 6.3195e+001 6.2012e+001" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Quartz" //NEW_LINE('')// &
         ! &"        SiO2  =  + 1.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           -3.9993" //NEW_LINE('')// &
         ! &"	-delta_H	32.949	kJ/mol	# 	Quartz" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-217.65 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 7.7698e-002 1.0612e-002 3.4651e+003 -4.3551e+000 -7.2138e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"-Vm 22.67" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         ! &"Rankinite" //NEW_LINE('')// &
         ! &"        Ca3Si2O7 +6.0000 H+  =  + 2.0000 SiO2 + 3.0000 Ca++ + 3.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           51.9078" //NEW_LINE('')// &
         ! &"	-delta_H	-302.089	kJ/mol	# 	Rankinite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-941.7 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -9.6393e+001 -1.6592e-002 2.4832e+004 3.2541e+001 -9.4630e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         &"Saponite-Mg" //NEW_LINE('')// &
         !&"        Mg3Ca.165Al.33Si3.67O10(OH)2 +7.3200 H+  =  + 0.3300 Al+++ + .1650 Ca ++ + 3 Mg++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         !&"" //NEW_LINE('')// &
         &"	Mg3.165Al.33Si3.67O10(OH)2 +7.3200 H+  =  + 0.3300 Al+++ + 3.1650 Mg++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           26.2523" //NEW_LINE('')// &
         &"	-delta_H	-210.822	kJ/mol	# 	Saponite-Mg" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1432.79 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 9.8888e+000 1.4320e-002 1.9418e+004 -1.5259e+001 -1.3716e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Saponite-Na" //NEW_LINE('')// &
         &"        Na.33Mg3Al.33Si3.67O10(OH)2 +7.3200 H+  =  + 0.3300 Al+++ + 0.3300 Na+ + 3.0000 Mg++ + 3.6700 SiO2 + 4.6600 H2O" //NEW_LINE('')// &
         &"        log_k           26.3459" //NEW_LINE('')// &
         &"	-delta_H	-201.401	kJ/mol	# 	Saponite-Na" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1435.61 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -6.7611e+001 4.7327e-003 2.3586e+004 1.2868e+001 -1.6493e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         &"Scolecite" //NEW_LINE('')// &
         &"        CaAl2Si3O10:3H2O +8.0000 H+  =  + 1.0000 Ca++ + 2.0000 Al+++ + 3.0000 SiO2 + 7.0000 H2O" //NEW_LINE('')// &
         &"        log_k           15.8767" //NEW_LINE('')// &
         &"	-delta_H	-204.93	kJ/mol	# 	Scolecite" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-6048.92 kJ/mol" //NEW_LINE('')// &
         &"        -analytic 5.0656e+001 -3.1485e-003 1.0574e+004 -2.5663e+001 -5.2769e+005" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"SiO2(am)" //NEW_LINE('')// &
         ! &"       SiO2  =  + 1.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           -2.7136" //NEW_LINE('')// &
         ! &"	-delta_H	20.0539	kJ/mol	# 	SiO2(am)" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-214.568 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.2109e+000 7.0767e-003 2.3634e+003 -3.4449e+000 -4.8591e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Siderite" //NEW_LINE('')// &
         ! &"        FeCO3 +1.0000 H+  =  + 1.0000 Fe++ + 1.0000 HCO3-" //NEW_LINE('')// &
         ! &"        log_k           -0.1920" //NEW_LINE('')// &
         ! &"	-delta_H	-32.5306	kJ/mol	# 	Siderite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-179.173 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.5990e+002 -4.9361e-002 5.4947e+003 6.3032e+001 8.5787e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"-Vm 29.2" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         &"Smectite-high-Fe-Mg" //NEW_LINE('')// &
         ! &"#        Ca.025Na.1K.2Fe++.5Fe+++.2Mg1.15Al1.25Si3.5H2O12 +8.0000 H+  =  + 0.0250 Ca++ + 0.1000 Na+ + 0.2000 Fe+++ + 0.2000 K+ " //&
         ! &"+ 0.5000 Fe++ + 1.1500 Mg++ + 1.2500 Al+++ + 3.5000 SiO2 + 5.0000 H2O" //NEW_LINE('')// &
         &"        Ca.025Na.1K.2Fe.5Fe.2Mg1.15Al1.25Si3.5H2O12 +8.0000 H+  =  + 0.0250 Ca++ + 0.1000 Na+ + 0.2000 Fe+++ + 0.2000 K+ + 0.5000 Fe++ " //&
         &"+ 1.1500 Mg++ + 1.2500 Al+++ + 3.5000 SiO2 + 5.0000 H2O " //NEW_LINE('')// &
         &"        log_k           17.4200" //NEW_LINE('')// &
         &"	-delta_H	-199.841	kJ/mol	# 	Smectite-high-Fe-Mg" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1351.39 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -9.6102e+000 1.2551e-003 1.8157e+004 -7.9862e+000 -1.3005e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &
         &"" //NEW_LINE('')// &
         ! &"Stilbite" //NEW_LINE('')// &
         ! &"        Ca1.019Na.136K.006Al2.18Si6.82O18:7.33H2O +8.7200 H+  =  + 0.0060 K+ + 0.1360 Na+ " //&
         ! &"+ 1.0190 Ca++ + 2.1800 Al+++ + 6.8200 SiO2 + 11.6900 H2O" //NEW_LINE('')// &
         ! &"        log_k           1.0545" //NEW_LINE('')// &
         ! &"	-delta_H	-83.0019	kJ/mol	# 	Stilbite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-11005.7 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.4483e+001 3.0987e-002 2.8013e+004 -1.5802e+001 -3.4491e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Tobermorite-9A" //NEW_LINE('')// &
         ! &"        Ca5Si6H6O20 +10.0000 H+  =  + 5.0000 Ca++ + 6.0000 SiO2 + 8.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           69.0798" //NEW_LINE('')// &
         ! &"	-delta_H	-329.557	kJ/mol	# 	Tobermorite-9A" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-2375.42 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -6.3384e+001 1.1722e-002 3.8954e+004 1.2268e+001 -2.8681e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Tremolite" //NEW_LINE('')// &
         ! &"        Ca2Mg5Si8O22(OH)2 +14.0000 H+  =  + 2.0000 Ca++ + 5.0000 Mg++ + 8.0000 H2O + 8.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           61.2367" //NEW_LINE('')// &
         ! &"	-delta_H	-406.404	kJ/mol	# 	Tremolite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-2944.04 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 8.5291e+001 4.6337e-002 3.9465e+004 -5.4414e+001 -3.1913e+006" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &

         ! &"Fe" //NEW_LINE('')// &
         ! &"        Fe +2.0000 H+ +0.5000 O2  =  + 1.0000 Fe++ + 1.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           59.0325" //NEW_LINE('')// &
         ! &"	-delta_H	-372.029	kJ/mol		Fe" //NEW_LINE('')// &
         ! &"# Enthalpy of formation:	0 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -6.2882e+001 -2.0379e-002 2.0690e+004 2.3673e+001 3.2287e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &


         ! &"Ferrihydrite" //NEW_LINE('')// &
         ! &"        Fe(OH)3 + 3H+ = Fe+3 + 3H2O" //NEW_LINE('')// &
         ! &"        log_k	3.191" //NEW_LINE('')// &
         ! &"	delta_h	-73.374	kJ" //NEW_LINE('')// &

         ! &"Fe3(OH)8" //NEW_LINE('')// &
         ! &"        Fe3(OH)8 + 8H+ = 2Fe+3 + Fe+2 + 8H2O" //NEW_LINE('')// &
         ! &"        log_k   20.222" //NEW_LINE('')// &
         ! &"	delta_h -0      kcal" //NEW_LINE('')// &

         &"Talc" //NEW_LINE('')// &
         &"        Mg3Si4O10(OH)2 +6.0000 H+  =  + 3.0000 Mg++ + 4.0000 H2O + 4.0000 SiO2" //NEW_LINE('')// &
         &"        log_k           21.1383" //NEW_LINE('')// &
         &"-delta_H	-148.737	kJ/mol	# Calculated enthalpy of reaction	Talc" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-1410.92 kcal/mol" //NEW_LINE('')// &
         &"        -analytic 1.1164e+001 2.4724e-002 1.9810e+004 -1.7568e+001 -1.8241e+006" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &


         &"Chlorite(14A)" //NEW_LINE('')// &
         &"        Mg5Al2Si3O10(OH)8 + 16H+ = 5Mg+2 + 2Al+3 + 3.0 SiO2 + 12H2O" //NEW_LINE('')// &
         &"        log_k           68.38" //NEW_LINE('')// &
         &"delta_h -151.494 kcal" //NEW_LINE('')// &

         &"" //NEW_LINE('')// &
         ! &"Fe(OH)2" //NEW_LINE('')// &
         ! &"        Fe(OH)2 +2.0000 H+  =  + 1.0000 Fe++ + 2.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           13.9045" //NEW_LINE('')// &
         ! &"	-delta_H	-95.4089	kJ/mol		Fe(OH)2" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-568.525 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -8.6666e+001 -1.8440e-002 7.5723e+003 3.2597e+001 1.1818e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &

         ! CHLORITE MINERALS
         !
         ! &"Chamosite-7A" //NEW_LINE('')// &
         ! &"        Fe2Al2SiO5(OH)4 +10.0000 H+  =  + 1.0000 SiO2 + 2.0000 Al+++ + 2.0000 Fe++ + 7.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           32.8416" //NEW_LINE('')// &
         ! &"-delta_H	-364.213	kJ/mol	# Calculated enthalpy of reaction	Chamosite-7A" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-902.407 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -2.5581e+002 -7.0890e-002 2.4619e+004 9.1789e+001 3.8424e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         !
         !
         &"Clinochlore-14A" //NEW_LINE('')// &
         &"        Mg5Al2Si3O10(OH)8 +16.0000 H+  =  + 2.0000 Al+++ + 3.0000 SiO2 + 5.0000 Mg++ + 12.0000 H2O" //NEW_LINE('')// &
         &"        log_k           67.2391" //NEW_LINE('')// &
         &"-delta_H	-612.379	kJ/mol	# Calculated enthalpy of reaction	Clinochlore-14A" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-2116.96 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.0441e+002 -6.2268e-002 3.5388e+004 6.9239e+001 5.5225e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &


         &"Clinochlore-7A" //NEW_LINE('')// &
         &"        Mg5Al2Si3O10(OH)8 +16.0000 H+  =  + 2.0000 Al+++ + 3.0000 SiO2 + 5.0000 Mg++ + 12.0000 H2O" //NEW_LINE('')// &
         &"        log_k           70.6124" //NEW_LINE('')// &
         &"-delta_H	-628.14	kJ/mol	# Calculated enthalpy of reaction	Clinochlore-7A" //NEW_LINE('')// &
         ! &"#	Enthalpy of formation:	-2113.2 kcal/mol" //NEW_LINE('')// &
         &"        -analytic -2.1644e+002 -6.4187e-002 3.6548e+004 7.4123e+001 5.7037e+002" //NEW_LINE('')// &
       !  &"#       -Range:  0-300" //NEW_LINE('')// &


         ! &"Ripidolite-14A" //NEW_LINE('')// &
         ! &"        Mg3Fe2Al2Si3O10(OH)8 +16.00 H+  =  + 2.00 Al+++ + 2.00 Fe++ + 3.00 Mg++ + 3.00 SiO2 + 12.00 H2O" //NEW_LINE('')// &
         ! &"        log_k           60.9638" //NEW_LINE('')// &
         ! &"-delta_H	-572.472	kJ/mol	# Calculated enthalpy of reaction	Ripidolite-14A" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1947.87 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.8376e+002 -6.1934e-002 3.2458e+004 6.2290e+001 5.0653e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         !
         ! &"Ripidolite-7A" //NEW_LINE('')// &
         ! &"        Mg3Fe2Al2Si3O10(OH)8 +16.00 H+  =  + 2.00 Al+++ + 2.00 Fe++ + 3.00 Mg++ + 3.00 SiO2 + 12.00 H2O" //NEW_LINE('')// &
         ! &"        log_k           64.3371" //NEW_LINE('')// &
         ! &"-delta_H	-586.325	kJ/mol	# Calculated enthalpy of reaction	Ripidolite-7A" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1944.56 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.9557e+002 -6.3779e-002 3.3634e+004 6.7057e+001 5.2489e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &

         ! &"Fe(OH)3" //NEW_LINE('')// &
         ! &"        Fe(OH)3 +3.0000 H+  =  + 1.0000 Fe+++ + 3.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           5.6556" //NEW_LINE('')// &
         ! &"	-delta_H	-84.0824	kJ/mol		Fe(OH)3" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-823.013 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.3316e+002 -3.1284e-002 7.9753e+003 4.9052e+001 1.2449e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &

         ! &"Troilite" //NEW_LINE('')// &
         ! &"        FeS +1.0000 H+  =  + 1.0000 Fe++ + 1.0000 HS-" //NEW_LINE('')// &
         ! &"        log_k           -3.8184" //NEW_LINE('')// &
         ! &"	-delta_H	-7.3296	kJ/mol	# 	Troilite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-101.036 kJ/mol" //NEW_LINE('')// &
         ! &"        -analytic -1.6146e+002 -5.3170e-002 4.0461e+003 6.4620e+001 6.3183e+001" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Wollastonite" //NEW_LINE('')// &
         ! &"        CaSiO3 +2.0000 H+  =  + 1.0000 Ca++ + 1.0000 H2O + 1.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           13.7605" //NEW_LINE('')// &
         ! &"	-delta_H	-76.5756	kJ/mol	# 	Wollastonite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-389.59 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 3.0931e+001 6.7466e-003 5.1749e+003 -1.3209e+001 -3.4579e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Xonotlite" //NEW_LINE('')// &
         ! &"        Ca6Si6O17(OH)2 +12.0000 H+  =  + 6.0000 Ca++ + 6.0000 SiO2 + 7.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           91.8267" //NEW_LINE('')// &
         ! &"	-delta_H	-495.457	kJ/mol	# 	Xonotlite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-2397.25 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 1.6080e+003 3.7309e-001 -2.2548e+004 -6.2716e+002 -3.8346e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-200" //NEW_LINE('')// &
         ! &"" //NEW_LINE('')// &
         ! &"Zoisite" //NEW_LINE('')// &
         ! &"        Ca2Al3(SiO4)3OH +13.0000 H+  =  + 2.0000 Ca++ + 3.0000 Al+++ + 3.0000 SiO2 + 7.0000 H2O" //NEW_LINE('')// &
         ! &"        log_k           43.3017" //NEW_LINE('')// &
         ! &"	-delta_H	-458.131	kJ/mol	# 	Zoisite" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-1643.69 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic 2.5321e+000 -3.5886e-002 1.9902e+004 -6.2443e+000 3.1055e+002" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &

         ! MINS FROM ANOTHER DATABASE
         &"Vermiculite-Na" //NEW_LINE('')// &
         ! &"Na0.85Mg3Si3.15Al0.85O10(OH)2 = +3.000Mg+2  +0.850Na+  +0.850Al+3  -9.400H+  +3.150H4(SiO4)  -0.600H2O" //NEW_LINE('')// &
         &"Na0.85Mg3Si3.15Al0.85O10(OH)2 = +3.000Mg+2  +0.850Na+  +0.850Al+3  -9.400H+  +6.30H2O + 3.15SiO2  -0.600H2O" //NEW_LINE('')// &
         &"  log_k  40.17  #" //NEW_LINE('')// &
         &"  delta_h  -354.987   kJ/mol  #" //NEW_LINE('')// &
         !&"  # Enthalpy of formation:    -6139.206  kJ/mol  07VIE" //NEW_LINE('')// &

         ! FROM SIT.dat
         &"Fe-Saponite-Ca" //NEW_LINE('')// &
         ! &"Ca0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Ca+2     +3.000Fe+2     +0.340Al+3     -7.360H+     +3.660H4(SiO4)     -2.640H2O" //NEW_LINE('')// &
         ! &"Ca0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Ca+2     +3.000Fe+2     +0.340Al+3     -7.360H+   +7.32H2O  +3.66SiO2     -2.640H2O" //NEW_LINE('')// &
         &"Ca0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Ca+2     +3.000Fe+2     +0.340Al+3     -7.360H+   +4.68H2O  +3.66SiO2" //NEW_LINE('')// &
         &"  log_k     22.43        #" //NEW_LINE('')// &
         &"  delta_h  -222.166      kJ/mol        #" //NEW_LINE('')// &
         !&"  # Enthalpy of formation:             -4916.58      kJ/mol        07VIE" //NEW_LINE('')// &



         ! FROM SIT.dat
         &"Fe-Saponite-Mg" //NEW_LINE('')// &
         ! &"Mg0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Mg+2     +3.000Fe+2     +0.340Al+3     -7.360H+     +3.660H4(SiO4)     -2.640H2O" //NEW_LINE('')// &
         ! &"Mg0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Mg+2     +3.000Fe+2     +0.340Al+3     -7.360H+   +7.32H2O  +3.66SiO2     -2.640H2O" //NEW_LINE('')// &
         &"Mg0.17Fe3Al0.34Si3.66O10(OH)2 = +0.170Mg+2     +3.000Fe+2     +0.340Al+3     -7.360H+   +4.68H2O  +3.66SiO2" //NEW_LINE('')// &
         &"  log_k     21.73        #" //NEW_LINE('')// &
         &"  delta_h  -222.096      kJ/mol        #" //NEW_LINE('')// &
         !&"  # Enthalpy of formation:             -4903.73      kJ/mol        07VIE" //NEW_LINE('')// &
         !
         ! &"Lepidocrocite" //NEW_LINE('')// &
         ! &"FeOOH = +1.000Fe+3  -3.000H+  +2.000H2O  " //NEW_LINE('')// &
         ! &"  log_k  0.75   #98DIA in 98CHI" //NEW_LINE('')// &
         ! &"  delta_h  -64.26  kJ/mol  #" //NEW_LINE('')// &
         ! &"  # Enthalpy of formation:    -556.4  kJ/mol  " //NEW_LINE('')// &
         ! !
         ! &"Vermiculite-K" //NEW_LINE('')// &
         ! &"K0.85Mg3Si3.15Al0.85O10(OH)2 = +3.000Mg+2  +0.850K+  +0.850Al+3  -9.400H+  +6.30H2O + 3.15SiO2  -0.600H2O " //NEW_LINE('')// &
         ! &"  log_k  36.86  #" //NEW_LINE('')// &
         ! &"  delta_h  -331.639   kJ/mol  #" //NEW_LINE('')// &
         ! &"  # Enthalpy of formation:    -6172.584  kJ/mol  07VIE" //NEW_LINE('')// &
         !
         ! &"Saponite-K" //NEW_LINE('')// &
         ! &"K0.33Mg3Al0.33Si3.67O10(OH)2 = +3.000Mg+2  +0.330K+  +0.330Al+3  -7.320H+  +7.34H2O + 3.67SiO2  -2.680H2O" //NEW_LINE('')// &
         ! &"  log_k  28.1   #" //NEW_LINE('')// &
         ! &"  delta_h  -252.497   kJ/mol  #" //NEW_LINE('')// &
         ! &"  # Enthalpy of formation:    -6005.94   kJ/mol  07VIE" //NEW_LINE('')// &
         !
         &"Vermiculite-Ca" //NEW_LINE('')// &
         &"Ca0.43Mg3Si3.14Al0.86O10(OH)2 = +0.430Ca+2  +3.000Mg+2  +0.860Al+3  -9.440H+  +6.28H2O + 3.14SiO2  -0.560H2O" //NEW_LINE('')// &
         &"  log_k  40.68  #" //NEW_LINE('')// &
         &"  delta_h  -378.219   kJ/mol  #" //NEW_LINE('')// &
         !&"  # Enthalpy of formation:    -6147.38   kJ/mol  07VIE" //NEW_LINE('')// &


         &"Vermiculite-Mg" //NEW_LINE('')// &
         &"Mg0.43Mg3Si3.14Al0.86O10(OH)2 = +3.430Mg+2  +0.860Al+3  -9.440H+  +6.28H2O + 3.14SiO2  -0.560H2O" //NEW_LINE('')// &
         &"  log_k  38.8   #" //NEW_LINE('')// &
         &"  delta_h  -377.469   kJ/mol  #" //NEW_LINE('')// &
         !&"  # Enthalpy of formation:    -6115.45   kJ/mol  07VIE" //NEW_LINE('')// &

         ! &"Chalcedony" //NEW_LINE('')// &
         ! &"        SiO2  =  + 1.0000 SiO2" //NEW_LINE('')// &
         ! &"        log_k           -3.7281" //NEW_LINE('')// &
         ! &"	-delta_H	31.4093	kJ/mol	# Calculated enthalpy of reaction	Chalcedony" //NEW_LINE('')// &
         ! ! &"#	Enthalpy of formation:	-217.282 kcal/mol" //NEW_LINE('')// &
         ! &"        -analytic -9.0068e+000 9.3241e-003 4.0535e+003 -1.0830e+000 -7.5077e+005" //NEW_LINE('')// &
         ! &"#       -Range:  0-300" //NEW_LINE('')// &


         &""! //NEW_LINE('')// &

	!-after L5 super long string!

	solute_step = solute_in
	dt = timestep_in

! 	write(*,*) "m1" , dt/mix_in(1)
! 	write(*,*) "m2" , dt/mix_in(2)
! 	write(*,*) "m" , dt/mix_in(3)

	kinetics = " precipitate_only"
	!kinetics = " "

	! write(*,*) "mix_in(1)" , mix_in(1)
	! write(*,*) "dt" , dt
	! write(*,*) "(dt/mix_in(1))" , (dt/mix_in(1))

	! write(*,*) "solute_step"
	! write(*,*) solute_step
	! write(*,*) " "


	do i=1,n_box


		! write(*,*) mix_in
		!# MIXING

		if (i == 1) then
			! solute_in(:,1) = solute_step(:,1) * (1.0 - (dt/mix_in(1)) - (0.1*dt/mix_in(2)) ) + solute0_in * (dt/mix_in(1)) + solute_step(:,2) * (0.1*dt/mix_in(2))
			! !write(*,*) "solute_in1 after" , solute_in(:,1)
			! n=2
			! solute_inter = solute_in(n,1)
			solute_in(:,1) = solute_step(:,1) * (1.0 - (dt/mix_in(1)) ) + solute0_in * (dt/mix_in(1))

			!# FIX [K] OR [Mg]
			! solute_in(8,1) = solute0_in(8)
			! solute_in(6,1) = solute0_in(6)

		end if



		if (i == 2) then
			! step 1 : put SW into ch_a_0, make ch_a_1
			solute_in(:,2) = solute_step(:,2) * (1.0 - (dt/mix_in(2)) ) + solute0_in * (dt/mix_in(2))
			! step 2 : put ch_b_0 into ch_a_1
			solute_step(1,2) = solute_in(1,2)
			solute_step(2,2) = solute_in(2,2)
			solute_step(4:,2) = solute_in(4:,2)

			solute_in(:,2) = solute_in(:,2) * (1.0 - (dt/mix_in(3)) ) + solute_step(:,3) * (dt/mix_in(3))

			!# FIX [K] OR [Mg]
			! solute_in(8,2) = solute0_in(8)
			! solute_in(6,2) = solute0_in(6)

		end if

		if (i == 3) then
			! solute_in(:,3) = solute_step(:,3) * (1.0 - (dt/mix_in(3)) ) + solute_step(:,2) * (dt/mix_in(3))
			! solute_in(:,2) = solute_step(:,2) * (1.0 - (dt/mix_in(3)) ) + solute_step(:,3) * (dt/mix_in(3))

			! no need to mix ch_b with seawater any more
			!solute_in(:,3) = solute_step(:,2) * (1.0 - (dt/mix_in(2)) ) + solute0_in * (dt/mix_in(2))

			! step 3 : put ch_a_1 into ch_b_0
			solute_in(:,3) = solute_step(:,3) * (1.0 - (dt/mix_in(3)) ) + solute_step(:,2) * (dt/mix_in(3))

			!# FIX [K] OR [Mg]
			! solute_in(8,3) = solute0_in(8)
			! solute_in(6,3) = solute0_in(6)
		end if

    ! write(*,*) "n_box: " , i
    ! write(*,*) "solute_in" , solute_in(:,i)
	! write(*,*) " "


! 		! write(*,*) "running geochem for box:" , i
! 		write(*,*) "glass" , primary_in(5,i)
! 		write(*,*) "basalt1" , primary_in(4,i)
! 		write(*,*) "basalt2" , primary_in(3,i)
! 		write(*,*) "basalt3" , primary_in(2,i)


		! solute_inS TO STRINGS
		write(s_ph,'(F25.10)') solute_in(1,i)
		write(s_alk,'(F25.10)') solute_in(2,i)
		write(s_water,'(F25.10)') solute_step(3,i)
		write(s_co2,'(F25.10)') solute_in(4,i)
		write(s_ca,'(F25.10)') solute_in(5,i)
		write(s_mg,'(F25.10)') solute_in(6,i)
		write(s_na,'(F25.10)') solute_in(7,i)
		write(s_k,'(F25.10)') solute_in(8,i)
		write(s_fe,'(F25.10)') solute_in(9,i)
		write(s_s,'(F25.10)') solute_in(10,i)
		write(s_si,'(F25.10)') solute_in(11,i)
		write(s_cl,'(F25.10)') solute_in(12,i)
		write(s_al,'(F25.10)') solute_in(13,i)
		write(s_hco3,'(F25.10)') solute_in(14,i)
		write(s_co3,'(F25.10)') solute_in(15,i)

		! MEDIUM TO STRINGS
		write(s_w,'(F25.10)') solute_step(3,i)

		! PRIMARIES TO STRINGS
		write(s_feldspar,'(F25.10)') primary_in(1,i)
		write(s_augite,'(F25.10)') primary_in(2,i)
		write(s_pigeonite,'(F25.10)') primary_in(3,i)
		write(s_basalt3,'(F25.10)') primary_in(2,i)
		write(s_basalt2,'(F25.10)') primary_in(3,i)
		write(s_basalt1,'(F25.10)') primary_in(4,i)
		write(s_glass,'(F25.10)') primary_in(5,i)



		!# secondaries to strings
		WRITE(s_kaolinite,'(F25.10)') secondary_in(1,i)
		WRITE(s_saponite,'(F25.10)') secondary_in(2,i)
		WRITE(s_celadonite,'(F25.10)') secondary_in(3,i)
		WRITE(s_clinoptilolite,'(F25.10)') secondary_in(4,i)
		WRITE(s_pyrite,'(F25.10)') secondary_in(5,i)
		WRITE(s_mont_na,'(F25.10)') secondary_in(6,i)
		WRITE(s_goethite,'(F25.10)') secondary_in(7,i)
		WRITE(s_smectite,'(F25.10)') secondary_in(8,i)
		WRITE(s_calcite,'(F25.10)') secondary_in(9,i)
		WRITE(s_kspar,'(F25.10)') secondary_in(10,i)
		WRITE(s_saponite_na,'(F25.10)') secondary_in(11,i) !!!!
		WRITE(s_nont_na,'(F25.10)') secondary_in(12,i)
		WRITE(s_nont_mg,'(F25.10)') secondary_in(13,i)
		WRITE(s_fe_celadonite,'(F25.10)') secondary_in(14,i)
		WRITE(s_nont_ca,'(F25.10)') secondary_in(15,i)
		WRITE(s_mesolite,'(F25.10)') secondary_in(16,i)
		WRITE(s_hematite,'(F25.10)') secondary_in(17,i)
		WRITE(s_mont_ca,'(F25.10)') secondary_in(18,i)
		WRITE(s_verm_ca,'(F25.10)') secondary_in(19,i)
		WRITE(s_analcime,'(F25.10)') secondary_in(20,i)
		WRITE(s_phillipsite,'(F25.10)') secondary_in(21,i)
		WRITE(s_mont_mg,'(F25.10)') secondary_in(22,i)
		WRITE(s_gismondine,'(F25.10)') secondary_in(23,i)
		WRITE(s_verm_mg,'(F25.10)') secondary_in(24,i)
		WRITE(s_natrolite,'(F25.10)') secondary_in(25,i)
		WRITE(s_talc,'(F25.10)') secondary_in(26,i) !!!!!!!!!
		WRITE(s_smectite_low,'(F25.10)') secondary_in(27,i)
		WRITE(s_prehnite,'(F25.10)') secondary_in(28,i)
		WRITE(s_chlorite,'(F25.10)') secondary_in(29,i) !!!!!!!!
		WRITE(s_scolecite,'(F25.10)') secondary_in(30,i)
		WRITE(s_clinochlore14a,'(F25.10)') secondary_in(31,i)
		WRITE(s_clinochlore7a,'(F25.10)') secondary_in(32,i)
		WRITE(s_saponite_ca,'(F25.10)') secondary_in(33,i)
		WRITE(s_verm_na,'(F25.10)') secondary_in(34,i)
		WRITE(s_pyrrhotite,'(F25.10)') secondary_in(35,i)
		WRITE(s_fe_saponite_ca,'(F25.10)') secondary_in(36,i) !!!
		WRITE(s_fe_saponite_mg,'(F25.10)') secondary_in(37,i) !!!
		WRITE(s_daphnite_7a,'(F25.10)') secondary_in(38,i) !!!
		WRITE(s_daphnite_14a,'(F25.10)') secondary_in(39,i) !!!
		WRITE(s_epidote,'(F25.10)') secondary_in(40,i) !!!

! 		write(s_verm_k,'(F25.10)') secondary_in(55,i)
! 		write(s_mont_mg,'(F25.10)') secondary_in(56,i)
		!write(s_mont_mg,'(F25.10)') secondary_in(57,i)

		! OTHER INFORMATION TO STRINGS
! 		if (temp_in(i) .gt. 60.0) then
! 			temp_in(i) = 60.0
! 		end if
		write(s_temp,'(F25.10)') temp_in(i)
		write(s_timestep,'(F25.10)') timestep_in
		write(s_area,'(F25.10)') area_in(i)



		input_string = "SOLUTION 1 " //NEW_LINE('')// &
		&"    units   mol/kgw" //NEW_LINE('')// &
		&"    temp" // trim(s_temp) //NEW_LINE('')// &
		&"    Ca " // trim(s_ca) //NEW_LINE('')// &
		&"    Mg " // trim(s_mg) //NEW_LINE('')// &
		&"    Na " // trim(s_na) //NEW_LINE('')// &
		&"    K " // trim(s_k) //NEW_LINE('')// &
		&"    Fe " // trim(s_fe) //NEW_LINE('')// &
		&"    S "// trim(s_s)  //NEW_LINE('')// &
		&"    Si " // trim(s_si) //NEW_LINE('')// &
		&"    Cl " // trim(s_cl) //NEW_LINE('')// &
		&"    Al " // trim(s_al) //NEW_LINE('')// &
		&"    C " // trim(s_co2) //NEW_LINE('')// &
		&"    Alkalinity " // trim(s_alk) //NEW_LINE('')// &
		&"    -water "// trim(s_water) // " # kg" //NEW_LINE('')// &


		&"EQUILIBRIUM_PHASES 1" //NEW_LINE('')


		input_string = TRIM(input_string) //      "    Goethite " // TRIM(s_precip) // TRIM(s_goethite) // kinetics //NEW_LINE('')


		input_string = TRIM(input_string) //      "    Celadonite " // TRIM(s_precip) // TRIM(s_celadonite) // kinetics //NEW_LINE('') ! mica
		input_string = TRIM(input_string) //      "    Saponite-Mg " // TRIM(s_precip) // TRIM(s_saponite) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Pyrite " // TRIM(s_precip) // TRIM(s_pyrite) // kinetics //NEW_LINE('')
		input_string = TRIM(input_string) //      "    Saponite-Na " // TRIM(s_precip) // TRIM(s_saponite_na) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Nontronite-Na " // TRIM(s_precip) // TRIM(s_nont_na) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Nontronite-Mg " // TRIM(s_precip) // TRIM(s_nont_mg) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Fe-Celadonite " // TRIM(s_precip) // TRIM(s_fe_celadonite) // kinetics //NEW_LINE('') ! mica

		! new phase
		input_string = TRIM(input_string) //      "    Nontronite-Ca " // TRIM(s_precip) // TRIM(s_nont_ca) // kinetics //NEW_LINE('') ! smectite
		! new phase
		input_string = TRIM(input_string) //      "    Montmor-Ca " // TRIM(s_precip) // TRIM(s_mont_ca) // kinetics //NEW_LINE('') ! smectite
		! new phase
		input_string = TRIM(input_string) //      "    Fe-Saponite-Ca " // TRIM(s_precip) // TRIM(s_fe_saponite_ca) // kinetics //NEW_LINE('') ! sap smec
		!new phase
		input_string = TRIM(input_string) //      "    Vermiculite-Ca " // TRIM(s_precip) // TRIM(s_verm_ca) // kinetics //NEW_LINE('') ! clay
		! new phase
		input_string = TRIM(input_string) //      "    Prehnite " // trim(s_precip) // trim(s_prehnite) // kinetics //NEW_LINE('')



		input_string = TRIM(input_string) //      "    Analcime " // TRIM(s_precip) // TRIM(s_analcime) // kinetics //NEW_LINE('') ! zeolite
		input_string = TRIM(input_string) //      "    Phillipsite " // TRIM(s_precip) // TRIM(s_phillipsite) // kinetics //NEW_LINE('') ! zeolite
		input_string = TRIM(input_string) //      "    Natrolite " // TRIM(s_precip) // TRIM(s_natrolite) // kinetics //NEW_LINE('') ! zeolite
		input_string = TRIM(input_string) //      "    Talc " // TRIM(s_precip) // TRIM(s_talc) // kinetics //NEW_LINE('')
		input_string = TRIM(input_string) //      "    Chlorite(14A) " // TRIM(s_precip) // TRIM(s_chlorite) // kinetics //NEW_LINE('') ! chlorite
		input_string = TRIM(input_string) //      "    Clinochlore-14A " // TRIM(s_precip) // TRIM(s_clinochlore14a) // kinetics //NEW_LINE('') ! chlorite
		input_string = TRIM(input_string) //      "    Clinochlore-7A " // TRIM(s_precip) // TRIM(s_clinochlore7a) // kinetics //NEW_LINE('') ! chlorite
		!input_string = TRIM(input_string) //      "    Saponite-Ca " // TRIM(s_precip) // TRIM(s_saponite_ca) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Pyrrhotite " // TRIM(s_precip) // TRIM(s_pyrrhotite) // kinetics //NEW_LINE('') ! sulfide




		input_string = TRIM(input_string) //      "    Fe-Saponite-Mg " // TRIM(s_precip) // TRIM(s_fe_saponite_mg) // kinetics //NEW_LINE('')! sap smec


		input_string = TRIM(input_string) //      "    Calcite " // TRIM(s_precip) // TRIM(s_calcite) // kinetics //NEW_LINE('')! calcite

			 ! 		!&"    Calcite " // trim(s_precip) // trim(s_calcite) // kinetics //NEW_LINE('')// & ! .135

		input_string = TRIM(input_string) //      "    Montmor-Na " // TRIM(s_precip) // TRIM(s_mont_na) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Montmor-Mg " // TRIM(s_precip) // TRIM(s_mont_mg) // kinetics //NEW_LINE('') ! smectite




		input_string = TRIM(input_string) //      "    Smectite-high-Fe-Mg " // trim(s_precip) // trim(s_smectite) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "    Vermiculite-Na " // TRIM(s_precip) // TRIM(s_verm_na) // kinetics //NEW_LINE('') ! clay




		input_string = TRIM(input_string) //      "    Vermiculite-Mg " // TRIM(s_precip) // TRIM(s_verm_mg) // kinetics //NEW_LINE('') ! clay
		!input_string = TRIM(input_string) //      "    Hematite " // TRIM(s_precip) // TRIM(s_hematite) // kinetics //NEW_LINE('') ! iron oxide
		!input_string = TRIM(input_string) //      "    Epidote  " // trim(s_precip) // trim(s_epidote) // kinetics //NEW_LINE('')
		input_string = TRIM(input_string) //      "    Smectite-low-Fe-Mg " // trim(s_precip) // trim(s_smectite_low) // kinetics //NEW_LINE('') ! smectite
		input_string = TRIM(input_string) //      "   Daphnite-7a " // trim(s_precip) // trim(s_daphnite_7a) // kinetics //NEW_LINE('') ! chlorite
		input_string = TRIM(input_string) //      "   Daphnite-14a " // trim(s_precip) // trim(s_daphnite_14a) // kinetics //NEW_LINE('')! chlorite
			 input_string = TRIM(input_string) //"    Kaolinite " // trim(s_precip) // trim(s_kaolinite) // kinetics //NEW_LINE('') ! zeolite

		!input_string = TRIM(input_string) //      "    Clinoptilolite-Ca " // trim(s_precip) // trim(s_clinoptilolite) // kinetics //NEW_LINE('') ! zeolite

			 input_string = TRIM(input_string) //"    K-Feldspar " // trim(s_precip) // trim(s_kspar) // kinetics //NEW_LINE('') ! zeolite

			 !input_string = TRIM(input_string) //"    Mesolite " // trim(s_precip) // trim(s_mesolite) // kinetics //NEW_LINE('') ! zeolite




		input_string = TRIM(input_string) //      "    Scolecite " // trim(s_precip) // trim(s_scolecite) // kinetics //NEW_LINE('') ! zeolite
			 input_string = TRIM(input_string) //"    Gismondine " // trim(s_precip) // trim(s_gismondine) // kinetics //NEW_LINE('') ! zeolite

		! &"    Kaolinite 0.0 " // trim(s_kaolinite) // kinetics //NEW_LINE('')// & ! clay
		! &"    Goethite 0.0 " // trim(s_goethite) // kinetics //NEW_LINE('')// &
		! &"    Celadonite 0.0 " // trim(s_celadonite) // kinetics //NEW_LINE('')// & ! mica
		!  !&"    Albite 0.0 " // trim(s_albite) // kinetics //NEW_LINE('')// & ! plagioclase
		! &"    Calcite 0.0 " // trim(s_calcite) // kinetics //NEW_LINE('')// & ! .135
		! &"    Montmor-Na 0.0 " // trim(s_mont_na) // kinetics //NEW_LINE('')// & ! smectite
		! !&"    Montmor-K 0.0 " // trim(s_mont_k) // kinetics //NEW_LINE('')// & ! smectite
		! !&"    Montmor-Mg 0.0 " // trim(s_mont_mg) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Montmor-Ca 0.0 " // trim(s_mont_ca) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Saponite-Mg 0.0 " // trim(s_saponite) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Stilbite 0.0 " // trim(s_stilbite) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Clinoptilolite-Ca 0.0 " // trim(s_clinoptilolite) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Pyrite 0.0 " // trim(s_pyrite) // kinetics //NEW_LINE('')// &
		! ! &"    Quartz 0.0 " // trim(s_quartz) // kinetics //NEW_LINE('')// &
		! &"    K-Feldspar 0.0 " // trim(s_kspar) // kinetics //NEW_LINE('')// &
		! &"    Saponite-Na 0.0 " // trim(s_saponite_na) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Nontronite-Na 0.0 " // trim(s_nont_na) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Nontronite-Mg 0.0 " // trim(s_nont_mg) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Nontronite-K 0.0 " // trim(s_nont_k) // kinetics //NEW_LINE('')// & ! smectite
		!   &"    Fe-Celadonite 0.0 " // trim(s_fe_celadonite) // kinetics //NEW_LINE('')// & ! mica
		! &"    Nontronite-Ca 0.0 " // trim(s_nont_ca) // kinetics //NEW_LINE('')// & ! smectite
		!  !&"    Muscovite 0.0 " // trim(s_muscovite) // kinetics //NEW_LINE('')// & ! mica
		! !&"    Mesolite 0.0 " // trim(s_mesolite) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Anhydrite 0.0 " // trim(s_anhydrite) // kinetics //NEW_LINE('')// & ! formerly magnesite
		! &"    Smectite-high-Fe-Mg 0.0 " // trim(s_smectite) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Saponite-K 0.0 " // trim(s_saponite_k) // kinetics //NEW_LINE('')// & ! smectite
		!    &"    Vermiculite-Na 0.0 " // trim(s_verm_na) // kinetics //NEW_LINE('')// &
		! !&"    Hematite 0.0 " // trim(s_hematite) // kinetics //NEW_LINE('')// &
		! ! &"    Hematite " // trim(si_hematite) // trim(s_hematite) // kinetics //NEW_LINE('')// &
		!    &"    Vermiculite-Ca 0.0 " // trim(s_verm_ca) // kinetics //NEW_LINE('')// &
		! &"    Analcime 0.0 " // trim(s_analcime) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Phillipsite 0.0 " // trim(s_phillipsite) // kinetics //NEW_LINE('')// & ! zeolite
		! !&"    Diopside 0.0 " // trim(s_diopside) // kinetics //NEW_LINE('')// & ! pyroxene
		!     !&"    Epidote  0.0 " // trim(s_epidote) // kinetics //NEW_LINE('')// &
		!    &"    Gismondine 0.0 " // trim(s_gismondine) // kinetics //NEW_LINE('')// & ! zeolite
		! !&"    Hedenbergite 0.0 " // trim(s_hedenbergite) // kinetics //NEW_LINE('')// & ! pyroxene
		!    &"    Chalcedony 0.0 " // trim(s_chalcedony) // kinetics //NEW_LINE('')// & ! quartz
		!    &"    Vermiculite-Mg 0.0 " // trim(s_verm_mg) // kinetics //NEW_LINE('')// &
		! &"    Ferrihydrite 0.0 " // trim(s_ferrihydrite) // kinetics //NEW_LINE('')// & ! iron oxyhydroxide
		! &"    Natrolite 0.0 " // trim(s_natrolite) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Talc 0.0 " // trim(s_talc) // kinetics //NEW_LINE('')// &
		! &"    Smectite-low-Fe-Mg 0.0 " // trim(s_smectite_low) // kinetics //NEW_LINE('')// & ! smectite
		!   &"    Prehnite 0.0 " // trim(s_prehnite) // kinetics //NEW_LINE('')// &
		! &"    Chlorite(14A) 0.0 " // trim(s_chlorite) // kinetics //NEW_LINE('')// & ! chlorite
		! &"    Scolecite 0.0 " // trim(s_scolecite) // kinetics //NEW_LINE('')// & ! zeolite
		! &"    Chamosite-7A 0.0 " // trim(s_chamosite7a) // kinetics //NEW_LINE('')// & ! chlorite
		! &"    Clinochlore-14A 0.0 " // trim(s_clinochlore14a) // kinetics //NEW_LINE('')// & ! chlorite
		! &"    Clinochlore-7A 0.0 " // trim(s_clinochlore7a) // kinetics //NEW_LINE('')// & ! chlorite
		! &"   Saponite-Ca 0.0 " // trim(s_saponite_ca) // kinetics //NEW_LINE('')// & ! smectite
		! &"   Pyrrhotite 0.0 " // trim(s_pyrrhotite) // kinetics //NEW_LINE('')// & ! sulfide
		!   !&"   Magnetite 0.0 " // trim(s_magnetite) // kinetics //NEW_LINE('')// &
		! &"   Daphnite-7a 0.0 " // trim(s_daphnite_7a) // kinetics //NEW_LINE('')// & ! chlorite
		! &"   Daphnite-14a 0.0 " // trim(s_daphnite_14a) // kinetics //NEW_LINE('')// & ! chlorite
		!   !&"   Vermiculite-K 0.0 " // trim(s_verm_k) // kinetics //NEW_LINE('')// &
		!   &"   Aragonite 0.0 " // trim(s_aragonite) // kinetics //NEW_LINE('')// &
		! ! &" -force_equality"  //NEW_LINE('')// &
		! &"   Lepidocrocite 0.0 " // trim(s_lepidocrocite) // kinetics //NEW_LINE('')// & ! iron oxyhydroxide


		!# RATES
		input_string = TRIM(input_string) //  "RATES" //NEW_LINE('')// &

		! stopped using 1/26/17, night
		! &"BGlass" //NEW_LINE('')// &
! 		&"-start" //NEW_LINE('')// &
! 		&"    10 rate0=M*110.0*(1.52e-5)*0.005*(1.0e4)*(2.51189e-6)*exp(-25.5/(.008314*TK))" // &
! 		!&"*(((ACT('H+')^3)/(ACT('Al+3')))^.33333)" //NEW_LINE('')// &
! 		&"*(((ACT('H+')^3)/(TOT('Al')))^.33333)" //NEW_LINE('')// &
! 		!&"*(((ACT('H+')^3)/(1.0e-14))^.33333)" //NEW_LINE('')// &
! 		&"    20 save rate0 * time" //NEW_LINE('')// &
! 		&"-end" //NEW_LINE('')// &


		! linear decrease with alteration
		! &"BGlass" //NEW_LINE('')// &
		! &"-start" //NEW_LINE('')// &
		! &"    10 rate0=M*110.0*(1.52e-5)*" // trim(param_exp_string_in) // "*(CALC_VALUE('R(sum)'))*(1.0e4)*(2.51189e-6)*exp(-25.5/(.008314*TK))" // &
		! &"*(((ACT('H+')^3)/(TOT('Al')))^.33333)" //NEW_LINE('')// &
		! &"    20 save rate0 * time" //NEW_LINE('')// &
		! &"-end" //NEW_LINE('')// &

		&"BGlass" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		&"	 10 base0 = 1e-14" //NEW_LINE('')// &
		&"	 20 if (ACT('Al+3') > 1e-14) then base0 = ACT('Al+3')" //NEW_LINE('')// &
		! &"    30 rate0=M*110.0*((4.56e5)/(3.0e6))*" // TRIM(param_exp_string_in) // "*(2.51189e-6)*exp(-25.5/(.008314*TK))*(((ACT('H+')^3)/(ACT('Al+3')))^.33333)" //NEW_LINE('')// &

		&"    30 rate0=M*110.0*((4.56e5)/(3.0e6))*" // TRIM(param_exp_string_in) // "*(2.51189e-6)*exp(-25.5/(.008314*TK))*(((ACT('H+')^3)/base0)^.33333)" //NEW_LINE('')// &



		! &"    30 rate0=" // TRIM(param_exp1_string_in) // " " //NEW_LINE('')// &







		! &"    30 rate0=M*110.0*((4.56e5)/(3.0e6))*" // TRIM(param_exp_string_in) // "*(2.51189e-6)*exp(-25.5/(.008314*TK))*(((ACT('H+')^3)/(1.0e-8))^.33333)" //NEW_LINE('')// &
		&"    40 save rate0 * time" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &

		&"Basalt1" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		&"    10 rate0=M*1.0"   //NEW_LINE('')// &
		&"    20 save rate0 * time" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &

		&"Basalt2" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		&"    10 rate0=M*1.0"   //NEW_LINE('')// &
		&"    20 save rate0 * time" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &

		&"Basalt3" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		&"    10 rate0=M*1.0"   //NEW_LINE('')// &
		&"    20 save rate0 * time" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &


		&"KINETICS 1" //NEW_LINE('')// &
		&"BGlass" //NEW_LINE('')// &
		! ! seyfried JDF
		&"-f CaO .2151 SiO2 .85 Al2O3 .14 " //&
		! & "Fe2O3 .149 FeO .0075 MgO .1744 K2O .002 " //&
		& "Fe2O3 .026 FeO .166 MgO .178 K2O .002 " //&
		& "Na2O .043" //NEW_LINE('')// &
		&"-m0 " // trim(s_glass) //NEW_LINE('')// &

		&"Basalt1 " //NEW_LINE('')// &
		& '-f MgO 0.85 FeO 0.15 SiO2 1.0' //NEW_LINE('')// &
! 		&"-f MgO 2.0 SiO2 1.0 " //NEW_LINE('')// & ! forsterite
! 		&"-f FeO 2.0 SiO2 1.0 " //NEW_LINE('')// & ! fayalite
		&"-m0 " // trim(s_basalt1) //NEW_LINE('')// &

		&"Basalt2 " //NEW_LINE('')// &
		& '-f MgO 2.0 SiO2 2.0' //NEW_LINE('')// &
! 		&"-f CaO 1.0 FeO 1.0 SiO2 2.0 " //NEW_LINE('')// & ! hedenbergite
! 		&"-f CaO 1.0 MgO 1.0 SiO2 2.0 " //NEW_LINE('')// & ! diopside
! 		&"-f FeO 1.0 MgO 1.0 SiO2 2.0 " //NEW_LINE('')// & ! fer mag
! 		&"-f MgO 2.0 SiO2 2.0 " //NEW_LINE('')// & ! enstatite
! 		&"-f FeO 2.0 SiO2 2.0 " //NEW_LINE('')// & ! ferrosilite
! 		&"-f CaO 2.0 SiO2 2.0 " //NEW_LINE('')// & ! wollastonite
		&"-m0 " // trim(s_basalt2) //NEW_LINE('')// &

		&"Basalt3 " //NEW_LINE('')// &
! 		&"-f CaO 1.0 FeO 1.0 Al2O3 1.0 SiO2 2.0 " //NEW_LINE('')// & ! old lab
! 		&"-f NaAlSi3O8 0.5 CaAl2Si2O8 0.5 " //NEW_LINE('')// & ! mid plag
		& '-f NaAlSi3O8 1.0' //NEW_LINE('')// &
		&"-m0 " // trim(s_basalt3) //NEW_LINE('')// &
		&"    -step " // trim(s_timestep) // " in 1" //NEW_LINE('')// &

		&"INCREMENTAL_REACTIONS true" //NEW_LINE('')// &


		&"CALCULATE_VALUES" //NEW_LINE('')// &

		&"R(sum)" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
! 		&"10 sum = (" //&
! 		&"(EQUI('stilbite')*480.19/2.15) + (EQUI('aragonite')*100.19/2.93)" // &
! 		&"+ (EQUI('kaolinite')*258.16/2.63) + (EQUI('albite')*263.02/2.62)" // &
! 		&"+ (EQUI('Saponite-Mg')*480.19/2.3) + (EQUI('celadonite')*429.02/3.0)" // &
! 		&"+ (EQUI('Clinoptilolite-Ca')*2742.13/2.15) + (EQUI('pyrite')*119.98/5.02)" // &
! 		&"+ (EQUI('montmor-na')*549.07/2.01) + (EQUI('goethite')*88.85/4.27)" // &
! 		&"+ (EQUI('dolomite')*180.4/2.84) + (EQUI('Smectite-high-Fe-Mg')*540.46/2.01)" // &
! 		&"+ (EQUI('saponite-k')*480.19/2.3) + (EQUI('anhydrite')*136.14/2.97)" // &
! 		&"+ (EQUI('siderite')*115.86/3.96) + (EQUI('calcite')*100.19/2.71)" // &
! 		&"+ (EQUI('quartz')*60.08/2.65) + (EQUI('k-feldspar')*278.33/2.56)" // &
! 		&"+ (EQUI('saponite-na')*480.19/2.3) + (EQUI('nontronite-na')*495.9/2.3)" // &
! 		&"+ (EQUI('nontronite-mg')*495.9/2.3) + (EQUI('nontronite-k')*495.9/2.3)" // &
! 		&"+ (EQUI('fe-celadonite')*495.9/2.3) + (EQUI('nontronite-ca')*495.9/2.3)" // &
! 		&"+ (EQUI('muscovite')*398.71/2.81) + (EQUI('mesolite')*1164.9/2.29)" // &
! 		&"+ (EQUI('hematite')*159.69/5.3) + (EQUI('montmor-ca')*549.07/2.01)" // &
! 		&"+ (EQUI('vermiculite-ca')*504.19/2.5) + (EQUI('analcime')*220.15/2.27)" // &
! 		&"+ (EQUI('phillipsite')*704.93/2.2) + (EQUI('diopside')*216.55/3.3)" // &
! 		&"+ (EQUI('epidote')*519.3/3.41) + (EQUI('gismondine')*718.55/2.26)" // &
! 		&"+ (EQUI('hedenbergite')*248.08/3.56) + (EQUI('chalcedony')*60.08/2.65)" // &
! 		&"+ (EQUI('vermiculite-mg')*504.19/2.5) + (EQUI('ferrihydrite')*169.7/3.8)" // &
! 		&"+ (EQUI('natrolite')*380.22/2.23) + (EQUI('talc')*379.27/2.75)" // &
! 		&"+ (EQUI('smectite-low-fe-mg')*540.46/2.01) + (EQUI('prehnite')*395.38/2.87)" // &
! 		&"+ (EQUI('chlorite')*67.4/2.468) + (EQUI('scolecite')*392.34/2.27)" // &
! 		&"+ (EQUI('chamosite-7a')*664.18/3.0) + (EQUI('clinochlore-14a')*595.22/3.0)" // &
! 		&"+ (EQUI('clinochlore-7a')*595.22/3.0) + (EQUI('saponite-ca')*480.19/2.3)" // &
! 		&"+ (EQUI('vermiculite-na')*504.19/2.5) + (EQUI('pyrrhotite')*85.12/4.62)" // &
! 		&"+ (EQUI('magnetite')*231.53/5.15) + (EQUI('lepidocrocite')*88.85/4.08)" // &
! 		&"+ (EQUI('daphnite-7a')*664.18/3.2) + (EQUI('daphnite-14a')*664.18/3.2)" // &
! 		&"+ (EQUI('vermiculite-k')*504.19/2.5) + (EQUI('montmor-k')*549.07/2.01)" // &
! 		&"+ (EQUI('montmor-mg')*549.07/2.01) )" //NEW_LINE('')// &
! 		&"20 sum = 1.0 - (sum/((KIN('BGlass')*110.0/2.7) + sum))" //&
		&"10 sum = 1.0" //&
		&"" //NEW_LINE('')// &
		&"100 SAVE sum" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &


		!
		&"R(phi)" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		!&"10 phi = 1.0-(CALC_VALUE('R(sum)')/(CALC_VALUE('R(sum)')+(TOT('water')*1000.0)))" //&
		! &"10 phi = ((  (ACT('H+')^3) / (ACT('Al+3')) )^.33333)" //&
		! &"10 phi = ACT('Al+3')" //&
		&"10 phi = 1.0" //&
		&"" //NEW_LINE('')// &
		&"100 SAVE phi" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &

		!
		&"R(s_sp)" //NEW_LINE('')// &
		&"-start" //NEW_LINE('')// &
		!&"10 s_sp = (CALC_VALUE('R(phi)')/(1.0-CALC_VALUE('R(phi)')))*400.0/CALC_VALUE('R(rho_s)')" //&
		&"10 s_sp = 1.53e-5" //&
		&"" //NEW_LINE('')// &
		&"100 SAVE s_sp" //NEW_LINE('')// &
		&"-end" //NEW_LINE('')// &


		! &"SELECTED_OUTPUT" //NEW_LINE('')// &
		! &"    -reset false" //NEW_LINE('')// &
		! &"    -high_precision true" //NEW_LINE('')// &
		! &"    -k basalt3 basalt2 basalt1 bglass" //NEW_LINE('')// &
		! &"    -ph" //NEW_LINE('')// &
		! &"    -pe false" //NEW_LINE('')// &
		! &"    -totals C" //NEW_LINE('')// &
		! &"    -totals Ca Mg Na K Fe S Si Cl Al " //NEW_LINE('')// &
		! &"    -molalities HCO3-" //NEW_LINE('')// &
		! &"    -water true" //NEW_LINE('')// &
		! &"    -alkalinity" //NEW_LINE('')// &
		! &"    -p stilbite aragonite kaolinite albite saponite-mg celadonite Clinoptilolite-Ca" //NEW_LINE('')// &
		! &"    -p pyrite montmor-na goethite dolomite Smectite-high-Fe-Mg saponite-k anhydrite" //NEW_LINE('')// &
		! &"    -p siderite calcite quartz k-feldspar saponite-na nontronite-na nontronite-mg" //NEW_LINE('')// &
		! &"    -p nontronite-k fe_celadonite nontronite-ca muscovite mesolite hematite montmor-ca" //NEW_LINE('')// &
		! &"    -p vermiculate-ca analcime phillipsite diopside epidote gismondine hedenbergite" //NEW_LINE('')// &
		! &"    -p chalcedony vermiculite-mg ferrihydrite natrolite talc Smectite-low-Fe-Mg prehnite" //NEW_LINE('')// &
		! &"    -p chlorite scolecite chamosite-7a Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// &
		! &"    -p vermiculite-na pyrrhotite magnetite Lepidocrocite Daphnite-7A Daphnite-14A" //NEW_LINE('')// &
		! ! &"    -p vermiculite-k montmor-k montmor-mg" //NEW_LINE('')// &
		! !&"    -p vermiculite-k montmor-k" //NEW_LINE('')// &
		!
		! &"    -s stilbite aragonite kaolinite albite saponite-mg celadonite Clinoptilolite-Ca" //NEW_LINE('')// &
		! &"    -s pyrite montmor-na goethite dolomite Smectite-high-Fe-Mg saponite-k anhydrite" //NEW_LINE('')// &
		! &"    -s siderite calcite quartz k-feldspar saponite-na nontronite-na nontronite-mg" //NEW_LINE('')// &
		! &"    -s nontronite-k fe-celadonite nontronite-ca muscovite mesolite hematite montmor-ca" //NEW_LINE('')// &
		! &"    -s vermiculate-ca analcime phillipsite diopside epidote gismondine hedenbergite" //NEW_LINE('')// &
		! &"    -s chalcedony vermiculite-mg ferrihydrite natrolite talc Smectite-low-Fe-Mg prehnite" //NEW_LINE('')// &
		! &"    -s chlorite scolecite chamosite-7a Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// &
		! &"    -s vermiculite-na pyrrhotite magnetite Lepidocrocite Daphnite-7A Daphnite-14A" //NEW_LINE('')// &
		! ! &"    -s vermiculite-k montmor-k montmor-mg" //NEW_LINE('')// &
		! !&"    -s vermiculite-k montmor-mg" //NEW_LINE('')// &
		! &"    -calculate_values R(sum) R(s_sp)" //NEW_LINE('')// &
		! &"    -time" //NEW_LINE('')// &
		&"SELECTED_OUTPUT" //NEW_LINE('')// &
		&"    -reset false" //NEW_LINE('')// &
		&"    -high_precision true" //NEW_LINE('')// &
		&"    -k basalt3 basalt2 basalt1 bglass" //NEW_LINE('')// &
		&"    -ph" //NEW_LINE('')// &
		&"    -pe false" //NEW_LINE('')// &
		&"    -totals C" //NEW_LINE('')// &
		&"    -totals Ca Mg Na K Fe S Si Cl Al " //NEW_LINE('')// &
		&"    -molalities HCO3-" //NEW_LINE('')// &
		&"    -water true" //NEW_LINE('')// &
		&"    -alkalinity" //NEW_LINE('')// &
		&"    -p Kaolinite Saponite-Mg Celadonite Clinoptilolite-Ca Pyrite Montmor-Na Goethite" //NEW_LINE('')// & ! 7
		&"    -p Smectite-high-Fe-Mg Calcite K-Feldspar Saponite-Na Nontronite-Na Nontronite-Mg" //NEW_LINE('')// & ! 6
		&"    -p Fe-Celadonite Nontronite-Ca Mesolite Hematite Montmor-Ca Vermiculite-Ca Analcime" //NEW_LINE('')// & ! 7
		&"    -p Phillipsite Montmor-Mg Gismondine Vermiculite-Mg Natrolite Talc Smectite-low-Fe-Mg " //NEW_LINE('')// & ! 7
		&"    -p Prehnite Chlorite(14a) scolecite Clinochlore-14A Clinochlore-7A Saponite-Ca" //NEW_LINE('')// & ! 6
		&"    -p Vermiculite-Na Pyrrhotite Fe-Saponite-Ca Fe-Saponite-Mg" //NEW_LINE('')// & ! 4

		&"    -p Daphnite-7a Daphnite-14a Epidote Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// & ! 6
		&"    -p prehnite chlorite(14a) scolecite Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// & ! 6
		&"    -p prehnite chlorite(14a) scolecite Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// & ! 6
		&"    -s kaolinite" //NEW_LINE('')// &		! 1
		! 		&"    -s kaolinite saponite-mg celadonite Clinoptilolite-Ca pyrite montmor-na goethite" //NEW_LINE('')// &
		! 		&"    -s Smectite-high-Fe-Mg calcite k-feldspar saponite-na nontronite-na nontronite-mg" //NEW_LINE('')// &
		! 		&"    -s fe-celadonite nontronite-ca mesolite hematite montmor-ca vermiculite-ca analcime" //NEW_LINE('')// &
		! 		&"    -s phillipsite diopside gismondine vermiculite-mg natrolite talc Smectite-low-Fe-Mg " //NEW_LINE('')// &
		! 		&"    -s prehnite chlorite(14a) scolecite Clinochlore-14A Clinochlore-7A saponite-ca" //NEW_LINE('')// &
		! 		&"    -s vermiculite-na pyrrhotite Fe-Saponite-Ca Fe-Saponite-Mg" //NEW_LINE('')// &
		&"    -calculate_values R(sum) R(s_sp)" //NEW_LINE('')// &
		&"    -time" //NEW_LINE('')// &
		&"END"



	   ! INITIALIZE STUFF
	   id = CreateIPhreeqc()



	   IF (id.LT.0) THEN
	   	write(*,*) "weird stop?"
	   	STOP
	   END IF

	   IF (SetSelectedOutputStringOn(id, .TRUE.).NE.IPQ_OK) THEN
	   	CALL OutputErrorString(id)
		write(*,*) "BUG 1" , " box:" , i
	   	write(*,*) "primary"
	   	write(*,*) primary_in(:,i)
	   	write(*,*) "secondary"
	   	write(*,*) secondary_in(:,i)
	   	write(*,*) "solute"
	   	write(*,*) solute_in(:,i)
	   	write(*,*) "medium"
	   	write(*,*) medium_in(:,i)
	   	write(*,*) "temp"
	   	write(*,*) temp_in(i)
	   	STOP
	   END IF

	   IF (LoadDatabaseString(id, L5).NE.0) THEN
	   	CALL OutputErrorString(id)
		write(*,*) "BUG 2" , " box:" , i
	   	write(*,*) "primary"
	   	write(*,*) primary_in(:,i)
	   	write(*,*) "secondary"
	   	write(*,*) secondary_in(:,i)
	   	write(*,*) "solute"
	   	write(*,*) solute_in(:,i)
	   	write(*,*) "medium"
	   	write(*,*) medium_in(:,i)
	   	write(*,*) "temp"
	   	write(*,*) temp_in(i)
	   	STOP
	   END IF

	   ! RUN INPUT
	   IF (RunString(id, input_string).NE.0) THEN
	   	write(*,*) "issue is:" , RunString(id, input_string)
	   	CALL OutputErrorString(id)
		write(*,*) "BUG 3" , " box:" , i
	   	write(*,*) "primary"
	   	write(*,*) primary_in(:,i)
	   	write(*,*) "secondary"
	   	write(*,*) secondary_in(:,i)
	   	write(*,*) "solute"
	   	write(*,*) solute_in(:,i)
	   	write(*,*) "medium"
	   	write(*,*) medium_in(:,i)
	   	write(*,*) "temp"
	   	write(*,*) temp_in(i)
	   	IF (RunString(id, input_string).NE.0) THEN
	   		write(*,*) "another chance 2"
	   		CALL OutputErrorString(id)
	   	END IF
	   	STOP
	   END IF


	   ! WRITE AWAY
	   DO ii=1,GetSelectedOutputStringLineCount(id)
 	   	call GetSelectedOutputStringLine(id, ii, line)
! 	   	! HEADER BITS YOU MAY WANT
! 	   	if ((ii .eq. 1)) then
! 	   	   !write(12,*) trim(line)
! 	   	   !if ((medium3(6) .gt. 24000.0) .and. (medium3(7) .gt. -100.0)) then
! 	   	   write(*,*) trim(line) ! PRINT LABELS FOR EVERY FIELD (USEFUL)
! 	   	   !end if
! 	   	end if


	   	! MEAT
	   	if (ii .gt. 1) then
	   		read(line,*) out_mat(ii,:)
	   		!!!!write(12,*) outmat(i,:) ! this writes to file, which i don't need (USEFUL)
	   ! 		if ((medium3(6) .gt. 23000.0) .and. (medium3(7) .gt. -200.0)) then
	   ! 		write(*,*) i
	   ! 		write(*,*) trim(line) ! PRINT EVERY GOD DAMN LINE
	   ! 		write(*,*) ""
	   ! ! 		! write(*,*) solute3
	   ! ! ! 		write(*,*) ""
	   ! ! 		write(*,*) ""
	   ! 		end if
	   	end if
	   END DO


	   p_out(i,:) = out_mat(3,:)
	   !p_out(i,130:186) = out_mat(2,130:186)
	   !p_out(i,124:177) = out_mat(2,124:177)
	!    write(*,*) "box" , i
	!    write(*,*) out_mat(3,:)
	!    write(*,*)



	   if (GetSelectedOutputStringLineCount(id) .ne. 3) then
	   	p_out(i,:) = 0.0
	   	write(*,*) "not = 3"
	   end if

 	   !write(*,*) p_out(i,189)

	   ! DESTROY INSTANCE
	   IF (DestroyIPhreeqc(id).NE.IPQ_OK) THEN
	   	CALL OutputErrorString(id)
	   	write(*,*) "cannot be destroyed?"
	   	STOP
	   END IF

	   run_box(i,:) = p_out(i,:)

   end do





! if (p_out(1,2) .lt. 1.0) then
! 	medLocal(m,5) = 0.0
! 	solLocal(m,:) = (/ solute3(1), solute3(2), solute3(3), solute3(4), solute3(5), &
! 	solute3(6), solute3(7), solute3(8), solute3(9), solute3(10), solute3(11), &
! 	solute3(12), solute3(13), solute3(14), 0.0/)
! end if


	return
end function run_box








! ----------------------------------------------------------------------------------%%
!
! GET_UNIT
!
! ----------------------------------------------------------------------------------%%

function get_unit ( )

  implicit none
  integer :: i, ios, get_unit
  logical lopen
  get_unit = 0
  do i = 1, 99
    if ( i /= 5 .and. i /= 6 .and. i /= 9 ) then
      inquire ( unit = i, opened = lopen, iostat = ios )
      if ( ios == 0 ) then
        if ( .not. lopen ) then
          get_unit = i
          return
        end if
      end if
    end if
  end do
  return
end function get_unit




! ----------------------------------------------------------------------------------%%
!
! LINSPACE
!
! ----------------------------------------------------------------------------------%%

function linspace ( n, a_first, a_last )

  implicit none
  integer, intent(in) :: n
   real (4) :: linspace(n)
   integer :: i
   real (4) :: a(n)
   real (4) , intent(in) ::  a_first, a_last

  if ( n == 1 ) then
    a(1) = ( a_first + a_last ) / 2.0
  else
    do i = 1, n
      a(i) = ( real ( n - i,     kind = 8 ) * a_first &
             + real (     i - 1, kind = 8 ) * a_last ) &
             / real ( n     - 1, kind = 8 )
    end do
  end if
  linspace = a
  return

end function linspace


FUNCTION replace_Text (s,text,rep)  RESULT(outs)
CHARACTER(*)        :: s,text,rep
CHARACTER(LEN(s)+100) :: outs     ! provide outs with extra 100 char len
INTEGER             :: i, nt, nr

outs = s ; nt = LEN_TRIM(text) ; nr = LEN(rep)
DO
   i = INDEX(outs,text(:nt)) ; IF (i == 0) EXIT
   outs = outs(:i-1) // rep(:nr) // outs(i+nt:)
END DO
END FUNCTION replace_Text

end module basalt_box_mod
