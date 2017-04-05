#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
ZetCode Tkinter tutorial

This script centers a small
window on the screen. 

Author: Jan Bodnar
Last modified: November 2015
Website: www.zetcode.com
"""
import Tkinter

from Tkinter import Tk, Frame, BOTH, Label, Checkbutton, BooleanVar
from ttk import Frame, Button, Style


class WelcomeWindow(Frame):
  
    def __init__(self, parent):
        Frame.__init__(self, parent)   
         
        self.parent = parent
        self.parent.title("Ez v.0")

        self.awVar = BooleanVar()
        self.fbVar = BooleanVar()
        self.piVar = BooleanVar()
        self.clVar = BooleanVar()

        self.appDict = {'Adwords': False, 'Facebook': False, 'Piwik': False, 'Close.io': False}

        self.style = Style()
        self.style.theme_use("default")

        self.appchecked = []

        self.pack(fill=BOTH, expand=1)
        
        self.centerWindow(400,400)
        self.initUI()

    def centerWindow(self, w, h):

        sw = self.parent.winfo_screenwidth()
        sh = self.parent.winfo_screenheight()
        
        x = (sw - w)/2
        y = (sh - h)/2
        self.parent.geometry('%dx%d+%d+%d' % (w, h, x, y))

    def centerTop(self, toplevel):
        toplevel.update_idletasks()
        w = toplevel.winfo_screenwidth()
        h = toplevel.winfo_screenheight()
        size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
        x = w/2 - size[0]/2
        y = h/2 - size[1]/2
        toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))


    def callbackOk(self):
        self.appDict = {'Adwords': self.awVar.get(), 'Facebook': self.fbVar.get(), 'Piwik': self.piVar.get(), 'Close.io': self.clVar.get()}
        infoWindow = Tkinter.Toplevel(self)
        infoWindow.wm_title("Connection credentials")
        
        infoWindow.geometry('600x500')        
        self.centerTop(infoWindow)
        
        topLabel = Label(infoWindow, text="Please enter required credentials and files.")
        topLabel.pack(padx=5, pady=5, anchor='nw')

        quitButtonTop = Button(infoWindow, text="Quit", command=infoWindow.destroy)
        quitButtonTop.pack(side='right', padx=5, pady=5, anchor='se')

        okButtonTop = Button(infoWindow, text="OK", command=None)
        okButtonTop.pack(side='right', padx=5, pady=5, anchor='se')

        print self.appDict

    def initUI(self):
      
        quitButton = Button(self, text="Quit", command=self.quit)
        quitButton.pack(side='right', padx=5, pady=5, anchor='se')

        okButton = Button(self, text="OK", command=self.callbackOk)
        okButton.pack(side='right', padx=5, pady=5, anchor='se')

        welcomeText = Label(self, text="Please select connectors needed.")
        welcomeText.pack(padx=5, pady=5, anchor='nw')

        awCheck = Checkbutton(self, text='Google Adwords', borderwidth=1, var=self.awVar)
        awCheck.pack(padx=5, pady=5, anchor='nw')

        fbCheck = Checkbutton(self, text='Facebook', borderwidth=1, var=self.fbVar)
        fbCheck.pack(padx=5, pady=5, anchor='nw')

        piCheck = Checkbutton(self, text='Piwik', borderwidth=1, var=self.piVar)
        piCheck.pack(padx=5, pady=5, anchor='nw')

        clCheck = Checkbutton(self, text='Close.io', borderwidth=1, var=self.clVar)
        clCheck.pack(padx=5, pady=5, anchor='nw')


def main():
  
    root = Tk()
    ex = WelcomeWindow(root)
    root.mainloop()


if __name__ == '__main__':
    main()