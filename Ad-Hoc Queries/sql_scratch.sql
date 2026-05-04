select sysadm.ps_vx_ir_student.emplid,
       sysadm.ps_vx_ir_student.first_name,
       sysadm.ps_vx_ir_student.last_name,
       sysadm.ps_vx_ir_student.vx_ir_tkn_gpa_st,
       sysadm.ps_vx_ir_student.vx_ir_cum_gpa_st,
       sysadm.ps_vx_ir_student.address1,
       sysadm.ps_vx_ir_student.address2,
       sysadm.ps_vx_ir_student.city,
       sysadm.ps_vx_ir_student.state,
       sysadm.ps_vx_ir_student.postal,
       vccseml.vccs_email,
       prfph.prf_phone,
       sysadm.ps_vx_ir_student.vx_ir_hs_grad_yr,
       case
           when sysadm.ps_vx_ir_student.vx_xdul_attribute = 'Y' then
               'Y'
           when sysadm.ps_vx_ir_student.acad_plan in ( '041',
                                                '042',
                                                '043' ) then
               'Y'
           else
               'N'
       end as is_dual_enl
  from sysadm.ps_vx_ir_student
  left join (
	select emplid,
	       email_addr as vccs_email
	  from ps_email_addresses
	 where E_ADDR_TYPE = 'VCCS'
) vccseml
on sysadm.ps_vx_ir_student.emplid = vccseml.emplid
  left join (
	select emplid,
	       phone as prf_phone
	  from ps_personal_phone
	 where pref_phone_flag = 'Y'
) prfph
on sysadm.ps_vx_ir_student.emplid = prfph.emplid
  left join (
	select distinct sq.emplid
	  from (
		select ps_stdnt_grps_hist.emplid,
		       ps_stdnt_grps_hist.stdnt_group,
		       ps_stdnt_grps_hist.effdt,
		       ps_stdnt_grps_hist.eff_status
		  from ps_stdnt_grps_hist
		  left join (
			select emplid,
			       institution,
			       stdnt_group,
			       max(effdt) as md
			  from ps_stdnt_grps_hist
			 group by emplid,
			          institution,
			          stdnt_group
		) md
		on ps_stdnt_grps_hist.emplid = md.emplid
		   and ps_stdnt_grps_hist.institution = md.institution
		   and ps_stdnt_grps_hist.stdnt_group = md.stdnt_group
		   and ps_stdnt_grps_hist.effdt = md.md
		 where ps_stdnt_grps_hist.institution = 'LF298'
		   and ps_stdnt_grps_hist.stdnt_group = 'PTK'
	) sq
	 where sq.eff_status = 'A'
) ptk
on sysadm.ps_vx_ir_student.emplid = ptk.emplid
 where sysadm.ps_vx_ir_student.strm = '2243'
   and sysadm.ps_vx_ir_student.institution = 'LF298'
   and sysadm.ps_vx_ir_student.vx_ir_extract_type = 'D'
   and sysadm.ps_vx_ir_student.campus = 'MIDD'
   and ptk.emplid is null
   and sysadm.ps_vx_ir_student.vx_ir_tkn_gpa_st >= 12
   and sysadm.ps_vx_ir_student.VX_IR_CUM_GPA_ST >= 3.5
   
