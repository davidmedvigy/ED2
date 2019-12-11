Module mend_coupler
  implicit none

Contains

  subroutine mend_update_parameters_coupler(soil_tempk, soil_water,  &
       ntext_soil, pH)
    use mend_consts_coms, only: som_consts, som_consts_base
    use grid_coms, only: nzg
    use soil_coms, only: soil
    use consts_coms, only: wdns, grav
    use mend_diagnose, only: mend_update_parameters
    implicit none

    real, dimension(nzg), intent(in) :: soil_tempk
    real, dimension(nzg), intent(in) :: soil_water
    integer, dimension(nzg), intent(in) :: ntext_soil
    
    real :: tp
    real :: wp
    real, intent(in) :: pH !=6.24  ! SROAK: 5.82; SRTDF: 6.24; PVTDF: 6.83
    real :: wfp
    integer :: ntxt

    ntxt = ntext_soil(nzg)
    tp = soil_tempk(nzg) - 273.15
    wfp = soil_water(nzg) / soil(ntxt)%slmsts

!tp = tp + 2.
!wfp = 0.8

!    root_avail_water = 0.
!    do k = krdepth, nzg
!       root_avail_water = root_avail_water + soil_water(k)*dslz(k) !m3/m2
!    enddo
!    root_avail_water = root_avail_water / (-slz(krdepth)) !m3/m3
!    wgpfrac = root_avail_water / slmsts
    wp = wdns * grav * soil(ntxt)%slpots / wfp**soil(ntxt)%slbs * 1.0e-6

    call mend_update_parameters(tp, wp, pH, wfp, som_consts, som_consts_base, &
         soil(ntxt)%slmsts, soil(ntxt)%sfldcap)

    return
  end subroutine mend_update_parameters_coupler

  subroutine mend_init(sens_params)
    use ed_state_vars, only: edgrid_g, edtype, polygontype, sitetype
    use nutrient_constants, only: soil_bulk_den, soil_ph
    use mend_consts_coms, only: mend_init_consts, litt_consts, wood_consts, &
         som_consts
    use mend_som, only: som_init
!    use mend_litter, only: litt_init
!    use mend_wood, only: wood_init
    use mend_state_vars, only: npom, nwood, mend_zero_vars, mend_mm_time
    use nutrient_constants, only: soil_cpct, soil_som_c2n, soil_totp,   &
         soil_extrp
    implicit none

    type(edtype), pointer :: cgrid
    type(polygontype), pointer :: cpoly
    type(sitetype), pointer :: csite
    integer :: ipy
    integer :: isi
    integer :: ipa
    integer :: iwood
    integer, intent(in) :: sens_params
    integer :: sens_code

!    sens_code = sens_params + 1
!    if(sens_code > 40)sens_code = sens_code - 40
    sens_code = sens_params

    write(*,*)'sens_params = ',sens_params, sens_code
!    call mend_init_consts(sens_code)
    call mend_init_consts(0)

    mend_mm_time = 0.

    cgrid => edgrid_g(1)
    do ipy = 1, cgrid%npolygons
       cpoly => cgrid%polygon(ipy)
       do isi = 1, cpoly%nsites
          csite => cpoly%site(isi)
          do ipa = 1, csite%npatches

             call mend_zero_vars(csite%mend_mm, ipa, ipa)

             csite%mend%bulk_den(ipa) = soil_bulk_den
             csite%mend%pH(ipa) = soil_ph

!             if(fertex == 'FE_A')then
!                csite%mend%bulk_den(ipa) = 954.
!                csite%mend%pH(ipa) = 6.45
!             elseif(fertex == 'FE_B')then
!                csite%mend%bulk_den(ipa) = 808.
!                csite%mend%pH(ipa) = 6.26
!             elseif(fertex == 'FE_C')then
!                csite%mend%bulk_den(ipa) = 834.
!                csite%mend%pH(ipa) = 6.33
!             elseif(fertex == 'FE_D')then
!                csite%mend%bulk_den(ipa) = 1012.
!                csite%mend%pH(ipa) = 6.51
!             elseif(fertex == 'FE_E')then
!                csite%mend%bulk_den(ipa) = 1037.
!                csite%mend%pH(ipa) = 6.58
!             elseif(fertex == 'FE_F')then
!                csite%mend%bulk_den(ipa) = 883.
!                csite%mend%pH(ipa) = 6.60
!             elseif(fertex == 'FE_G')then
!                csite%mend%bulk_den(ipa) = 827.
!                csite%mend%pH(ipa) = 6.67
!             elseif(fertex == 'FE_H')then
!                csite%mend%bulk_den(ipa) = 959.
!                csite%mend%pH(ipa) = 6.49
!             elseif(fertex == 'FE_I')then
!                csite%mend%bulk_den(ipa) = 855.
!                csite%mend%pH(ipa) = 6.46
!             elseif(fertex == 'FE_J')then
!                csite%mend%bulk_den(ipa) = 917.
!                csite%mend%pH(ipa) = 6.45
!             elseif(fertex == 'FE_K')then
!                csite%mend%bulk_den(ipa) = 879.
!                csite%mend%pH(ipa) = 6.59
!             elseif(fertex == 'FE_L')then
!                csite%mend%bulk_den(ipa) = 747.
!                csite%mend%pH(ipa) = 6.83
!             elseif(fertex == 'M')then
!                csite%mend%bulk_den(ipa) = 911.
!                csite%mend%pH(ipa) = 6.36
!             elseif(fertex == 'N')then
!                csite%mend%bulk_den(ipa) = 779.
!                csite%mend%pH(ipa) = 6.61
!             elseif(fertex == 'O')then
!                csite%mend%bulk_den(ipa) = 841.
!                csite%mend%pH(ipa) = 6.86
!             elseif(fertex == 'P')then
!                csite%mend%bulk_den(ipa) = 836.
!                csite%mend%pH(ipa) = 6.64
!             endif

             csite%mend_mm%bulk_den(ipa) = csite%mend%bulk_den(ipa)
             csite%mend_mm%pH(ipa) = csite%mend%pH(ipa)

             call som_init(npom,  &
                  csite%mend%som%cvars%pom(:,ipa), csite%mend%som%cvars%dom(ipa), &
                  csite%mend%som%cvars%enz_pom(:,ipa), csite%mend%som%cvars%mom(ipa),  &
                  csite%mend%som%cvars%qom(ipa), csite%mend%som%cvars%enz_mom(ipa),  &
                  csite%mend%som%cvars%amb(ipa), csite%mend%som%cvars%dmb(ipa),   &
                  csite%mend%som%nvars%pom(:,ipa), csite%mend%som%nvars%dom(ipa),  &
                  csite%mend%som%nvars%enz_pom(:,ipa), csite%mend%som%nvars%mom(ipa),  &
                  csite%mend%som%nvars%qom(ipa), csite%mend%som%nvars%enz_mom(ipa),  &
                  csite%mend%som%nvars%amb(ipa), csite%mend%som%nvars%dmb(ipa),   &
                  csite%mend%som%pvars%pom(:,ipa), csite%mend%som%pvars%dom(ipa), &
                  csite%mend%som%pvars%enz_pom(:,ipa), csite%mend%som%pvars%mom(ipa),  &
                  csite%mend%som%pvars%qom(ipa), csite%mend%som%pvars%enz_mom(ipa),  &
                  csite%mend%som%pvars%amb(ipa), csite%mend%som%pvars%dmb(ipa),   &
                  csite%mend%som%fluxes%co2_lost(ipa),  &
                  csite%mend%som%fluxes%nmin(ipa), &
                  csite%mend%som%fluxes%nitr(ipa), &
                  csite%mend%som%invars%nh4(ipa), &
                  csite%mend%som%invars%no3(ipa), csite%mend%som%invars%psol(ipa), &
                  csite%mend%som%invars%plab(ipa), csite%mend%som%fluxes%ngas_lost(ipa), &
                  csite%mend%som%cvars%enz_ptase(ipa), csite%mend%som%nvars%enz_ptase(ipa), &
                  csite%mend%som%pvars%enz_ptase(ipa), csite%mend%som%fluxes%nh4_dep(ipa),  &
                  csite%mend%som%fluxes%no3_dep(ipa), csite%mend%som%fluxes%ppar_dep(ipa), &
                  csite%mend%som%fluxes%nh4_plant(:,ipa), csite%mend%som%fluxes%nh4_bnf(ipa), &
                  csite%mend%som%fluxes%no3_plant(:,ipa), csite%mend%som%fluxes%c_leach(ipa), &
                  csite%mend%som%fluxes%n_leach(ipa), csite%mend%som%fluxes%p_leach(ipa),  &
                  csite%mend%som%fluxes%p_plant(:,ipa), csite%mend%som%invars%pocc(ipa),  &
                  csite%mend%som%invars%psec(ipa), &
                  csite%mend%som%invars%ppar(ipa), csite%mend%som%plvars%enz_plant_n(:,ipa),  &
                  csite%mend%som%plvars%enz_plant_p(:,ipa), csite%mend%som%plvars%vnh4up_plant(:,ipa),  &
                  csite%mend%som%plvars%vno3up_plant(:,ipa),  &
                  csite%mend%som%plvars%vpup_plant(:,ipa),   &
                  csite%mend%som%plvars%plant_input_C_pom(:,ipa), &
                  csite%mend%som%plvars%plant_input_N_pom(:,ipa), &
                  csite%mend%som%plvars%plant_input_P_pom(:,ipa), &
                  csite%mend%som%plvars%plant_input_C_dom(ipa), &
                  csite%mend%som%plvars%plant_input_N_dom(ipa), &
                  csite%mend%som%plvars%plant_input_P_dom(ipa), &
                  som_consts, csite%mend%bulk_den(ipa),   &
                  soil_cpct, soil_som_c2n, soil_totp, soil_extrp)

             ! call litt_init(npom,  &
             !      csite%mend%litt%cvars%pom(:,ipa), csite%mend%litt%cvars%dom(ipa), &
             !      csite%mend%litt%cvars%enz_pom(:,ipa), csite%mend%litt%cvars%mom(ipa),  &
             !      csite%mend%litt%cvars%qom(ipa), csite%mend%litt%cvars%enz_mom(ipa),  &
             !      csite%mend%litt%cvars%amb(ipa), csite%mend%litt%cvars%dmb(ipa),   &
             !      csite%mend%litt%nvars%pom(:,ipa), csite%mend%litt%nvars%dom(ipa),  &
             !      csite%mend%litt%nvars%enz_pom(:,ipa), csite%mend%litt%nvars%mom(ipa),  &
             !      csite%mend%litt%nvars%qom(ipa), csite%mend%litt%nvars%enz_mom(ipa),  &
             !      csite%mend%litt%nvars%amb(ipa), csite%mend%litt%nvars%dmb(ipa),   &
             !      csite%mend%litt%pvars%pom(:,ipa), csite%mend%litt%pvars%dom(ipa),  &
             !      csite%mend%litt%pvars%enz_pom(:,ipa), csite%mend%litt%pvars%mom(ipa),  &
             !      csite%mend%litt%pvars%qom(ipa), csite%mend%litt%pvars%enz_mom(ipa),  &
             !      csite%mend%litt%pvars%amb(ipa), csite%mend%litt%pvars%dmb(ipa),   &
             !      csite%mend%litt%fluxes%co2_lost(ipa),  &
             !      csite%mend%litt%fluxes%nmin(ipa), &
             !      csite%mend%litt%fluxes%nitr(ipa), &
             !      csite%mend%litt%invars%nh4(ipa),  &
             !      csite%mend%litt%invars%no3(ipa), csite%mend%litt%invars%psol(ipa), &
             !      csite%mend%litt%invars%plab(ipa), csite%mend%litt%fluxes%ngas_lost(ipa),  &
             !      csite%mend%litt%cvars%enz_ptase(ipa), csite%mend%litt%nvars%enz_ptase(ipa),  &
             !      csite%mend%litt%pvars%enz_ptase(ipa), csite%mend%litt%fluxes%nh4_dep(ipa),  &
             !      csite%mend%litt%fluxes%no3_dep(ipa), csite%mend%litt%fluxes%ppar_dep(ipa), &
             !      csite%mend%litt%fluxes%nh4_plant(:,ipa), csite%mend%litt%fluxes%nh4_bnf(ipa),  &
             !      csite%mend%litt%fluxes%no3_plant(:,ipa), csite%mend%litt%fluxes%c_leach(ipa),  &
             !      csite%mend%litt%fluxes%n_leach(ipa), csite%mend%litt%fluxes%p_leach(ipa),  &
             !      csite%mend%litt%fluxes%p_plant(:,ipa), csite%mend%litt%invars%pocc(ipa),  &
             !      csite%mend%litt%invars%psec(ipa), &
             !      csite%mend%litt%invars%ppar(ipa), csite%mend%litt%plvars%enz_plant_n(:,ipa),  &
             !      csite%mend%litt%plvars%enz_plant_p(:,ipa), csite%mend%litt%plvars%vnh4up_plant(:,ipa), &
             !      csite%mend%litt%plvars%vno3up_plant(:,ipa),  &
             !      csite%mend%litt%plvars%vpup_plant(:,ipa), &
             !      csite%mend%litt%plvars%plant_input_C_pom(:,ipa), &
             !      csite%mend%litt%plvars%plant_input_N_pom(:,ipa), &
             !      csite%mend%litt%plvars%plant_input_P_pom(:,ipa), &
             !      csite%mend%litt%plvars%plant_input_C_dom(ipa), &
             !      csite%mend%litt%plvars%plant_input_N_dom(ipa), &
             !      csite%mend%litt%plvars%plant_input_P_dom(ipa), &
             !      litt_consts, csite%mend%bulk_den(ipa))
             
             ! do iwood = 1, nwood
             !    call wood_init(iwood, npom,  &
             !         csite%mend%wood(iwood)%cvars%pom(:,ipa),  &
             !         csite%mend%wood(iwood)%cvars%dom(ipa),  &
             !         csite%mend%wood(iwood)%cvars%enz_pom(:,ipa),  &
             !         csite%mend%wood(iwood)%cvars%mom(ipa),  &
             !         csite%mend%wood(iwood)%cvars%qom(ipa),  &
             !         csite%mend%wood(iwood)%cvars%enz_mom(ipa),  &
             !         csite%mend%wood(iwood)%cvars%amb(ipa),  &
             !         csite%mend%wood(iwood)%cvars%dmb(ipa), &
             !         csite%mend%wood(iwood)%nvars%pom(:,ipa),  &
             !         csite%mend%wood(iwood)%nvars%dom(ipa),  &
             !         csite%mend%wood(iwood)%nvars%enz_pom(:,ipa),  &
             !         csite%mend%wood(iwood)%nvars%mom(ipa),  &
             !         csite%mend%wood(iwood)%nvars%qom(ipa),  &
             !         csite%mend%wood(iwood)%nvars%enz_mom(ipa),  &
             !         csite%mend%wood(iwood)%nvars%amb(ipa),  &
             !         csite%mend%wood(iwood)%nvars%dmb(ipa),  &
             !         csite%mend%wood(iwood)%pvars%pom(:,ipa),  &
             !         csite%mend%wood(iwood)%pvars%dom(ipa),  &
             !         csite%mend%wood(iwood)%pvars%enz_pom(:,ipa),  &
             !         csite%mend%wood(iwood)%pvars%mom(ipa), &
             !         csite%mend%wood(iwood)%pvars%qom(ipa),  &
             !         csite%mend%wood(iwood)%pvars%enz_mom(ipa), &
             !         csite%mend%wood(iwood)%pvars%amb(ipa),  &
             !         csite%mend%wood(iwood)%pvars%dmb(ipa),  &
             !         csite%mend%wood(iwood)%fluxes%co2_lost(ipa),  &
             !         csite%mend%wood(iwood)%fluxes%nmin(ipa),  &
             !         csite%mend%wood(iwood)%fluxes%nitr(ipa),  &
             !         csite%mend%wood(iwood)%invars%nh4(ipa),  &
             !         csite%mend%wood(iwood)%invars%no3(ipa),  &
             !         csite%mend%wood(iwood)%invars%psol(ipa), &
             !         csite%mend%wood(iwood)%invars%plab(ipa), &
             !         csite%mend%wood(iwood)%fluxes%ngas_lost(ipa), &
             !         csite%mend%wood(iwood)%cvars%enz_ptase(ipa), &
             !         csite%mend%wood(iwood)%nvars%enz_ptase(ipa), &
             !         csite%mend%wood(iwood)%pvars%enz_ptase(ipa), &
             !         csite%mend%wood(iwood)%fluxes%nh4_dep(ipa), &
             !         csite%mend%wood(iwood)%fluxes%no3_dep(ipa), &
             !         csite%mend%wood(iwood)%fluxes%ppar_dep(ipa),   &
             !         csite%mend%wood(iwood)%fluxes%nh4_plant(:,ipa),  &
             !         csite%mend%wood(iwood)%fluxes%nh4_bnf(ipa), &
             !         csite%mend%wood(iwood)%fluxes%no3_plant(:,ipa), &
             !         csite%mend%wood(iwood)%fluxes%c_leach(ipa),  &
             !         csite%mend%wood(iwood)%fluxes%n_leach(ipa),  &
             !         csite%mend%wood(iwood)%fluxes%p_leach(ipa), &
             !         csite%mend%wood(iwood)%fluxes%p_plant(:,ipa), &
             !         csite%mend%wood(iwood)%invars%pocc(ipa), &
             !         csite%mend%wood(iwood)%invars%psec(ipa), &
             !         csite%mend%wood(iwood)%invars%ppar(ipa),  &
             !         csite%mend%wood(iwood)%plvars%enz_plant_n(:,ipa), &
             !         csite%mend%wood(iwood)%plvars%enz_plant_p(:,ipa),  &
             !         csite%mend%wood(iwood)%plvars%vnh4up_plant(:,ipa),  &
             !         csite%mend%wood(iwood)%plvars%vno3up_plant(:,ipa),  &
             !         csite%mend%wood(iwood)%plvars%vpup_plant(:,ipa),  &
             !         csite%mend%wood(iwood)%plvars%plant_input_C_pom(:,ipa), &
             !         csite%mend%wood(iwood)%plvars%plant_input_N_pom(:,ipa), &
             !         csite%mend%wood(iwood)%plvars%plant_input_P_pom(:,ipa), &
             !         csite%mend%wood(iwood)%plvars%plant_input_C_dom(ipa), &
             !         csite%mend%wood(iwood)%plvars%plant_input_N_dom(ipa), &
             !         csite%mend%wood(iwood)%plvars%plant_input_P_dom(ipa), &
             !         wood_consts(iwood), csite%mend%bulk_den(ipa))
             ! enddo
          enddo
       enddo
    enddo
    
    return
  end subroutine mend_init

  subroutine mend_extern_forcing(mend, ipa, ncohorts, broot, nplant, &
       pft,  &
       krdepth, slden, nstorage, pstorage, nstorage_min, pstorage_min, &
       water_supply_layer_frac, lai)
    use mend_state_vars, only: mend_model, nwood
!    use mend_wood, only: wood_extern_forcing
!    use mend_litter, only: litt_extern_forcing
    use mend_som, only: som_extern_forcing
    use mend_consts_coms, only: som_consts
    use nutrient_constants, only: ndep_rate, pdep_rate, ndep_appl, pdep_appl, nlsl
    use ed_misc_coms, only: current_time
    use mend_plant, only: som_plant_enzymes, litt_plant_enzymes, wood_plant_enzymes
    use soil_coms, only: nzg
    implicit none
    type(mend_model) :: mend
    integer, intent(in) :: ipa
    integer :: iwood
    integer, intent(in) :: ncohorts
    integer, intent(in), dimension(ncohorts) :: pft
    integer, intent(in), dimension(ncohorts) :: krdepth
    real, intent(in), dimension(ncohorts) :: broot
    real, intent(in), dimension(ncohorts) :: nplant
    real, intent(in), dimension(ncohorts) :: nstorage
    real, intent(in), dimension(ncohorts) :: pstorage
    real, intent(in), dimension(ncohorts) :: nstorage_min
    real, intent(in), dimension(ncohorts) :: pstorage_min
    real, intent(in), dimension(ncohorts) :: lai
    real, intent(in), dimension(nzg,ncohorts) :: water_supply_layer_frac
    real :: broot_total
    integer :: ico
    real, intent(in) :: slden
    real, dimension(ncohorts) :: water_supply

    do ico = 1, ncohorts
       water_supply(ico) = sum(water_supply_layer_frac(nlsl:nzg,ico))
    enddo

    call som_extern_forcing(ndep_rate, som_consts, slden, &
         mend%som%fluxes%nh4_dep(ipa), mend%som%fluxes%no3_dep(ipa), &
         pdep_rate, mend%som%fluxes%ppar_dep(ipa), current_time%year, &
         ndep_appl, pdep_appl)
    
    call som_plant_enzymes(ncohorts, broot, nplant, pft,  &
         krdepth, slden, mend%som%plvars%enz_plant_n(:,ipa),  &
         mend%som%plvars%enz_plant_p(:,ipa), &
         mend%som%plvars%vnh4up_plant(:,ipa),  &
         mend%som%plvars%vno3up_plant(:,ipa), &
         mend%som%plvars%vpup_plant(:,ipa), som_consts, nstorage, pstorage, &
         nstorage_min, pstorage_min, water_supply, lai)

!    call litt_extern_forcing(mend%litt%fluxes%nh4_dep(ipa), &
!         mend%litt%fluxes%no3_dep(ipa), mend%litt%fluxes%ppar_dep(ipa))
    
!    call litt_plant_enzymes(mend%litt%plvars%enz_plant_n(:,ipa), &
!         mend%litt%plvars%enz_plant_p(:,ipa), &
!         mend%litt%plvars%vnh4up_plant(:,ipa),  &
!         mend%litt%plvars%vno3up_plant(:,ipa), &
!         mend%litt%plvars%vpup_plant(:,ipa))
    
!    do iwood = 1, nwood
!       call wood_extern_forcing(iwood, mend%wood(iwood)%fluxes%nh4_dep(ipa), &
!            mend%wood(iwood)%fluxes%no3_dep(ipa),  &
!            mend%wood(iwood)%fluxes%ppar_dep(ipa))
!       call wood_plant_enzymes(iwood, &
!            mend%wood(iwood)%plvars%enz_plant_n(:,ipa), &
!            mend%wood(iwood)%plvars%enz_plant_p(:,ipa), &
!            mend%wood(iwood)%plvars%vnh4up_plant(:,ipa), &
!            mend%wood(iwood)%plvars%vno3up_plant(:,ipa), &
!            mend%wood(iwood)%plvars%vpup_plant(:,ipa))
!    enddo

    return
  end subroutine mend_extern_forcing

  subroutine mend_derivs_coupler(som, d_som, litt, d_litt, wood, d_wood, &
       csite, ipa, som_water_drainage, soil_water, d_can_co2, &
       d_co2budget_storage,ccapcani, ntext_soil)
    use mend_exchange, only: litt2som_exchange, plant2litt_exchange, &
         plant2som_exchange, plant2wood_exchange, wood2litt_exchange, &
         wood2som_exchange, zero_exchange_vars, inc_exchange_vars, &
         wood2wood_exchange, som2canopy_exchange
    use ed_state_vars, only: sitetype
    use mend_derivs, only: mend_derivs_layer
    use mend_consts_coms, only: som_consts, litt_consts, wood_consts
    use mend_state_vars, only: mend_vars, exchange_vars, npom, nwood
    use grid_coms, only: nzg
    use soil_coms, only: dslz, soil
    use consts_coms, only: wdns, pi1
    use nutrient_constants, only: nlsl

    implicit none

    real(kind=8), intent(in) :: som_water_drainage
    real(kind=8), dimension(nzg), intent(in) :: soil_water
    real :: litt_water_drainage
    real :: wood_water_drainage
    integer, intent(in) :: ipa
    type(sitetype), target :: csite
    type(mend_vars) :: som
    type(mend_vars) :: d_som
    type(mend_vars) :: litt
    type(mend_vars) :: d_litt
    type(mend_vars), dimension(nwood) :: wood
    type(mend_vars), dimension(nwood) :: d_wood
    real(kind=8), intent(in) :: ccapcani
    type(exchange_vars) :: litt2som
    type(exchange_vars) :: plant2litt
    type(exchange_vars) :: plant2som
    type(exchange_vars), dimension(nwood) :: plant2wood
    type(exchange_vars), dimension(nwood) :: wood2litt
    type(exchange_vars), dimension(nwood) :: wood2som
    type(exchange_vars) :: wood2litt_sum
    type(exchange_vars) :: wood2som_sum
    type(exchange_vars), dimension(nwood, nwood) :: wood2wood

    real, dimension(npom) :: input_pom_c_net
    real, dimension(npom) :: input_pom_n_net
    real, dimension(npom) :: input_pom_p_net
    real :: input_dom_c_net
    real :: input_dom_n_net
    real :: input_dom_p_net
    real :: input_nh4_net
    real :: input_no3_net
    real :: input_psol_net
    real :: input_ppar_net
    integer :: iwood
    integer :: jwood
    real :: gm2_mgg
    real :: total_water
    integer :: k
    real :: som_water_drainage_ps  ! units: 1/s
    real(kind=8), intent(inout) :: d_can_co2
    real(kind=8), intent(inout) :: d_co2budget_storage
    real :: wfp
    integer, dimension(nzg) :: ntext_soil

    wfp = soil_water(nzg) / soil(ntext_soil(nzg))%slmsts
!    wfp = soil_water(nzg) / soil(csite%ntext_soil(nzg,ipa))%slmsts
    gm2_mgg = 1. / (som_consts%eff_soil_depth * csite%mend%bulk_den(ipa))
    total_water = 0.
    do k = nlsl, nzg
       total_water = total_water + soil_water(k) * dslz(k)
    enddo
    ! No negative drainage.
    som_water_drainage_ps = max(0., som_water_drainage) / (total_water * wdns)
    litt_water_drainage = 0.
    wood_water_drainage = 0.

    call zero_exchange_vars(wood2litt_sum)
    call zero_exchange_vars(wood2som_sum)
    do iwood = 1, nwood
       call plant2wood_exchange(iwood, npom, &
            plant2wood(iwood)%pom_c, plant2wood(iwood)%pom_n,   &
            plant2wood(iwood)%pom_p, plant2wood(iwood)%dom_c,   &
            plant2wood(iwood)%dom_n, plant2wood(iwood)%dom_p, &
            plant2wood(iwood)%nh4, plant2wood(iwood)%no3,   &
            plant2wood(iwood)%psol)
       
       call wood2litt_exchange(iwood, npom, &
            wood(iwood)%cvars%pom(:,1), wood(iwood)%nvars%pom(:,1), wood(iwood)%pvars%pom(:,1), &
            wood(iwood)%cvars%dom(1), wood(iwood)%nvars%dom(1), wood(iwood)%pvars%dom(1), &
            wood(iwood)%invars%nh4(1), wood(iwood)%invars%no3(1), wood(iwood)%invars%psol(1), &
            wood2litt(iwood)%pom_c, wood2litt(iwood)%pom_n,   &
            wood2litt(iwood)%pom_p, wood2litt(iwood)%dom_c,  &
            wood2litt(iwood)%dom_n, wood2litt(iwood)%dom_p,   &
            wood2litt(iwood)%nh4, wood2litt(iwood)%no3,   &
            wood2litt(iwood)%psol, wood_consts(iwood))
       call inc_exchange_vars(wood2litt_sum, wood2litt(iwood))

       call wood2som_exchange(iwood, npom, &
            wood(iwood)%cvars%pom(:,1), wood(iwood)%nvars%pom(:,1), wood(iwood)%pvars%pom(:,1), &
            wood(iwood)%cvars%dom(1), wood(iwood)%nvars%dom(1), wood(iwood)%pvars%dom(1), &
            wood(iwood)%invars%nh4(1), wood(iwood)%invars%no3(1), wood(iwood)%invars%psol(1), &
            wood2som(iwood)%pom_c, wood2som(iwood)%pom_n,   &
            wood2som(iwood)%pom_p, wood2som(iwood)%dom_c,  &
            wood2som(iwood)%dom_n, wood2som(iwood)%dom_p,   &
            wood2som(iwood)%nh4, wood2som(iwood)%no3,   &
            wood2som(iwood)%psol, wood_consts(iwood))
       call inc_exchange_vars(wood2som_sum, wood2som(iwood))

       do jwood = 1, nwood
          call wood2wood_exchange(iwood, jwood, npom, &
               wood(iwood)%cvars%pom(:,1), wood(iwood)%nvars%pom(:,1), wood(iwood)%pvars%pom(:,1), &
               wood(iwood)%cvars%dom(1), wood(iwood)%nvars%dom(1), wood(iwood)%pvars%dom(1), &
               wood(iwood)%invars%nh4(1), wood(iwood)%invars%no3(1), wood(iwood)%invars%psol(1), &
               wood2wood(iwood,jwood)%pom_c, wood2wood(iwood,jwood)%pom_n,   &
               wood2wood(iwood,jwood)%pom_p, wood2wood(iwood,jwood)%dom_c,  &
               wood2wood(iwood,jwood)%dom_n, wood2wood(iwood,jwood)%dom_p,   &
               wood2wood(iwood,jwood)%nh4, wood2wood(iwood,jwood)%no3, &
               wood2wood(iwood,jwood)%psol, wood_consts(iwood))
       enddo

    enddo

    call plant2litt_exchange(npom, &
         plant2litt%pom_c, plant2litt%pom_n, plant2litt%pom_p, &
         plant2litt%dom_c, plant2litt%dom_n, plant2litt%dom_p, &
         plant2litt%nh4, plant2litt%no3, plant2litt%psol)

    call litt2som_exchange(npom, &
         litt%cvars%pom(:,1), litt%nvars%pom(:,1), litt%pvars%pom(:,1), &
         litt%cvars%dom(1), litt%nvars%dom(1), litt%pvars%dom(1), &
         litt%invars%nh4(1), litt%invars%no3(1), litt%invars%psol(1), &
         litt2som%pom_c, litt2som%pom_n, litt2som%pom_p, &
         litt2som%dom_c, litt2som%dom_n, litt2som%dom_p, &
         litt2som%nh4, litt2som%no3, litt2som%psol)

    call plant2som_exchange(npom, &
         plant2som%pom_c, plant2som%pom_n, plant2som%pom_p, &
         plant2som%dom_c, plant2som%dom_n, plant2som%dom_p, &
         plant2som%nh4, plant2som%no3, plant2som%psol,   &
         csite%plant_input_C(:,ipa), csite%plant_input_N(:,ipa),  &
         csite%plant_input_P(:,ipa))

    d_som%plvars%plant_input_C_pom(:,1) = plant2som%pom_c * gm2_mgg
    d_som%plvars%plant_input_N_pom(:,1) = plant2som%pom_n * gm2_mgg
    d_som%plvars%plant_input_P_pom(:,1) = plant2som%pom_p * gm2_mgg
    d_som%plvars%plant_input_C_dom = plant2som%dom_c * gm2_mgg
    d_som%plvars%plant_input_N_dom = plant2som%dom_n * gm2_mgg
    d_som%plvars%plant_input_P_dom = plant2som%dom_p * gm2_mgg

    input_pom_c_net = (plant2som%pom_c+litt2som%pom_c+wood2som_sum%pom_c) * &
         gm2_mgg
    input_dom_c_net = (plant2som%dom_c+litt2som%dom_c+wood2som_sum%dom_c) * &
         gm2_mgg
    input_pom_n_net = (plant2som%pom_n+litt2som%pom_n+wood2som_sum%pom_n) * &
         gm2_mgg
    input_dom_n_net = (plant2som%dom_n+litt2som%dom_n+wood2som_sum%dom_n) * &
         gm2_mgg
    input_pom_p_net = (plant2som%pom_p+litt2som%pom_p+wood2som_sum%pom_p) * &
         gm2_mgg
    input_dom_p_net = (plant2som%dom_p+litt2som%dom_p+wood2som_sum%dom_p) * &
         gm2_mgg
    input_nh4_net = (plant2som%nh4 + litt2som%nh4 + wood2som_sum%nh4) * &
         gm2_mgg + som%fluxes%nh4_dep(1)
    input_no3_net = (plant2som%no3 + litt2som%no3 + wood2som_sum%no3) * &
         gm2_mgg + som%fluxes%no3_dep(1)
    input_psol_net = (plant2som%psol + litt2som%psol + wood2som_sum%psol) * &
         gm2_mgg + som%fluxes%ppar_dep(1)
    input_ppar_net = 0.
    call mend_derivs_layer(npom, som_consts,  &
         som%cvars%pom(:,1), input_pom_c_net, d_som%cvars%pom(:,1),  &
         som%cvars%dom(1), input_dom_c_net, d_som%cvars%dom(1),  &
         som%cvars%enz_pom(:,1), d_som%cvars%enz_pom(:,1),  &
         som%cvars%mom(1), d_som%cvars%mom(1),  &
         som%cvars%qom(1), d_som%cvars%qom(1),  &
         som%cvars%enz_mom(1), d_som%cvars%enz_mom(1),  &
         som%cvars%amb(1), d_som%cvars%amb(1),   &
         som%cvars%dmb(1), d_som%cvars%dmb(1),   &
         som%fluxes%co2_lost(1), d_som%fluxes%co2_lost(1),  &
         som%fluxes%nmin(1), d_som%fluxes%nmin(1),  &
         som%fluxes%nitr(1), d_som%fluxes%nitr(1),  &
         som%nvars%pom(:,1), input_pom_n_net, d_som%nvars%pom(:,1),  &
         som%nvars%dom(1), input_dom_n_net, d_som%nvars%dom(1),  &
         som%nvars%enz_pom(:,1), d_som%nvars%enz_pom(:,1),  &
         som%nvars%mom(1), d_som%nvars%mom(1),   &
         som%nvars%qom(1), d_som%nvars%qom(1),   &
         som%nvars%enz_mom(1), d_som%nvars%enz_mom(1),   &
         som%nvars%amb(1), d_som%nvars%amb(1),  &
         som%nvars%dmb(1), d_som%nvars%dmb(1),  &
         som%invars%nh4(1), input_nh4_net, d_som%invars%nh4(1), &
         som%invars%no3(1), input_no3_net, d_som%invars%no3(1),  &
         som%pvars%pom(:,1), input_pom_p_net, d_som%pvars%pom(:,1),  &
         som%pvars%dom(1), input_dom_p_net, d_som%pvars%dom(1),  &
         som%pvars%enz_pom(:,1), d_som%pvars%enz_pom(:,1),  &
         som%pvars%mom(1), d_som%pvars%mom(1),   &
         som%pvars%qom(1), d_som%pvars%qom(1),  &
         som%pvars%enz_mom(1), d_som%pvars%enz_mom(1),   &
         som%pvars%amb(1), d_som%pvars%amb(1),  &
         som%pvars%dmb(1), d_som%pvars%dmb(1),   &
         som%invars%psol(1), input_psol_net, d_som%invars%psol(1),  &
         som%invars%plab(1), d_som%invars%plab(1), &
         som%fluxes%ngas_lost(1), d_som%fluxes%ngas_lost(1), &
         som%cvars%enz_ptase(1), d_som%cvars%enz_ptase(1), &
         som%nvars%enz_ptase(1), d_som%nvars%enz_ptase(1), &
         som%pvars%enz_ptase(1), d_som%pvars%enz_ptase(1),  &
         d_som%fluxes%nh4_plant(:,1), &
         som%fluxes%nh4_bnf(1), d_som%fluxes%nh4_bnf(1), &
         d_som%fluxes%no3_plant(:,1), &
         som%fluxes%c_leach(1), d_som%fluxes%c_leach(1), &
         som%fluxes%n_leach(1), d_som%fluxes%n_leach(1),  &
         som%fluxes%p_leach(1), d_som%fluxes%p_leach(1), &
         d_som%fluxes%p_plant(:,1), &
         som%invars%pocc(1), d_som%invars%pocc(1), &
         som%invars%ppar(1), d_som%invars%ppar(1), input_ppar_net,  &
         som%plvars%enz_plant_n(:,1), som%plvars%enz_plant_p(:,1), &
         som%plvars%vnh4up_plant(:,1), som%plvars%vno3up_plant(:,1),  &
         som%plvars%vpup_plant(:,1), som_water_drainage_ps, &
         csite%mend%bulk_den(ipa), pi1, wfp)

    call som2canopy_exchange(d_som%fluxes%co2_lost(1),  &
         csite%mend%bulk_den(ipa), som_consts, &
         d_can_co2, d_co2budget_storage, ccapcani)

    input_pom_c_net = plant2litt%pom_c - litt2som%pom_c + wood2litt_sum%pom_c
    input_dom_c_net = plant2litt%dom_c - litt2som%dom_c + wood2litt_sum%dom_c
    input_pom_n_net = plant2litt%pom_n - litt2som%pom_n + wood2litt_sum%pom_n
    input_dom_n_net = plant2litt%dom_n - litt2som%dom_n + wood2litt_sum%dom_n
    input_pom_p_net = plant2litt%pom_p - litt2som%pom_p + wood2litt_sum%pom_p
    input_dom_p_net = plant2litt%dom_p - litt2som%dom_p + wood2litt_sum%dom_p
    input_nh4_net = plant2litt%nh4 - litt2som%nh4 + wood2litt_sum%nh4 +  &
         litt%fluxes%nh4_dep(1)
    input_no3_net = plant2litt%no3 - litt2som%no3 + wood2litt_sum%no3 +  &
         litt%fluxes%no3_dep(1)
    input_psol_net = plant2litt%psol - litt2som%psol + wood2litt_sum%psol
    input_ppar_net = litt%fluxes%ppar_dep(1)
    call mend_derivs_layer(npom, litt_consts,  &
         litt%cvars%pom(:,1), input_pom_c_net, d_litt%cvars%pom(:,1),  &
         litt%cvars%dom(1), input_dom_c_net, d_litt%cvars%dom(1),  &
         litt%cvars%enz_pom(:,1), d_litt%cvars%enz_pom(:,1),  &
         litt%cvars%mom(1), d_litt%cvars%mom(1),  &
         litt%cvars%qom(1), d_litt%cvars%qom(1),  &
         litt%cvars%enz_mom(1), d_litt%cvars%enz_mom(1),  &
         litt%cvars%amb(1), d_litt%cvars%amb(1),   &
         litt%cvars%dmb(1), d_litt%cvars%dmb(1),   &
         litt%fluxes%co2_lost(1), d_litt%fluxes%co2_lost(1),  &
         litt%fluxes%nmin(1), d_litt%fluxes%nmin(1),  &
         litt%fluxes%nitr(1), d_litt%fluxes%nitr(1),  &
         litt%nvars%pom(:,1), input_pom_n_net, d_litt%nvars%pom(:,1),  &
         litt%nvars%dom(1), input_dom_n_net, d_litt%nvars%dom(1),  &
         litt%nvars%enz_pom(:,1), d_litt%nvars%enz_pom(:,1),  &
         litt%nvars%mom(1), d_litt%nvars%mom(1),   &
         litt%nvars%qom(1), d_litt%nvars%qom(1),   &
         litt%nvars%enz_mom(1), d_litt%nvars%enz_mom(1),   &
         litt%nvars%amb(1), d_litt%nvars%amb(1),  &
         litt%nvars%dmb(1), d_litt%nvars%dmb(1),  &
         litt%invars%nh4(1), input_nh4_net, d_litt%invars%nh4(1), &
         litt%invars%no3(1), input_no3_net, d_litt%invars%no3(1),  &
         litt%pvars%pom(:,1), input_pom_p_net, d_litt%pvars%pom(:,1),  &
         litt%pvars%dom(1), input_dom_p_net, d_litt%pvars%dom(1),  &
         litt%pvars%enz_pom(:,1), d_litt%pvars%enz_pom(:,1),  &
         litt%pvars%mom(1), d_litt%pvars%mom(1),   &
         litt%pvars%qom(1), d_litt%pvars%qom(1),  &
         litt%pvars%enz_mom(1), d_litt%pvars%enz_mom(1),   &
         litt%pvars%amb(1), d_litt%pvars%amb(1),  &
         litt%pvars%dmb(1), d_litt%pvars%dmb(1),   &
         litt%invars%psol(1), input_psol_net, d_litt%invars%psol(1),  &
         litt%invars%plab(1), d_litt%invars%plab(1), &
         litt%fluxes%ngas_lost(1), d_litt%fluxes%ngas_lost(1), &
         litt%cvars%enz_ptase(1), d_litt%cvars%enz_ptase(1), &
         litt%nvars%enz_ptase(1), d_litt%nvars%enz_ptase(1), &
         litt%pvars%enz_ptase(1), d_litt%pvars%enz_ptase(1), &
         d_litt%fluxes%nh4_plant(:,1), &
         litt%fluxes%nh4_bnf(1), d_litt%fluxes%nh4_bnf(1), &
         d_litt%fluxes%no3_plant(:,1), &
         litt%fluxes%c_leach(1), d_litt%fluxes%c_leach(1), &
         litt%fluxes%n_leach(1), d_litt%fluxes%n_leach(1), &
         litt%fluxes%p_leach(1), d_litt%fluxes%p_leach(1), &
         d_litt%fluxes%p_plant(:,1), &
         litt%invars%pocc(1), d_litt%invars%pocc(1), &
         litt%invars%ppar(1), d_litt%invars%ppar(1), input_ppar_net, &
         litt%plvars%enz_plant_n(:,1), litt%plvars%enz_plant_p(:,1), &
         litt%plvars%vnh4up_plant(:,1),  &
         litt%plvars%vno3up_plant(:,1), litt%plvars%vpup_plant(:,1), &
         litt_water_drainage, &
         csite%mend%bulk_den(ipa),pi1, wfp)

    do iwood = 1,nwood
       input_pom_c_net = plant2wood(iwood)%pom_c - wood2litt(iwood)%pom_c -  &
            wood2som(iwood)%pom_c
       input_dom_c_net = plant2wood(iwood)%dom_c - wood2litt(iwood)%dom_c -  &
            wood2som(iwood)%dom_c
       input_pom_n_net = plant2wood(iwood)%pom_n - wood2litt(iwood)%pom_n -  &
            wood2som(iwood)%pom_n
       input_dom_n_net = plant2wood(iwood)%dom_n - wood2litt(iwood)%dom_n -  &
            wood2som(iwood)%dom_n
       input_pom_p_net = plant2wood(iwood)%pom_p - wood2litt(iwood)%pom_p -  &
            wood2som(iwood)%pom_p
       input_dom_p_net = plant2wood(iwood)%dom_p - wood2litt(iwood)%dom_p -  &
            wood2som(iwood)%dom_p
       input_nh4_net = plant2wood(iwood)%nh4 - wood2litt(iwood)%nh4 -  &
            wood2som(iwood)%nh4 + wood(iwood)%fluxes%nh4_dep(1)
       input_no3_net = plant2wood(iwood)%no3 - wood2litt(iwood)%no3 -  &
            wood2som(iwood)%no3 + wood(iwood)%fluxes%no3_dep(1)
       input_psol_net = plant2wood(iwood)%psol - wood2litt(iwood)%psol -  &
            wood2som(iwood)%psol
       input_ppar_net = wood(iwood)%fluxes%ppar_dep(1)
       do jwood = 1, nwood
          input_pom_c_net = input_pom_c_net - wood2wood(iwood,jwood)%pom_c + &
               wood2wood(jwood,iwood)%pom_c
          input_pom_n_net = input_pom_n_net - wood2wood(iwood,jwood)%pom_n + &
               wood2wood(jwood,iwood)%pom_n
          input_pom_p_net = input_pom_p_net - wood2wood(iwood,jwood)%pom_p + &
               wood2wood(jwood,iwood)%pom_p
          input_dom_c_net = input_dom_c_net - wood2wood(iwood,jwood)%dom_c + &
               wood2wood(jwood,iwood)%dom_c
          input_dom_n_net = input_dom_n_net - wood2wood(iwood,jwood)%dom_n + &
               wood2wood(jwood,iwood)%dom_n
          input_dom_p_net = input_dom_p_net - wood2wood(iwood,jwood)%dom_p + &
               wood2wood(jwood,iwood)%dom_p
          input_nh4_net = input_nh4_net - wood2wood(iwood,jwood)%nh4 + &
               wood2wood(jwood,iwood)%nh4
          input_no3_net = input_no3_net - wood2wood(iwood,jwood)%no3 + &
               wood2wood(jwood,iwood)%no3
          input_psol_net = input_psol_net - wood2wood(iwood,jwood)%psol + &
               wood2wood(jwood,iwood)%psol
       enddo
       call mend_derivs_layer(npom, wood_consts(iwood), &
            wood(iwood)%cvars%pom(:,1), input_pom_c_net,  &
            d_wood(iwood)%cvars%pom(:,1), wood(iwood)%cvars%dom(1),  &
            input_dom_c_net, d_wood(iwood)%cvars%dom(1),  &
            wood(iwood)%cvars%enz_pom(:,1), d_wood(iwood)%cvars%enz_pom(:,1), &
            wood(iwood)%cvars%mom(1), d_wood(iwood)%cvars%mom(1),  &
            wood(iwood)%cvars%qom(1), d_wood(iwood)%cvars%qom(1),  &
            wood(iwood)%cvars%enz_mom(1), d_wood(iwood)%cvars%enz_mom(1),  &
            wood(iwood)%cvars%amb(1), d_wood(iwood)%cvars%amb(1),  &
            wood(iwood)%cvars%dmb(1), d_wood(iwood)%cvars%dmb(1),  &
            wood(iwood)%fluxes%co2_lost(1), d_wood(iwood)%fluxes%co2_lost(1), &
            wood(iwood)%fluxes%nmin(1), d_wood(iwood)%fluxes%nmin(1), &
            wood(iwood)%fluxes%nitr(1), d_wood(iwood)%fluxes%nitr(1), &
            wood(iwood)%nvars%pom(:,1), input_pom_n_net, &
            d_wood(iwood)%nvars%pom(:,1), wood(iwood)%nvars%dom(1),   &
            input_dom_n_net, d_wood(iwood)%nvars%dom(1),  &
            wood(iwood)%nvars%enz_pom(:,1), d_wood(iwood)%nvars%enz_pom(:,1), &
            wood(iwood)%nvars%mom(1), d_wood(iwood)%nvars%mom(1),  &
            wood(iwood)%nvars%qom(1), d_wood(iwood)%nvars%qom(1),  &
            wood(iwood)%nvars%enz_mom(1), d_wood(iwood)%nvars%enz_mom(1),   &
            wood(iwood)%nvars%amb(1), d_wood(iwood)%nvars%amb(1),  &
            wood(iwood)%nvars%dmb(1), d_wood(iwood)%nvars%dmb(1),  &
            wood(iwood)%invars%nh4(1), input_nh4_net, &
            d_wood(iwood)%invars%nh4(1), wood(iwood)%invars%no3(1),   &
            input_no3_net, d_wood(iwood)%invars%no3(1), &
            wood(iwood)%pvars%pom(:,1), input_pom_p_net, &
            d_wood(iwood)%pvars%pom(:,1), wood(iwood)%pvars%dom(1),   &
            input_dom_p_net, d_wood(iwood)%pvars%dom(1),  &
            wood(iwood)%pvars%enz_pom(:,1), d_wood(iwood)%pvars%enz_pom(:,1), &
            wood(iwood)%pvars%mom(1), d_wood(iwood)%pvars%mom(1), &
            wood(iwood)%pvars%qom(1), d_wood(iwood)%pvars%qom(1),  &
            wood(iwood)%pvars%enz_mom(1), d_wood(iwood)%pvars%enz_mom(1),   &
            wood(iwood)%pvars%amb(1), d_wood(iwood)%pvars%amb(1), &
            wood(iwood)%pvars%dmb(1), d_wood(iwood)%pvars%dmb(1),  &
            wood(iwood)%invars%psol(1), input_psol_net,  &
            d_wood(iwood)%invars%psol(1), wood(iwood)%invars%plab(1),  &
            d_wood(iwood)%invars%plab(1), wood(iwood)%fluxes%ngas_lost(1),  &
            d_wood(iwood)%fluxes%ngas_lost(1),  &
            wood(iwood)%cvars%enz_ptase(1), d_wood(iwood)%cvars%enz_ptase(1), &
            wood(iwood)%nvars%enz_ptase(1), d_wood(iwood)%nvars%enz_ptase(1), &
            wood(iwood)%pvars%enz_ptase(1), d_wood(iwood)%pvars%enz_ptase(1), &
            d_wood(iwood)%fluxes%nh4_plant(:,1),  &
            wood(iwood)%fluxes%nh4_bnf(1),  d_wood(iwood)%fluxes%nh4_bnf(1), &
            d_wood(iwood)%fluxes%no3_plant(:,1), &
            wood(iwood)%fluxes%c_leach(1), d_wood(iwood)%fluxes%c_leach(1),  &
            wood(iwood)%fluxes%n_leach(1), d_wood(iwood)%fluxes%n_leach(1),  &
            wood(iwood)%fluxes%p_leach(1), d_wood(iwood)%fluxes%p_leach(1), &
            d_wood(iwood)%fluxes%p_plant(:,1), &
            wood(iwood)%invars%pocc(1), d_wood(iwood)%invars%pocc(1), &
            wood(iwood)%invars%ppar(1), d_wood(iwood)%invars%ppar(1),  &
            input_ppar_net, wood(iwood)%plvars%enz_plant_n(:,1),  &
            wood(iwood)%plvars%enz_plant_p(:,1),   &
            wood(iwood)%plvars%vnh4up_plant(:,1), &
            wood(iwood)%plvars%vno3up_plant(:,1),   &
            wood(iwood)%plvars%vpup_plant(:,1), &
            wood_water_drainage, &
            csite%mend%bulk_den(ipa),pi1,wfp)

    enddo

    return
  end subroutine mend_derivs_coupler

  subroutine mend_update_diag(mend)
    use mend_state_vars, only: mend_model, nwood
    use mend_consts_coms, only: som_consts, litt_consts, wood_consts
    use mend_diagnose, only: mend_update_diag_layer
    implicit none
    type(mend_model) :: mend
    integer :: iwood

    call mend_update_diag_layer(mend%som, som_consts, 1, mend%bulk_den(1))
!    call mend_update_diag_layer(mend%litt, litt_consts, 1, mend%bulk_den(1))
!    do iwood = 1, nwood
!       call mend_update_diag_layer(mend%wood(iwood), wood_consts(iwood), 1, &
!            mend%bulk_den(1))
!    enddo

    return
  end subroutine mend_update_diag

  subroutine mend_slow_P(mend, ipa)
    use mend_state_vars, only: mend_model, nwood
    use mend_derivs, only: mend_slow_P_layer
    use mend_consts_coms, only: som_consts, litt_consts, wood_consts
    use mend_diagnose, only: mend_update_diag_layer
    implicit none
    type(mend_model) :: mend
    integer, intent(in) :: ipa
    integer :: iwood

    call mend_slow_P_layer(som_consts, mend%som%invars%plab(ipa), &
         mend%som%invars%pocc(ipa), mend%som%invars%psec(ipa), &
         mend%som%invars%ppar(ipa), &
         mend%som%invars%psol(ipa), mend%bulk_den(ipa))
    call mend_update_diag_layer(mend%som, som_consts, ipa, mend%bulk_den(ipa))

!    call mend_slow_P_layer(litt_consts, mend%litt%invars%plab(ipa), &
!         mend%litt%invars%pocc(ipa), mend%litt%invars%ppar(ipa), &
!         mend%litt%invars%psol(ipa))
!    call mend_update_diag_layer(mend%som, litt_consts, ipa)

!    do iwood = 1, nwood
!       call mend_slow_P_layer(wood_consts(iwood),   &
!            mend%wood(iwood)%invars%plab(ipa), &
!            mend%wood(iwood)%invars%pocc(ipa),   &
!            mend%wood(iwood)%invars%ppar(ipa), &
!            mend%wood(iwood)%invars%psol(ipa))
!       call mend_update_diag_layer(mend%wood(iwood), wood_consts(iwood), ipa)
!    enddo

    return
  end subroutine mend_slow_P

end Module mend_coupler
