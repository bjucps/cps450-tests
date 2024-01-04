#!/usr/bin/awk 

/^PASS/ { print $2 "|" $3 "|![PASS](" PASS_IMG ")" }
/^FAIL/ { print $2 "|" $3 "|![FAIL](" FAIL_IMG ")" }
