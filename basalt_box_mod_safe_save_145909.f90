module basalt_box_mod
	implicit none
	
	include 'mpif.h'
	INCLUDE "IPhreeqc.f90.inc"
save


contains


! ----------------------------------------------------------------------------------%%
!
! RUN_BOX
!
! ----------------------------------------------------------------------------------%%

function run_box(primary_in, secondary_in, solute_in, medium_in, g_pri, g_sec, g_sol, g_med, n_box, temp_in, area_in, mix_in, timestep_in)
	integer :: g_pri, g_sec, g_sol, g_med, n_box
	integer :: i, ii, j, jj
	real(4) :: primary_in(g_pri,n_box), secondary_in(g_sec,n_box), solute_in(g_sol,n_box), medium_in(g_med,n_box)
	real(4) :: temp_in(n_box), area_in(n_box), mix_in(n_box), timestep_in
	
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
	character(len=25) :: s_nont_h, s_nont_ca, s_muscovite, s_mesolite, s_hematite, s_diaspore
	character(len=25) :: s_feldspar, s_pigeonite, s_augite, s_glass, s_magnetite ! primary
	character(len=25) :: s_laumontite, s_mont_k, s_mont_mg, s_mont_ca
	character(len=25) :: s_temp, s_timestep, s_area ! important information
	character(len=25) :: s_ph, s_ca, s_mg, s_na, s_k, s_fe, s_s, s_si, s_cl, s_al, s_alk, s_co2 ! solutes
	character(len=25) :: s_hco3, s_co3
	character(len=25) :: s_water, s_w ! medium
	character(len=25) :: kinetics
	character(len=45000) :: input_string
	
	character(len=59000) :: L5
	
	!L5 = ! goes here eventually
	
	kinetics = " precipitate_only"
	!kinetics = " "
	
	do i=1,n_box
		
		
		! solute_inS TO STRINGS
		write(s_ph,'(F25.10)') solute_in(1,i)
		write(s_alk,'(F25.10)') solute_in(2,i)
		write(s_water,'(F25.10)') solute_in(3,i)
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
		write(s_w,'(F25.10)') medium3(3)!solute_in3(3)
	
		! PRIMARIES TO STRINGS
		write(s_feldspar,'(F25.10)') primary_in(1,i)
		write(s_augite,'(F25.10)') primary_in(2,i)
		write(s_pigeonite,'(F25.10)') primary_in(3,i)
		write(s_magnetite,'(F25.10)') primary_in(4,i)
		write(s_glass,'(F25.10)') primary_in(5,i)
	
		! SECONDARIES TO STRINGS
		write(s_stilbite,'(F25.10)') secondary_in(1,i)
		write(s_aragonite,'(F25.10)') secondary_in(2,i)
		write(s_kaolinite,'(F25.10)') secondary_in(3,i)
		write(s_albite,'(F25.10)') secondary_in(4,i)
		write(s_saponite,'(F25.10)') secondary_in(5,i)
		write(s_celadonite,'(F25.10)') secondary_in(6,i)
		write(s_clinoptilolite,'(F25.10)') secondary_in(7,i)
		write(s_pyrite,'(F25.10)') secondary_in(8,i)
		write(s_mont_na,'(F25.10)') secondary_in(9,i)
		write(s_goethite,'(F25.10)') secondary_in(10,i)
		write(s_dolomite,'(F25.10)') secondary_in(11,i)
		write(s_smectite,'(F25.10)') secondary_in(12,i)
		write(s_saponite_k,'(F25.10)') secondary_in(13,i)
		write(s_anhydrite,'(F25.10)') secondary_in(14,i)
		write(s_siderite,'(F25.10)') secondary_in(15,i)
		write(s_calcite,'(F25.10)') secondary_in(16,i)
		write(s_quartz,'(F25.10)') secondary_in(17,i)
		write(s_kspar,'(F25.10)') secondary_in(18,i)
		write(s_saponite_na,'(F25.10)') secondary_in(19,i)
		write(s_nont_na,'(F25.10)') secondary_in(20,i)
		write(s_nont_mg,'(F25.10)') secondary_in(21,i)
		write(s_nont_k,'(F25.10)') secondary_in(22,i)
		write(s_nont_h,'(F25.10)') secondary_in(23,i)
		write(s_nont_ca,'(F25.10)') secondary_in(24,i)
		write(s_muscovite,'(F25.10)') secondary_in(25,i)
		write(s_mesolite,'(F25.10)') secondary_in(26,i)
		write(s_hematite,'(F25.10)') secondary_in(27,i)
		write(s_mont_ca,'(F25.10)') secondary_in(28,i)
		write(s_verm_ca,'(F25.10)') secondary_in(29,i)
		write(s_analcime,'(F25.10)') secondary_in(30,i)
		write(s_phillipsite,'(F25.10)') secondary_in(31,i)
		write(s_diopside,'(F25.10)') secondary_in(32,i)
		write(s_epidote,'(F25.10)') secondary_in(33,i)
		write(s_gismondine,'(F25.10)') secondary_in(34,i)
		write(s_hedenbergite,'(F25.10)') secondary_in(35,i)
		write(s_chalcedony,'(F25.10)') secondary_in(36,i)
		write(s_verm_mg,'(F25.10)') secondary_in(37,i)
		write(s_ferrihydrite,'(F25.10)') secondary_in(38,i)
		write(s_natrolite,'(F25.10)') secondary_in(39,i)
		write(s_talc,'(F25.10)') secondary_in(40,i)
		write(s_smectite_low,'(F25.10)') secondary_in(41,i)
		write(s_prehnite,'(F25.10)') secondary_in(42,i)
		write(s_chlorite,'(F25.10)') secondary_in(43,i)
		write(s_scolecite,'(F25.10)') secondary_in(44,i)
		write(s_chamosite7a,'(F25.10)') secondary_in(45,i)
		write(s_clinochlore14a,'(F25.10)') secondary_in(46,i)
		write(s_clinochlore7a,'(F25.10)') secondary_in(47,i)
		write(s_saponite_ca,'(F25.10)') secondary_in(48,i)
		write(s_verm_na,'(F25.10)') secondary_in(49,i)
		write(s_pyrrhotite,'(F25.10)') secondary_in(50,i)
		write(s_magnetite,'(F25.10)') secondary_in(51,i)
		write(s_lepidocrocite,'(F25.10)') secondary_in(52,i)
		write(s_daphnite_7a,'(F25.10)') secondary_in(53,i)
		write(s_daphnite_14a,'(F25.10)') secondary_in(54,i)
		write(s_verm_k,'(F25.10)') secondary_in(55,i)
		write(s_mont_k,'(F25.10)') secondary_in(56,i)
		write(s_mont_mg,'(F25.10)') secondary_in(57,i)

		! OTHER INFORMATION TO STRINGS
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
		&"    -water "// trim(s_w) // " # kg" //NEW_LINE('')// &
		
	
		&"EQUILIBRIUM_PHASES 1" //NEW_LINE('')// &
		&"    Kaolinite 0.0 " // trim(s_kaolinite) // kinetics //NEW_LINE('')// & ! clay
		&"    Goethite 0.0 " // trim(s_goethite) // kinetics //NEW_LINE('')// &
		&"    Celadonite 0.0 " // trim(s_celadonite) // kinetics //NEW_LINE('')// & ! mica
		! &"    Albite 0.0 " // trim(s_albite) // kinetics //NEW_LINE('')// & ! plagioclase
		&"    Calcite 1.0 " // trim(s_calcite) // kinetics //NEW_LINE('')// & ! .135
		&"    Montmor-Na 0.0 " // trim(s_mont_na) // kinetics //NEW_LINE('')// & ! smectite
		&"    Montmor-K 0.0 " // trim(s_mont_k) // kinetics //NEW_LINE('')// & ! smectite
		&"    Montmor-Mg 0.0 " // trim(s_mont_mg) // kinetics //NEW_LINE('')// & ! smectite
		&"    Montmor-Ca 0.0 " // trim(s_mont_ca) // kinetics //NEW_LINE('')// & ! smectite
		&"    Saponite-Mg 0.0 " // trim(s_saponite) // kinetics //NEW_LINE('')// & ! smectite
		&"    Stilbite 0.0 " // trim(s_stilbite) // kinetics //NEW_LINE('')// & ! zeolite
		&"    Clinoptilolite-Ca 0.0 " // trim(s_clinoptilolite) // kinetics //NEW_LINE('')// & ! zeolite
		&"    Pyrite 0.0 " // trim(s_pyrite) // kinetics //NEW_LINE('')// &
		! &"    Quartz 0.0 " // trim(s_quartz) // kinetics //NEW_LINE('')// &
		&"    K-Feldspar 0.0 " // trim(s_kspar) // kinetics //NEW_LINE('')// &
		 &"    Saponite-Na 0.0 " // trim(s_saponite_na) // kinetics //NEW_LINE('')// & ! smectite
		 &"    Nontronite-Na 0.0 " // trim(s_nont_na) // kinetics //NEW_LINE('')// & ! smectite
		 &"    Nontronite-Mg 0.0 " // trim(s_nont_mg) // kinetics //NEW_LINE('')// & ! smectite
		 &"    Nontronite-K 0.0 " // trim(s_nont_k) // kinetics //NEW_LINE('')// & ! smectite
		!  &"    Nontronite-H 0.0 " // trim(s_nont_h) // kinetics //NEW_LINE('')// & ! smectite
		 &"    Nontronite-Ca 0.0 " // trim(s_nont_ca) // kinetics //NEW_LINE('')// & ! smectite
		! &"    Muscovite 0.0 " // trim(s_muscovite) // kinetics //NEW_LINE('')// & ! mica
		 &"    Mesolite 0.0 " // trim(s_mesolite) // kinetics //NEW_LINE('')// & ! zeolite
		 &"    Anhydrite 0.0 " // trim(s_anhydrite) // kinetics //NEW_LINE('')// & ! formerly magnesite
		 &"    Smectite-high-Fe-Mg 0.0 " // trim(s_smectite) // kinetics //NEW_LINE('')// & ! smectite
		 &"    Saponite-K 0.0 " // trim(s_saponite_k) // kinetics //NEW_LINE('')// & ! smectite
		!   &"    Vermiculite-Na 0.0 " // trim(s_verm_na) // kinetics //NEW_LINE('')// &
		  &"    Hematite 0.0 " // trim(s_hematite) // kinetics //NEW_LINE('')// &
		! &"    Hematite " // trim(si_hematite) // trim(s_hematite) // kinetics //NEW_LINE('')// &
		!   &"    Vermiculite-Ca 0.0 " // trim(s_verm_ca) // kinetics //NEW_LINE('')// &
		 &"    Analcime 0.0 " // trim(s_analcime) // kinetics //NEW_LINE('')// & ! zeolite
		 &"    Phillipsite 0.0 " // trim(s_phillipsite) // kinetics //NEW_LINE('')// & ! zeolite
		   &"    Diopside 0.0 " // trim(s_diopside) // kinetics //NEW_LINE('')// & ! pyroxene
		!    &"    Epidote  0.0 " // trim(s_epidote) // kinetics //NEW_LINE('')// &
		!   &"    Gismondine 0.0 " // trim(s_gismondine) // kinetics //NEW_LINE('')// & ! zeolite
		  &"    Hedenbergite 0.0 " // trim(s_hedenbergite) // kinetics //NEW_LINE('')// & ! pyroxene
		!   &"    Chalcedony 0.0 " // trim(s_chalcedony) // kinetics //NEW_LINE('')// & ! quartz
		!   &"    Vermiculite-Mg 0.0 " // trim(s_verm_mg) // kinetics //NEW_LINE('')// &
		 &"    Ferrihydrite 0.0 " // trim(s_ferrihydrite) // kinetics //NEW_LINE('')// & ! iron oxyhydroxide
		  &"    Natrolite 0.0 " // trim(s_natrolite) // kinetics //NEW_LINE('')// & ! zeolite
		&"    Talc 0.0 " // trim(s_talc) // kinetics //NEW_LINE('')// &
		 &"    Smectite-low-Fe-Mg 0.0 " // trim(s_smectite_low) // kinetics //NEW_LINE('')// & ! smectite
		!  &"    Prehnite 0.0 " // trim(s_prehnite) // kinetics //NEW_LINE('')// &
		  &"    Chlorite(14A) 0.0 " // trim(s_chlorite) // kinetics //NEW_LINE('')// & ! chlorite
		  &"    Scolecite 0.0 " // trim(s_scolecite) // kinetics //NEW_LINE('')// & ! zeolite
		  &"    Chamosite-7A 0.0 " // trim(s_chamosite7a) // kinetics //NEW_LINE('')// & ! chlorite
		  &"    Clinochlore-14A 0.0 " // trim(s_clinochlore14a) // kinetics //NEW_LINE('')// & ! chlorite
		  &"    Clinochlore-7A 0.0 " // trim(s_clinochlore7a) // kinetics //NEW_LINE('')// & ! chlorite
		 &"   Saponite-Ca 0.0 " // trim(s_saponite_ca) // kinetics //NEW_LINE('')// & ! smectite
		 &"   Pyrrhotite 0.0 " // trim(s_pyrrhotite) // kinetics //NEW_LINE('')// & ! sulfide
		!  &"   Magnetite 0.0 " // trim(s_magnetite) // kinetics //NEW_LINE('')// &
		  &"   Daphnite-7a 0.0 " // trim(s_daphnite_7a) // kinetics //NEW_LINE('')// & ! chlorite
		  &"   Daphnite-14a 0.0 " // trim(s_daphnite_14a) // kinetics //NEW_LINE('')// & ! chlorite
		!  &"   Vermiculite-K 0.0 " // trim(s_verm_k) // kinetics //NEW_LINE('')// &
		!  &"   Aragonite 0.0 " // trim(s_aragonite) // kinetics //NEW_LINE('')// &
		! &" -force_equality"  //NEW_LINE('')// &
		 &"   Lepidocrocite 0.0 " // trim(s_lepidocrocite) // kinetics //NEW_LINE('')// & ! iron oxyhydroxide
	

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