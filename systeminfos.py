#!/usr/bin/env python
import distro
import platform


def main():
    print(
        "Bitte beachten Sie, dass wir ohne Ticketnummer, Ihr Anliegen nicht bearbeiten können. / We cannot proceed your inquire without ticket number!")
    print(
        "Um eine Ticketnummer zu erhalten, schreiben Sie uns eine Mail an tux@tuxedocomputer.com mit Ihrem Anliegen. / To get an ticket number you can contact us by mail to tux@tuxedocomputers.com")
    IMNr = input("Wie lautet Ihre Ticketnummer? Mit [ENTER] bestätigen / What is your ticket number?: ")
    print("")
    print("Okay, we are working with ticket %s!" % IMNr)

    LinuxDistro = distro.linux_distribution()[0]
    LinuxDistroVersion = distro.linux_distribution()[0]
    Kernel = platform.platform()

    if distro.linux_distribution(full_distribution_name=False) == "arch":
        pass


if __name__ == '__main__':
    main()
