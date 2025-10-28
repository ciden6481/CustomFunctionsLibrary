# Definitions

## Status

> * 1=New
> * 2=Returning
> * 3=Transfer
### From sas reports
- Set Status to 1 by default.
- If admit_type is "ITF", set Status to 3.
- If FICE is not "008659" or is not blank, set Status to 3.
- If prev_degree is not blank, set Status to 3.
- If prvenrl is "Y", set Status to 2.
- *considers transfers from other VCCS as transfer, not returning*
### From data dictionary
- if [vx_ir_prior_stdnt = 'Y'] or [vx_ir_prior_stdnt = 'N' and institution is a Virginia Community College] then status = '2' and END; or 
- if [vx_ir_prior_stdnt = 'N'] and [admit_type = ('ITE' or 'TEF' or 'TRN' or 'ITF') or vx_ir_prev_degree ne <blank> or fice_cd ne <blank>, then status = '3'] and END; or
- status = '1' and END