#!/usr/bin/env python
'''
Check that each file assembles and that the output binary
is identical to the original file.
'''
import filecmp
import os
import subprocess
import shutil
import sys
import tempfile

FILES = {
    'prep-corvus-diag.asm':       'prep-corvus-diag.bin',
    'prep-hardbox-configure.asm': 'prep-hardbox-configure.bin',
    'rom-u62-c7.63.asm':          'rom-u62-c7.63.bin',
}

def main():
    here = os.path.abspath(os.path.dirname(__file__))

    failures = []
    for src in sorted(FILES.keys()):
        # find absolute path to original binary, if any
        original = FILES[src]
        if original is not None:
            original = os.path.join(here, FILES[src])

        # change to directory of source file
        # this is necessary for files that use include directives
        src_dirname = os.path.join(here, os.path.dirname(src))
        os.chdir(src_dirname)

        # filenames for assembly command
        tmpdir = tempfile.mkdtemp(prefix='corvus')
        srcfile = os.path.join(here, src)
        outfile = os.path.join(tmpdir, 'a.bin')
        lstfile = os.path.join(tmpdir, 'a.lst')
        subs = {'srcfile': srcfile, 'outfile': outfile, 'lstfile': lstfile}

        cmd = ("z80asm --list='%(lstfile)s' --output='%(outfile)s' "
               "'%(srcfile)s'")

        # try to assemble the file
        try:
            subprocess.check_output(cmd % subs, shell=True)
            assembled = True
        except subprocess.CalledProcessError as exc:
            sys.stdout.write(exc.output)
            assembled = False

        # check assembled output is identical to original binary
        if not assembled:
            sys.stderr.write("%s: assembly failed\n" % src)
            failures.append(src)
        elif original is None:
            sys.stdout.write("%s: ok\n" % src)
        elif filecmp.cmp(original, outfile):
            sys.stdout.write("%s: ok\n" % src)
        else:
            sys.stderr.write("%s: not ok\n" % src)
            failures.append(src)

        shutil.rmtree(tmpdir)

    return len(failures)

if __name__ == '__main__':
    if sys.version_info[:2] < (2, 7):
        sys.stderr.write("Python 2.7 or later required\n")
        sys.exit(1)

    status = main()
    sys.exit(status)
