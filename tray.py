import gi
import os
import signal
import time

gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
gi.require_version('Notify', '0.7')

from gi.repository import Gtk as gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Notify as notify

APPINDICATOR_ID = 'customtray'

CURRPATH = os.path.dirname(os.path.realpath(__file__))

class Indicator():
    def __init__(self):
        self.indicator = appindicator.Indicator.new(APPINDICATOR_ID, CURRPATH+"/help.png", appindicator.IndicatorCategory.SYSTEM_SERVICES)
        self.indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.build_menu())
        self.threads = []
        notify.init(APPINDICATOR_ID)

    def build_menu(self):
        menu = gtk.Menu()

        # item_color = gtk.MenuItem('Change green')
        # item_color.connect('activate', self.change_green)

        # item_color2 = gtk.MenuItem('Change red')
        # item_color2.connect('activate', self.change_red)

        item_quit = gtk.MenuItem('Quit')
        item_quit.connect('activate', self.quit)

        # menu.append(item_color)
        # menu.append(item_color2)
        menu.append(item_quit)
        menu.show_all()
        return menu

    def change_green(self, source):
        self.indicator.set_icon(CURRPATH+"/ok.png")

    def change_red(self, source):
        self.indicator.set_icon(CURRPATH+"/error.png")

    def change_unknown(self, source):
        self.indicator.set_icon(CURRPATH+"/help.png")

    def quit(self, source):
        self.threads 
        gtk.main_quit()


indicator = Indicator()
signal.signal(signal.SIGINT, signal.SIG_DFL)
gtk.main()