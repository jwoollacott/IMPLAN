*   Strip duplicates from IMPLAN GAMS data files
clear
foreach s in AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY {
    import delimited id value using `s'.gms, delim(" ") asflo stringc(2)
    duplicates drop
    export delim using `s'.gms, delim(" ") novar replace
    clear
}


