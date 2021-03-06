import cmd
import shlex
import time
from corvus.client import Corvus

class Console(cmd.Cmd):
    def __init__(self, completekey='tab', stdin=None, stdout=None,
                 corvus=None):
        if corvus is None:
            corvus = Corvus()
        self._corvus = corvus
        self.prompt = "> "
        cmd.Cmd.__init__(self, completekey, stdin, stdout)

    def help_backup(self):
        self.stdout.write('backup <drive> <filename>\n'
                          'Read all sectors and save to an image file\n')

    def do_backup(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 2:
            return self.help_backup()
        drive = int(splitted[0])
        filename = splitted[1]

        total_sectors = self._corvus.get_drive_capacity(drive)
        with open(filename, "wb") as f:
            for i in range(total_sectors):
                data = self._corvus.read_sector_512(drive, i)
                f.write(''.join([ chr(d) for d in data ]))
                self.stdout.write("\r%d bytes" % (i * 512))
                self.stdout.flush()
            self.stdout.write("\n")

    def help_restore(self):
        self.stdout.write('restore <drive> <filename>\n'
                          'Write all sectors from an image file\n')

    def do_restore(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 2:
            return self.help_restore()
        drive = int(splitted[0])
        filename = splitted[1]

        total_sectors = self._corvus.get_drive_capacity(drive)
        with open(filename, "rb") as f:
            for i in range(total_sectors):
                data = [ ord(d) for d in f.read(512) ]
                if len(data) < 512:
                    break
                self._corvus.write_sector_512(1, i, data)
                self.stdout.write("\r%d bytes" % (i * 512))
                self.stdout.flush()
            self.stdout.write("\n")

    def help_scribble(self):
        self.stdout.write('scribble <drive> <count>\n'
                          'Seek to first and last sector <count> times.\n')

    def do_scribble(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 2:
            return self.help_scribble()
        drive = int(splitted[0])
        count = int(splitted[1])

        first_sector = 0
        last_sector = self._corvus.get_drive_capacity(1) - 1
        for i in range(count):
            self._corvus.read_sector_512(drive, first_sector)
            time.sleep(0.10)
            self._corvus.read_sector_512(drive, last_sector)
            time.sleep(0.10)

    def help_prep_enter(self):
        self.stdout.write('prep_enter <drive>\n'
                          'Enter prep mode.\n')

    def do_prep_enter(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 1:
            return self.help_prep_enter()

        drive = int(splitted[0])
        error = self._corvus.enter_prep_mode(drive)
        self.stdout.write("%02d\n" % error)

    def help_prep_exit(self):
        self.stdout.write('prep_exit\n'
                          'Exit prep mode (must be in prep mode).\n')

    def do_prep_exit(self, args):
        error = self._corvus.exit_prep_mode()
        self.stdout.write("%02d\n" % error)

    def help_prep_format(self):
        self.stdout.write('prep_format <drive>\n'
                          'Format the drive (must be in prep mode).\n')

    def do_prep_format(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 1:
            return self.help_prep_format()

        drive = int(splitted[0])
        error = self._corvus.format(drive)
        self.stdout.write("%02d\n" % error)

    def help_prep_verify(self):
        self.stdout.write('prep_verify <drive>\n'
                          'Verify the drive (must be in prep mode).\n')

    def do_prep_verify(self, args):
        splitted = shlex.split(args)
        if len(splitted) != 1:
            return self.help_prep_verify()

        drive = int(splitted[0])
        num_bad_sectors = self._corvus.verify(drive)
        self.stdout.write("%d bad sectors\n" % num_bad_sectors)

    def help_quit(self):
        self._output("Exit this program")

    def do_quit(self, args):
        return 1

def main():
    c = Console()
    c.do_help('')
    c.cmdloop()

if __name__ == "__main__":
    main()
