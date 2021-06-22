clear

tempfile cc
local st NY 
forval c = 1(2)77 {
    clear
    local z 
    if `c' < 11 local z=0
    import delimited "./IMPLAN18/`st'_0`z'`c' Industry Detail.csv", rowr(2) varn(2)
    drop if industrycode==0
    gen county = "`st'_0`z'`c'"
    if `c' > 1 append using `cc'
    save `cc', replace
}

save WA_Labor, replace
export delimited "./IMPLAN18/`st'_Labor.csv", replace


