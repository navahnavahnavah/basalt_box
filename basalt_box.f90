PROGRAM main
	use basalt_box_mod
	implicit none

! 	INCLUDE "IPhreeqc.f90.inc"
save


interface
	! writes 2D array to file
	function write_matrix ( m, n, table, filename )
		implicit none
		integer :: m, n, j, output_status, unit0, reclen
		character ( len = * ) filename
		character ( len = 30 ) string
		real(4)  :: table(m,n) , write_matrix
	end function write_matrix

	! writes 1D array to file
	function write_vec ( n, vector, filename )
		implicit none
		integer :: n, j, output_status, unit0
		character ( len = * ) filename
		real(4)  :: vector(n), write_vec
	end function write_vec

end interface


integer, parameter :: g_pri=5, g_sec=80, g_sol=15, g_med=7, n_box=3, alt_num=136


integer, parameter :: tn = 200000, tp = 1000
integer :: i, ii, j, jj
real(4) :: t_min = 0.0, t_max = 1.57e14


! integer, parameter :: tn = 20000, tp = 100
! integer :: i, ii, j, jj
! real(4) :: t_min = 0.0, t_max = 1.57e13

! integer, parameter :: tn = 50000, tp = 1000
! integer :: i, ii, j, jj
! real(4) :: t_min = 0.0, t_max = 3.925e13

real(4) :: dt
real(4) :: solute0(g_sol)
real(4) :: primary(g_pri,n_box), secondary(g_sec,n_box), solute(g_sol,n_box), medium(g_med,n_box)
real(4) :: primary_mat(g_pri,n_box,tp), secondary_mat(g_sec,n_box,tp), solute_mat(g_sol,n_box,tp), medium_mat(g_med,n_box,tp)
real(4) :: temps(tn,n_box), mix(tn,n_box), phi(tn,n_box), area(tn,n_box)
real(4) :: run_box_out(n_box,alt_num)
real(4) :: writer
real(4) :: temp_100_ht(tn), temp_100_2ht(tn)
character(len=300) :: path
character(len=300) :: s_i
integer :: in
real(4) :: t_vol_s_0 = 0.006
real(4) :: t_vol_a_0 = 0.006
real(4) :: t_vol_b_0 = 0.006

! RUNTIME PARAMETERS
character(len=300) :: param_path, param_temp_string, param_tra_string, param_xb_string
character(len=300) :: param_exp_string, param_exp1_string
character(len=300) :: param_sw_diff_string, param_t_diff_string, param_q_string
real(4) :: param_temp, param_tra, param_xb, param_exp, param_exp1
real(4) :: param_sw_diff, param_t_diff, param_q



in = iargc()

call getarg(1,param_path)
call getarg(2,param_temp_string)
call getarg(3,param_tra_string)
call getarg(4,param_xb_string)
call getarg(5,param_exp_string)
call getarg(6,param_exp1_string)

call getarg(7,param_sw_diff_string)
call getarg(8,param_t_diff_string)
call getarg(9,param_q_string)


read (param_temp_string, *) param_temp
read (param_tra_string, *) param_tra
read (param_xb_string, *) param_xb
read (param_exp_string, *) param_exp
read (param_exp1_string, *) param_exp1


read (param_sw_diff_string, *) param_sw_diff
write(*,*) "PARAM_SW_DIFF_STRING: " , param_sw_diff_string
read (param_t_diff_string, *) param_t_diff


write(*,*) "PARAM_SW_DIFF BEFORE: " , param_sw_diff
param_sw_diff = 10.0**(param_sw_diff)
write(*,*) "PARAM_SW_DIFF AFTER: " , param_sw_diff
param_t_diff = (3.14e7)*(10.0**(param_t_diff))

param_tra = param_tra/1000.0
param_tra = 10.0**(param_tra)
param_xb = -1.0*param_xb/100.0
param_xb = 10.0**(param_xb)

path = param_path !'/data/navah/summer16/basalt_box/output/test0/'


read (param_q_string, *) param_q

param_sw_diff = (3.14e7)*(t_vol_s_0/1000.0)/((1.0e-9)*param_q)

write(*,*) "PARAM_Q: " , param_q
write(*,*) "PARAM_SW_DIFF = f(PARAM_Q)" , param_sw_diff


! current temp stages in use

!- REACTION TEMPERATURE
temp_100_2ht = 60.0

if (param_temp .eq. 100) then
	temps(:,1) = temp_100_2ht
	temps(:,2) = temp_100_2ht
	temps(:,3) = temp_100_2ht
end if





dt = (t_max-t_min)/real(tn - 1,kind=4)

! INITIAL GEOCHEMICAL CONDITIONS

area = 1.0
phi = 0.1
!mix = 0.1
!temps = param_temp!50.0

! mix(:,1) = 3.14e11
! mix(:,2) = 3.14e12
! mix(:,3) = 3.14e11*2.0

mix(:,1) = param_sw_diff
mix(:,2) = param_sw_diff/2.0
mix(:,3) = param_t_diff!*2.0

! primary minerals [mol]
primary = 0.0
primary(1,:) = 0.0


primary(2,1) = 0.0 ! plagioclase
primary(3,1) = 0.0 ! pyroxene
primary(4,1) = 0.0 ! olivine
primary(5,1) = 1.0 ! basaltic glass

primary(2,2) = 0.0 ! plagioclase
primary(3,2) = 0.0 ! pyroxene
primary(4,2) = 0.0 ! olivine
primary(5,2) = 1.0 ! basaltic glass

primary(2,3) = 0.0 ! plagioclase
primary(3,3) = 0.0 ! pyroxene
primary(4,3) = 0.0 ! olivine
primary(5,3) = 1.0 ! basaltic glass


! secondary minerals [mol]
secondary = 0.0

! ! saturation
! saturation = 0.0

! ! SURFACE SEAWATER SITE 858-ish, JUAN DE FUCA AREA
! from elderfield 1999, and other places
solute(1,:) = 8.2 ! ph
solute(2,:) = .00243 ! Alk
! solute(3,1) = 0.0080 ! water mass
! solute(3,2) = 0.0075 ! water mass
! solute(3,3) = 0.0075 ! water mass
solute(3,1) = t_vol_s_0 ! water mass
solute(3,2) = t_vol_a_0 ! water mass
solute(3,3) = t_vol_b_0 ! water mass
solute(4,:) = .002100 ! TOTAL C
solute(5,:) = .01028 ! Ca
solute(6,:) = .0528 ! Mg
solute(7,:) = .460 ! Na
solute(8,:) = .00995 ! K
solute(9,:) = 0.0 ! Fe
solute(10,:) = .028  ! S(6)
solute(11,:) = 0.0 ! Si
solute(12,:) = .540 ! Cl
solute(13,:) =  0.0!0.0 ! Al
solute(14,:) = .00245 ! inert
solute(15,:) = 0.0 ! CO3-2

solute0 = solute(:,1)


medium(1,:) = .1 ! phiCoarse
medium(2,:) = 0.0 ! s_sp
! medium(3,1) = 0.008
! medium(3,2) = 0.0075
! medium(3,3) = 0.0075
medium(3,1) = t_vol_s_0
medium(3,2) = t_vol_a_0
medium(3,3) = t_vol_b_0

medium(4,:) = 1.0! reactive fraction now!
medium(5,:) = 1.0 ! rxn toggle
medium(5,:) = 1.0 ! ALL CELLS ON/OFF
!medium(1,:,5) = 1.0
medium(6,:) = 0.0 ! x-coord
medium(7,:) = 0.0 ! y-coord


do j = 1,tn

	! write(*,*) "timestep:" , j

	if (mod(j,tn/100) .eq. 0) then
			OPEN(UNIT=88, status = 'replace', FILE=trim(path) // 'dynamicSubStep.txt')
			write(88,*) j
			close ( 88 )
	end if

! 	! if (mod(j,tn/tp) .eq. 0.0) then
! 		write(*,*) "STARTING STEP:" , j
! 		write(*,*) " "
! 		write(*,*) " "
! 		write(*,*) " "
! 		OPEN(UNIT=8, status = 'replace', FILE=trim(path) // 'dynamicStep.txt')
! 		write(*,*) "opened"
! 		write(8,*) j
! 		close ( 8 )
! 		!velocitiesCoarse0 = 0.0
! 	! end if
!

	!run_box_out = 0.0
! ! RUN BOX GOES HERE
run_box_out = run_box(primary, secondary, solute, solute0, medium, g_pri, g_sec, g_sol, g_med, n_box, alt_num, temps(j,:), area(j,:), mix(j,:), dt, param_exp_string, param_exp1_string)

	do i = 1,n_box

		solute(:,i) = (/ run_box_out(i,2), run_box_out(i,3), run_box_out(i,4), run_box_out(i,5), run_box_out(i,6), &
		run_box_out(i,7), run_box_out(i,8), run_box_out(i,9), run_box_out(i,10), run_box_out(i,11), run_box_out(i,12), &
		run_box_out(i,13), run_box_out(i,14), run_box_out(i,15), 0.0/)

		!# volume scaling
		if (i == 1) then
			do ii = 4,g_sol
				solute(ii,i) = solute(ii,i)*t_vol_s_0/solute(3,i)
			end do
			solute(3,i) = t_vol_s_0
		end if

		if (i == 2) then
			do ii = 4,g_sol
				solute(ii,i) = solute(ii,i)*t_vol_a_0/solute(3,i)
			end do
			solute(3,i) = t_vol_a_0
		end if

		if (i == 3) then
			do ii = 4,g_sol
				solute(ii,i) = solute(ii,i)*t_vol_b_0/solute(3,i)
			end do
			solute(3,i) = t_vol_b_0
		end if

		! write(*,*) "timestep:" , j , " " , 'n_box:' , i
		! write(*,*) solute(:,i)
		! write(*,*) " "

! 		secondary(:,i) = (/ run_box_out(i,16), run_box_out(i,18), run_box_out(i,20), run_box_out(i,22), run_box_out(i,24), run_box_out(i,26), run_box_out(i,28), &
! 		run_box_out(i,30), run_box_out(i,32), run_box_out(i,34), run_box_out(i,36), run_box_out(i,38), run_box_out(i,40), run_box_out(i,42), &
! 		run_box_out(i,44), run_box_out(i,46), run_box_out(i,48), run_box_out(i,50), run_box_out(i,52), run_box_out(i,54), run_box_out(i,56), &
! 		run_box_out(i,58), run_box_out(i,60), run_box_out(i,62), run_box_out(i,64), run_box_out(i,66), run_box_out(i,68), run_box_out(i,70), &
! 		run_box_out(i,72), run_box_out(i,74), run_box_out(i,76), run_box_out(i,78), run_box_out(i,80), run_box_out(i,82), run_box_out(i,84), &
! 		run_box_out(i,86), run_box_out(i,88), run_box_out(i,90), run_box_out(i,92), run_box_out(i,94), run_box_out(i,96), run_box_out(i,98), &
! 		run_box_out(i,100), run_box_out(i,102), run_box_out(i,104), run_box_out(i,106), run_box_out(i,108), run_box_out(i,110), run_box_out(i,112), &
! 		run_box_out(i,114), run_box_out(i,116), run_box_out(i,118), run_box_out(i,120), run_box_out(i,122), &
! 		!run_box_out(i,114), run_box_out(i,116), run_box_out(i,118), run_box_out(i,120), run_box_out(i,122), run_box_out(i,124), &
! 		! run_box_out(i,126), run_box_out(i,128), &
! 		!run_box_out(i,126),&
! 		run_box_out(i,124), run_box_out(i,125),&
! 		run_box_out(i,126), run_box_out(i,127),&
! 		run_box_out(i,128), run_box_out(i,129),&
! 		run_box_out(i,130), run_box_out(i,131), run_box_out(i,132), run_box_out(i,133), run_box_out(i,134), run_box_out(i,135), run_box_out(i,136), &
! 		run_box_out(i,137), run_box_out(i,138), run_box_out(i,139), run_box_out(i,140), &
! 		run_box_out(i,141), run_box_out(i,142), run_box_out(i,143), run_box_out(i,144), run_box_out(i,145), run_box_out(i,146), &
! 		run_box_out(i,147), run_box_out(i,148), run_box_out(i,149), run_box_out(i,150), run_box_out(i,151), run_box_out(i,152), &
! 		run_box_out(i,153), run_box_out(i,154), run_box_out(i,155), run_box_out(i,156), run_box_out(i,157), run_box_out(i,158), &
! 		run_box_out(i,159), run_box_out(i,160), run_box_out(i,161), run_box_out(i,162), run_box_out(i,163), run_box_out(i,164), &
! 		run_box_out(i,165), run_box_out(i,166), run_box_out(i,167), run_box_out(i,168), run_box_out(i,169), run_box_out(i,170), &
! 		run_box_out(i,171), run_box_out(i,172), run_box_out(i,173), run_box_out(i,174), run_box_out(i,175), run_box_out(i,176), &
! 		run_box_out(i,177)/)
! 		! run_box_out(i,177), run_box_out(i,178), run_box_out(i,179), run_box_out(i,180), run_box_out(i,181), run_box_out(i,182), &
! 		! run_box_out(i,183), run_box_out(i,184), run_box_out(i,185), run_box_out(i,186)/)
! ! 		run_box_out(i,183)/)

		DO ii = 1,g_sec/2
			secondary(ii,i) = run_box_out(i,2*ii+14)
		END DO
		! write(*,*) "timestep:" , j , " " , 'n_box:' , i
		! write(*,*) secondary(:,i)
		! write(*,*) " "

		primary(:,i) = (/ 0.0*run_box_out(i,136), run_box_out(i,127), run_box_out(i,129), run_box_out(i,131), run_box_out(i,133)/)

		!medium(1:4,i) = (/ run_box_out(i,187), run_box_out(i,187), run_box_out(i,4), run_box_out(i,187)/)

	end do

	if (mod(j,tn/tp) .eq. 0.0) then

		write(*,*) "writing timestep:" , j/(tn/tp)

		primary_mat(:,:,j/(tn/tp)) = primary
		secondary_mat(:,:,j/(tn/tp)) = secondary
		solute_mat(:,:,j/(tn/tp)) = solute
		medium_mat(:,:,j/(tn/tp)) = medium

	end if

end do


! writer = write_vec ( tp, primary_mat(), trim(path) // 'y.txt' )

!# WRITE TO FILE
writer = write_matrix(n_box, tp, primary_mat(5,:,:), trim(path) // 'z_primary_mat5.txt')
! writer = write_matrix(n_box, tp, primary_mat(4,:,:), trim(path) // 'z_primary_mat4.txt')
! writer = write_matrix(n_box, tp, primary_mat(3,:,:), trim(path) // 'z_primary_mat3.txt')
! writer = write_matrix(n_box, tp, primary_mat(2,:,:), trim(path) // 'z_primary_mat2.txt')

writer = write_matrix(n_box, tp, solute_mat(1,:,:), trim(path) // 'z_solute_ph.txt')
writer = write_matrix(n_box, tp, solute_mat(2,:,:), trim(path) // 'z_solute_alk.txt')
writer = write_matrix(n_box, tp, solute_mat(3,:,:), trim(path) // 'z_solute_w.txt')
writer = write_matrix(n_box, tp, solute_mat(4,:,:), trim(path) // 'z_solute_c.txt')
writer = write_matrix(n_box, tp, solute_mat(5,:,:), trim(path) // 'z_solute_ca.txt')
writer = write_matrix(n_box, tp, solute_mat(6,:,:), trim(path) // 'z_solute_mg.txt')
writer = write_matrix(n_box, tp, solute_mat(7,:,:), trim(path) // 'z_solute_na.txt')
writer = write_matrix(n_box, tp, solute_mat(8,:,:), trim(path) // 'z_solute_k.txt')
writer = write_matrix(n_box, tp, solute_mat(9,:,:), trim(path) // 'z_solute_fe.txt')
writer = write_matrix(n_box, tp, solute_mat(10,:,:), trim(path) // 'z_solute_s.txt')
writer = write_matrix(n_box, tp, solute_mat(11,:,:), trim(path) // 'z_solute_si.txt')
writer = write_matrix(n_box, tp, solute_mat(12,:,:), trim(path) // 'z_solute_cl.txt')
writer = write_matrix(n_box, tp, solute_mat(13,:,:), trim(path) // 'z_solute_al.txt')

writer = write_matrix(n_box, tp, medium_mat(1,:,:), trim(path) // 'z_medium_sum.txt')

do i=1,g_sec/2
    if (i < 10) then
		write(s_i,'(i1)') i
    else
		write(s_i,'(i2)') i
    end if
	if (maxval(secondary_mat(i,:,:)) > 0.0) then
		writer = write_matrix(n_box, tp, secondary_mat(i,:,:), trim(path) // 'z_secondary_mat' // trim(s_i) // '.txt')
	end if
end do


END PROGRAM main








! ----------------------------------------------------------------------------------%%
!
! WRITE_VEC
!
! ----------------------------------------------------------------------------------%%

function write_vec ( n, vector, filename )
	use basalt_box_mod
  implicit none
  integer :: n, j, output_status, unit0
  character ( len = * ) filename
  real(4)  :: vector(n), write_vec


  unit0 = get_unit ()
  open ( unit = unit0, file = filename, status = 'replace', iostat = output_status )
  if ( output_status /= 0 ) then
    write ( *, '(a,i8)' ) 'COULD NOT OPEN OUTPUT FILE "' // &
      trim ( filename ) // '" USING UNIT ', unit0
    unit0 = -1
    stop
  end if


  if ( 0 < n ) then
    do j = 1, n
      write ( unit0, '(2x,g24.16)' ) vector(j)
    end do

  end if


  close ( unit = unit0 )
  write_vec = 1.0
  return
end function write_vec




! ----------------------------------------------------------------------------------%%
!
! WRITE_MATRIX
!
! ----------------------------------------------------------------------------------%%

function write_matrix ( m, n, table, filename )
	use basalt_box_mod
  implicit none
  integer :: m, n, j, output_status, unit0, reclen
  character ( len = * ) filename
  character ( len = 30 ) string
  real(4)  :: table(m,n) , write_matrix



  INQUIRE(iolength=reclen)table
  unit0 = get_unit ()
  open ( unit = unit0, file = filename, &
    status = 'replace', iostat = output_status, buffered='YES', buffercount=500)

  if ( output_status /= 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8MAT_WRITE - Fatal error!'
    write ( *, '(a,i8)' ) 'Could not open the output file "' // &
      trim ( filename ) // '" on unit ', unit0
    unit0 = -1
    stop
  end if



!
 	write ( string, '(a1,i8,a1,i8,a1,i8,a1)' ) '(', m, 'g', 24, '.', 16, ')'
! 	!write ( string, '(a1,i8,a1,i8,a1,i8,a1)' ) '(', m, 'g', 14, '.', 6, ')'
!
!     do j = 1, n
!       write ( unit0, string) table(1:m,j)
!     end do

    do j = 1, n
      write ( unit0, 400) table(1:m,j)
    end do
400 FORMAT(<m>g24.16)


  close ( unit = unit0 )
  write_matrix = 2.0
  return
end function write_matrix
