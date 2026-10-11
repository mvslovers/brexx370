"""A small mvsMF client for the project's MVS tools (mvstest.py, tso/).

mbt 3 owns the MVS connection: the tools run as `mbt run <command>`
(mbt/init.lua), and mbt hands them the target and the token of its
mvsMF session in the environment:

  MVSTEST_URL       http://host:port of mvsMF
  MVSTEST_USER      the userid of the session
  MVSTEST_TOKEN     the session's LtpaToken2
  MVSTEST_HLQ       the target's HLQ
  MVSTEST_VOLUME    the target's volume ("" when it names none)
  MVSTEST_JOBCLASS  the target's job class
  MVSTEST_MSGCLASS  the target's message class

There is no password here, so there is no Basic fallback: without a token
the tool stops. The token ends with mbt's session, and a tool cannot log
on again: when mvsMF restarts during a run, rerun the command.

The methods follow mbt 2's client (mbt/scripts/mbt/mvsmf.py, v2.1.2),
which these tools used until the move to mbt 3 (#420).
"""
import http.client
import json
import os
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass, field

# mvsMF's HTTPD answered HTTP/1.1 requests without Content-Length or
# chunked encoding, so Python waited for the end of the body. HTTP/1.0,
# as mbt 2 did.
http.client.HTTPConnection._http_vsn = 10
http.client.HTTPConnection._http_vsn_str = "HTTP/1.0"

# One line per failed request; mvsMF's error body can be an HTML page.
_ERR_MAX = 200

# The JES system DDs: every step's IEF142I/IEF450I/IEF272I is in these.
JES_DDNAMES = {"JESJCLIN", "JESMSGLG", "JESJCL", "JESYSMSG"}


class MvsMFError(Exception):
    """A request to mvsMF failed."""


def _one_line(err, limit=_ERR_MAX):
    s = " ".join(str(err).split())
    return s if len(s) <= limit else s[:limit - 3] + "..."


@dataclass
class Target:
    """The MVS system mbt runs the tool against."""
    url: str
    user: str
    token: str
    hlq: str
    volume: str
    jobclass: str
    msgclass: str

    @classmethod
    def from_env(cls, command):
        """The target mbt passed; `command` names the mbt run command."""
        env = os.environ
        if "MVSTEST_URL" not in env:
            raise SystemExit(f"no MVS target in the environment -- run this "
                             f"as 'mbt run {command}' (mbt/init.lua)")
        if not env.get("MVSTEST_TOKEN"):
            raise SystemExit("mbt passed no mvsMF session token: the target's "
                             "mvsMF gives no LtpaToken2, and this tool has no "
                             "password to log on with")
        user = env.get("MVSTEST_USER", "")
        return cls(url=env["MVSTEST_URL"].rstrip("/"), user=user,
                   token=env["MVSTEST_TOKEN"],
                   hlq=env.get("MVSTEST_HLQ") or user.upper(),
                   volume=env.get("MVSTEST_VOLUME", ""),
                   jobclass=env.get("MVSTEST_JOBCLASS") or "A",
                   msgclass=env.get("MVSTEST_MSGCLASS") or "H")


def to_vrm(version):
    """mbt's VRM: 3.0.0 -> V3R0M0, 3.0.0-dev -> V3R0M0D, 3.0.0-rc1 -> V3R0M0R1."""
    m = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)(?:-([a-z]+)(\d*))?", version)
    if not m:
        raise ValueError(f"not a version: {version}")
    vrm = f"V{m[1]}R{m[2]}M{m[3]}"
    if m[4] == "dev":
        vrm += "D"
    elif m[4]:
        vrm += m[4][0].upper() + m[5]
    return vrm


def jobcard(jobname, jobclass, msgclass, description="MBT"):
    """A JOB card (no trailing newline); the name is cut to 8."""
    jn = jobname[:8].upper()
    jn_field = jn.ljust(8) if len(jn) < 8 else jn + " "
    return (f"//{jn_field}JOB ({jobclass}),'{description}',\n"
            f"//          CLASS={jobclass},MSGCLASS={msgclass},\n"
            f"//          MSGLEVEL=(1,1),\n"
            f"//          NOTIFY=&SYSUID")


@dataclass
class JobResult:
    """A submitted job: rc 0, 4, ...; 9999 for an ABEND, 9998 a JCL error."""
    jobid: str
    jobname: str
    rc: int
    status: str       # "CC", "ABEND", "JCL ERROR", "TIMEOUT", "UNKNOWN"
    spool: str
    # One line per request that failed reading the spool back: an empty
    # spool with errors is an unreadable job, not one without output.
    spool_errors: list = field(default_factory=list)

    @property
    def success(self):
        return self.status == "CC"


class Client:
    """mvsMF over the session token mbt opened."""

    def __init__(self, target):
        self._base = f"{target.url}/zosmf"
        self._token = target.token

    def _request(self, method, path, body=None,
                 content_type="application/json", accept="application/json",
                 extra_headers=None, timeout=30):
        url = self._base + urllib.parse.quote(path, safe="/?=&()")
        req = urllib.request.Request(url, method=method)
        req.add_header("Cookie", f"LtpaToken2={self._token}")
        req.add_header("Accept", accept)
        if body is not None:
            req.add_header("Content-Type", content_type)
            req.data = body
        for key, val in (extra_headers or {}).items():
            req.add_header(key, val)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return resp.read()
        except urllib.error.HTTPError as e:
            if e.code == 401:
                raise MvsMFError(f"HTTP 401 for {method} {path}: the session "
                                 f"token is no longer valid (mvsMF restarted?)"
                                 f" -- rerun the mbt command")
            text = ""
            try:
                text = e.read().decode("utf-8", errors="replace")
            except Exception:
                pass
            raise MvsMFError(f"HTTP {e.code} {e.reason} for {method} {path}"
                             + (f": {text}" if text else ""))
        except urllib.error.URLError as e:
            raise MvsMFError(f"Connection failed to {url}: {e.reason}")
        # Once the request is out, a slow server raises a bare TimeoutError
        # and a dropped connection an OSError; URLError is one too, so these
        # come after it.
        except TimeoutError:
            raise MvsMFError(f"No response to {method} {path} within "
                             f"{timeout}s (read timeout)")
        except (http.client.HTTPException, OSError) as e:
            raise MvsMFError(f"Connection lost during {method} {path}: "
                             f"{type(e).__name__}: {e}")

    def _json(self, method, path, body=None):
        data = json.dumps(body).encode("utf-8") if body is not None else None
        raw = self._request(method, path, data)
        # latin-1 is byte-transparent for EBCDIC remnants in spool data
        return json.loads(raw.decode("latin-1")) if raw else {}

    # --- jobs ---

    def submit_jcl(self, jcl, timeout=120, jes_only=False):
        """Submit inline JCL and wait for its output."""
        raw = self._request("PUT", "/restjobs/jobs", jcl.encode("utf-8"),
                            content_type="text/plain")
        resp = json.loads(raw)
        jobname = resp.get("jobname", "UNKNOWN")
        jobid = resp.get("jobid", "UNKNOWN")
        backoff, i, elapsed = [1, 2, 3, 5], 0, 0
        while elapsed < timeout:
            delay = backoff[min(i, len(backoff) - 1)]
            time.sleep(delay)
            elapsed += delay
            i += 1
            try:
                data = self._json("GET", f"/restjobs/jobs/{jobname}/{jobid}")
            except MvsMFError as e:
                if "HTTP 401" in str(e):
                    raise
                continue
            if data.get("status") != "OUTPUT":
                continue
            rc, status = _parse_retcode(data.get("retcode"))
            spool, errors = self._collect_spool(jobname, jobid, jes_only)
            if rc == -1 and spool:        # MVS/CE's mvsMF gives no retcode
                rc, status = _parse_spool_rc(spool)
            return JobResult(jobid, jobname, rc, status, spool, errors)
        spool, errors = self._collect_spool(jobname, jobid)
        return JobResult(jobid, jobname, 9999, "TIMEOUT", spool, errors)

    def _collect_spool(self, jobname, jobid, jes_only=False):
        """(text, errors): the concatenated spool and one line per failed
        request; a per-DD failure is "{ddname}: {message}"."""
        try:
            data = self._json("GET", f"/restjobs/jobs/{jobname}/{jobid}/files")
        except MvsMFError as e:
            return "", [_one_line(e)]
        files = data if isinstance(data, list) else data.get("items", [])
        parts, errors = [], []
        for f in files:
            fid, ddname = f.get("id", ""), f.get("ddname", "")
            if not fid or (jes_only and ddname not in JES_DDNAMES):
                continue
            try:
                raw = self._request(
                    "GET", f"/restjobs/jobs/{jobname}/{jobid}/files/{fid}/records",
                    accept="text/plain")
                text = raw.decode("utf-8", errors="replace").replace("\r", "")
                parts.append(f"--- {ddname} ---\n{text}")
            except MvsMFError as e:
                parts.append(f"--- {ddname} --- [FAILED TO RETRIEVE: {e}]")
                errors.append(f"{ddname}: {_one_line(e)}")
        return "\n".join(parts), errors

    # --- data sets ---

    def dataset_exists(self, dsn):
        # the dslevel must be shorter than the name to list the data set
        # itself; at most two qualifiers, for MVS/CE
        parts = dsn.split(".")
        level = ".".join(parts[:max(min(len(parts) - 1, 2), 1)])
        try:
            items = self._json("GET", f"/restfiles/ds?dslevel={level}").get("items", [])
        except MvsMFError as e:
            if "HTTP 401" in str(e):
                raise
            return False
        return any(item.get("dsname", "").strip() == dsn for item in items)

    def create_dataset(self, dsn, dsorg, recfm, lrecl, blksize, space,
                       unit="SYSDA", volume=None):
        """space: [unit, primary, secondary(, directory blocks)]."""
        body = {"dsorg": dsorg, "alcunit": space[0], "primary": int(space[1]),
                "secondary": int(space[2]), "recfm": recfm, "lrecl": lrecl,
                "blksize": blksize, "unit": unit}
        if len(space) >= 4:
            body["dirblk"] = int(space[3])
        if volume:
            body["vol"] = volume
        self._json("POST", f"/restfiles/ds/{dsn}", body)

    def delete_dataset(self, dsn):
        self._request("DELETE", f"/restfiles/ds/{dsn}", accept="*/*")

    def list_members(self, dsn):
        data = self._json("GET", f"/restfiles/ds/{dsn}/member")
        return [m["member"].strip() for m in data.get("items", [])]

    def write_member(self, dsn, member, content):
        self._request("PUT", f"/restfiles/ds/{dsn}({member})",
                      content.encode("utf-8"), content_type="text/plain",
                      accept="*/*")

    def upload_binary(self, dsn, data):
        """Binary into a sequential data set (an XMIT); mvsMF rewrites it
        on MVS, so the timeout grows with the size."""
        self._request("PUT", f"/restfiles/ds/{dsn}", data,
                      content_type="application/octet-stream", accept="*/*",
                      extra_headers={"X-IBM-Data-Type": "binary"},
                      timeout=max(120, len(data) // (1024 * 1024) * 20 + 120))


def _parse_retcode(s):
    """"CC 0004" -> (4, "CC"); "ABEND S0C4" -> (9999, "ABEND"); None -> (-1, ...)."""
    if s is None:
        return -1, "UNKNOWN"
    s = s.strip()
    if s.startswith("CC "):
        try:
            return int(s[3:].strip()), "CC"
        except ValueError:
            return 9999, "CC"
    if "ABEND" in s:
        return 9999, "ABEND"
    if "JCL ERROR" in s:
        return 9998, "JCL ERROR"
    return 9999, "UNKNOWN"


def _parse_spool_rc(spool):
    m = re.search(r"COND CODE\s+(\d+)", spool)
    if m:
        return int(m.group(1)), "CC"
    if "IEF452I" in spool or "JCL ERROR" in spool:
        return 9998, "JCL ERROR"
    if "IEF472I" in spool or "ABEND" in spool:
        return 9999, "ABEND"
    return -1, "UNKNOWN"
