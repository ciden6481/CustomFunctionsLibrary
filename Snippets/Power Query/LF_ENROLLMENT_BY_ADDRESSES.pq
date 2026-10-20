// @snippet.title: LF ENROLLMENT BY ADDRESSES
// @snippet.description: Snippet for LF_ENROLLMENT_BY_ADDRESSES.
// @snippet.tags: auto-generated

let
    Source = Oracle.Database("s92qery", [HierarchicalNavigation = true]),
    AcadCareerText = Text.Replace(Text.From(pAcadCareer), "'", "''"),
    pSTRM = {"2254","2262","2263"},
    StrmValues = if Value.Is(pSTRM, type list) then pSTRM else {pSTRM},
    StrmClause = Text.Combine(List.Transform(StrmValues, each "'" & Text.Replace(Text.From(_), "'", "''") & "'"), ","),
    SqlText = "
SELECT DISTINCT A.STRM, A.EMPLID, C.LAST_NAME, C.FIRST_NAME, D.ADDRESS1, D.ADDRESS2, D.CITY, D.STATE, D.POSTAL, B.CAMPUS, E.VC_JURIS_DESCR, F.EMAIL_ADDR, G.EMAIL_ADDR
  FROM PS_STDNT_ENRL A, PS_ACAD_PROG B, PS_SCC_NAMES_QVW C, PS_ADDRESSES D, PS_VC_JURISCDE_TBL E, PS_EMAIL_ADDRESSES F, PS_EMAIL_ADDRESSES G
  WHERE ( E.VC_JURIS_CODE = D.COUNTY
    AND ( A.INSTITUTION = 'LF298'
     AND A.ACAD_CAREER = '"
        & AcadCareerText
        & "'
     AND A.STRM IN ("
        & StrmClause
        & ")
     AND A.STDNT_ENRL_STATUS = 'E'
     AND A.EMPLID = B.EMPLID
     AND A.ACAD_CAREER = B.ACAD_CAREER
     AND A.INSTITUTION = B.INSTITUTION
     AND B.EFFDT =
        (SELECT MAX(B_ED.EFFDT) FROM PS_ACAD_PROG B_ED
        WHERE B.EMPLID = B_ED.EMPLID
          AND B.ACAD_CAREER = B_ED.ACAD_CAREER
          AND B.STDNT_CAR_NBR = B_ED.STDNT_CAR_NBR
          AND B_ED.EFFDT <= SYSDATE)
    AND B.EFFSEQ =
        (SELECT MAX(B_ES.EFFSEQ) FROM PS_ACAD_PROG B_ES
        WHERE B.EMPLID = B_ES.EMPLID
          AND B.ACAD_CAREER = B_ES.ACAD_CAREER
          AND B.STDNT_CAR_NBR = B_ES.STDNT_CAR_NBR
          AND B.EFFDT = B_ES.EFFDT)

     AND A.EMPLID = C.EMPLID
     AND C.EFFDT =
        (SELECT MAX(C_ED.EFFDT) FROM PS_SCC_NAMES_QVW C_ED
        WHERE C.EMPLID = C_ED.EMPLID
          AND C.NAME_TYPE = C_ED.NAME_TYPE
          AND C_ED.EFFDT <= SYSDATE)
     AND C.NAME_TYPE = 'PRI'
     AND A.EMPLID = D.EMPLID
     AND D.EFFDT =
        (SELECT MAX(D_ED.EFFDT) FROM PS_ADDRESSES D_ED
        WHERE D.EMPLID = D_ED.EMPLID
          AND D.ADDRESS_TYPE = D_ED.ADDRESS_TYPE
          AND D_ED.EFFDT <= SYSDATE)
     AND D.ADDRESS_TYPE = 'MAIL'
     AND A.EMPLID = F.EMPLID
     AND F.E_ADDR_TYPE = 'VCCS'
     AND A.EMPLID =  G.EMPLID(+)
     AND  G.E_ADDR_TYPE(+) = 'OTHR' ))",
    Result = Value.NativeQuery(Source, SqlText)
in
    Result