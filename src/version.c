/*
 * The version PARSE VERSION shows: the mbt version of mbt.toml in the
 * form of the 2.x releases, 3.0.0 -> V3R0M0, 3.0.0-dev -> V3R0M0D,
 * 3.0.0-rc1 -> V3R0M0R1 (the VRM of mbt's data set names).
 */
#include <ctype.h>
#include <string.h>

#include "rexx.h"

/* copies a run of digits, false if there is none */
static int copydigits(const char **p, char **o)
{
	const char *s = *p;

	if (!isdigit((unsigned char) *s)) {
		return 0;
	}
	while (isdigit((unsigned char) *s)) {
		*(*o)++ = *s++;
	}
	*p = s;
	return 1;
}

/* "V3R0M0" from "3.0.0", "V3R0M0D" from "3.0.0-dev"; fills out[] */
static void vrm(const char *ver, char *out, size_t size)
{
	static const char sep[3] = { 'V', 'R', 'M' };
	char buf[32];
	char *o = buf;
	const char *p = ver;
	int i;

	for (i = 0; i < 3; i++) {
		*o++ = sep[i];
		if (!copydigits(&p, &o) || (i < 2 && *p++ != '.')) {
			strcpy(buf, "V0R0M0");
			o = buf + 6;
			p = "";
			break;
		}
	}
	if (*p == '-') {
		p++;
		if (strncmp(p, "dev", 3) == 0) {
			*o++ = 'D';
		} else if (isalpha((unsigned char) *p)) {
			*o++ = (char) toupper((unsigned char) *p);
			while (isalpha((unsigned char) *p)) {
				p++;
			}
			copydigits(&p, &o);
		}
	}
	*o = '\0';
	strncpy(out, buf, size - 1);
	out[size - 1] = '\0';
}

/* "BREXX/370 V3R0M0 (Oct 31 2026)" */
const char *RxVersionStr(void)
{
	static char str[sizeof(PACKAGE) + 64];
	char v[32];

	vrm(VERSION, v, sizeof(v));
	strcpy(str, PACKAGE " ");
	strcat(str, v);
	strcat(str, " (" __DATE__ ")");
	return str;
}
