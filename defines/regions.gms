$TITLE Regions


*   Regions
set reg     Regions plus National /
    NEG     "New England"
    MID     "Middle Atlantic"
    ENC     "East North Central"
    WNC     "West North Central"
    SAC     "South Atlantic"
    ESC     "East South Central"
    WSC     "West South Central"
    MTN     "Mountain"
    PAC     "Pacific" 
    USA     "United States"     /;

set USA(reg) USA only           /
    USA     "United States"     /;

set r(reg)  Regions             /
    NEG     "New England"
    MID     "Middle Atlantic"
    ENC     "East North Central"
    WNC     "West North Central"
    SAC     "South Atlantic"
    ESC     "East South Central"
    WSC     "West South Central"
    MTN     "Mountain"
    PAC     "Pacific"           /;

*   States
set st      States /
    AK  "Alaska"
    AL  "Alabama"
    AR  "Arkansas"
    AZ  "Arizona"
    CA  "California"
    CO  "Colorado"
    CT  "Connecticut"
*   DC  "District of Columbia"
    DE  "Delaware"
    FL  "Florida"
    GA  "Georgia"
    HI  "Hawaii"
    IA  "Iowa"
    ID  "Idaho"
    IL  "Illinois"
    IN  "Indiana"
    KS  "Kansas"
    KY  "Kentucky"
    LA  "Louisiana"
    MA  "Massachusetts"
    MD  "Maryland"
    ME  "Maine"
    MI  "Michigan"
    MN  "Minnesota"
    MO  "Missouri"
    MS  "Mississippi"
    MT  "Montana"
    NC  "North Carolina"
    ND  "North Dakota"
    NE  "Nebraska"
    NH  "New Hampshire"
    NJ  "New Jersey"
    NM  "New Mexico"
    NV  "Nevada"
    NY  "New York"
    OH  "Ohio"
    OK  "Oklahoma"
    OR  "Oregon"
    PA  "Pennsylvania"
    RI  "Rhode Island"
    SC  "South Carolina"
    SD  "South Dakota"
    TN  "Tennessee"
    TX  "Texas"
    UT  "Utah"
    VA  "Virginia"
    VT  "Vermont"
    WA  "Washington"
    WI  "Wisconsin"
    WV  "West Virginia"
    WY  "Wyoming"
    US  "United States" /;

* map Census regions to states
set mapCENSUS(r,st) /
    NEG.(ct,me,ma,nh,ri,vt)
    MID.(nj,ny,pa)
    ENC.(il,in,mi,oh,wi)
    WNC.(ia,ks,mn,mo,ne,nd,sd)
    SAC.(de,fl,ga,md,nc,sc,va,wv)
    ESC.(al,ky,ms,tn)
    WSC.(ar,la,ok,tx)
    MTN.(az,co,id,mt,nv,nm,ut,wy)
    PAC.(ak,ca,hi,or,wa) /;



$ontext
*   Regions
set reg     Regions plus National /
    NEAST   "North East"
    ECENT   "East Central"
    SEAST   "South East"
    NCENT   "North Central"
    SCENT   "South Central"
    WEST    "West" 
    USA     "United States"
    /;

set USA(reg)    / USA /;

set r(reg)      Regions /
    NEAST   "North East"
    ECENT   "East Central"
    SEAST   "South East"
    NCENT   "North Central"
    SCENT   "South Central"
    WEST    "West"          /;

* states
set st       states /
    AK  "Alaska"
    AL  "Alabama"
    AR  "Arkansas"
    AZ  "Arizona"
    CA  "California"
    CO  "Colorado"
    CT  "Connecticut"
    DE  "Delaware"
    FL  "Florida"
    GA  "Georgia"
    HI  "Hawaii"
    IA  "Iowa"
    ID  "Idaho"
    IL  "Illinois"
    IN  "Indiana"
    KS  "Kansas"
    KY  "Kentucky"
    LA  "Louisiana"
    MA  "Massachusetts"
    MD  "Maryland"
    ME  "Maine"
    MI  "Michigan"
    MN  "Minnesota"
    MO  "Missouri"
    MS  "Mississippi"
    MT  "Montana"
    NC  "North Carolina"
    ND  "North Dakota"
    NE  "Nebraska"
    NH  "New Hampshire"
    NJ  "New Jersey"
    NM  "New Mexico"
    NV  "Nevada"
    NY  "New York"
    OH  "Ohio"
    OK  "Oklahoma"
    OR  "Oregon"
    PA  "Pennsylvania"
    RI  "Rhode Island"
    SC  "South Carolina"
    SD  "South Dakota"
    TN  "Tennessee"
    TX  "Texas"
    UT  "Utah"
    VA  "Virginia"
    VT  "Vermont"
    WA  "Washington"
    WI  "Wisconsin"
    WV  "West Virginia"
    WY  "Wyoming" /;

*   EMF Regions
SET mapCENSUS(r,st)  /
    NEAST.(ME, NH, VT, MA, RI, CT, NY                        )   
    ECENT.(PA, NJ, DE, MD, VA, WV, OH                        )   
    SEAST.(NC, SC, KY, TN, GA, FL, AL, MS                    )
    NCENT.(MI, IN, IL, WI, MN, IA, MO, ND, SD                )
    SCENT.(NE, KS, OK, AR, LA, TX                            )
    WEST.(WA, OR, ID, MT, WY, NV, UT, CO, CA, AZ, NM, AK, HI ) /;
$offtext