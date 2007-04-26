/*

tini - download tracklogs from Brauniger and Flytec flight recorders
Copyright (C) 2007  Tom Payne

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#include "tini.h"

%%{

machine pbrsnp;

action string_begin { begin = fpc; }
action string_end {
	s = alloc(fpc - begin + 1);
	memcpy(s, begin, fpc - begin);
	s[fpc - begin] = '\0';
}
string = [^,]* %string_end;

action pbrsnp_instrument_id { snp->instrument_id = s; s = 0; }
action pbrsnp_pilot_name { snp->pilot_name = s; s = 0; }
action pbrsnp_serial_number { snp->serial_number = s; s = 0; }
action pbrsnp_software_version { snp->software_version = s; s = 0; }

main :=
	"PBRSNP" ","
	%string_begin string %pbrsnp_instrument_id ","
	%string_begin string %pbrsnp_pilot_name ","
	%string_begin digit* %string_end %pbrsnp_serial_number ","
	%string_begin string %pbrsnp_software_version
	0 @{ fbreak; };
}%%

snp_t *snp_new(const char *p)
{
    snp_t *snp = alloc(sizeof(snp_t));
    %% write data;
    int cs;
    const char *begin = 0;
    char *s = 0;
    %% write init;
    %% write exec noend;
    if (cs == pbrsnp_error || cs < pbrsnp_first_final) {
	snp_delete(snp);
	return 0;
    }
    return snp;
}

void snp_delete(snp_t *snp)
{
    if (snp) {
	free(snp->instrument_id);
	free(snp->pilot_name);
	free(snp->serial_number);
	free(snp->software_version);
	free(snp);
    }
}

/* vim: set filetype=ragel: */
