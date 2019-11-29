{
    gsub("'","\"",$1)
    if (NR > 1) {
        if (NR == 2){
	    stmt = sprintf("alter pump %s.*",$1);
        } else {
	    stmt = stmt + sprintf(", %s.*",$1);
        }
    }
} 

END {
    printf "%s %s;\n",stmt, action;
}
